# Shell scriptek – fájlok olvasása, írása és a fájlvégek

Az előző órákon megismertük a shell scriptek alapjait (lásd [`Material_4.md`](../Exercise_4/Material_4.md) és [`Material_5.md`](../Exercise_5/Material_5.md)). Ezen az órán a **fájlkezelésen** van a hangsúly: fájlok beolvasása soronként, eredmények írása fájlba, és amit a valódi fájlok „elronthatnak”: **hiányzó újsor a fájl végén, plusz üres sorok, Windows-os sorvégek**.

Az óra felépítése:

1. Fájlok olvasása és írása, átirányítások.
2. Fájlvégek és sorvégek: milyen hibákat okoznak, és hogyan kezeljük őket.
3. Az előző óra gyakorló feladatainak megoldása.
4. Az óra feladatai: az 1–5. általános script feladat, a 6–9. fájlt olvas és ír.
5. További gyakorlás: fájl beolvasós és fájlba író feladatok önálló megoldásra.

## Tartalom

1. [A mappa tartalma](#a-mappa-tartalma)
2. [Fájlok olvasása és írása](#fájlok-olvasása-és-írása)
3. [Fájlvégek és sorvégek](#fájlvégek-és-sorvégek)
4. [Univerzális minta: fájl beolvasása soronként](#univerzális-minta-fájl-beolvasása-soronként)
5. [Az előző óra gyakorló feladatainak megoldása](#az-előző-óra-gyakorló-feladatainak-megoldása)
6. [Az óra feladatai](#az-óra-feladatai)
7. [Gyakori hibák](#gyakori-hibák)
8. [További gyakorlás](#további-gyakorlás)

## A mappa tartalma

```text
Exercise_6/
├── Material_6.md             ez a leírás
├── .gitattributes            megakadályozza, hogy a git átírja a tesztfájlok sorvégeit
├── exercise_5_solutions/     az előző óra „További gyakorlás” feladatainak megoldásai és adatfájljai
├── tasks/                    az órai és a további gyakorló feladatok bemeneti fájljai
└── solutions/                az órai feladatok megoldásai
```

| Fájl | Tartalom |
|---|---|
| [`tasks/numbers_ok.txt`](tasks/numbers_ok.txt) | `10`, `20`, `30`: szabályos fájl |
| [`tasks/numbers_no_newline.txt`](tasks/numbers_no_newline.txt) | Ugyanez, de az utolsó sor után **nincs** újsor |
| [`tasks/numbers_empty_lines.txt`](tasks/numbers_empty_lines.txt) | Ugyanez, de a végén **két üres sor** is van |
| [`tasks/numbers_crlf.txt`](tasks/numbers_crlf.txt) | Ugyanez, **Windows-os (CRLF)** sorvégekkel |
| [`tasks/numbers_mixed.txt`](tasks/numbers_mixed.txt) | Minden csapda egyben: szóközök, üres sorok, CRLF, hibás sorok (7. feladat) |
| [`tasks/lines.txt`](tasks/lines.txt), [`words.txt`](tasks/words.txt), [`phone_registry.txt`](tasks/phone_registry.txt) | A 4., 2. és 5. feladat bemenete; egyiknél sincs újsor az utolsó sor után |
| [`tasks/messy.txt`](tasks/messy.txt), [`grades.txt`](tasks/grades.txt) | A 8. és 9. feladat bemenete (CRLF, szóközök, üres sorok) |
| `tasks/poem.txt`, `inventory.txt`, `server.log`, `names.txt`, `emails.txt`, `new_contacts.txt` | A [További gyakorlás](#további-gyakorlás) bemeneti fájljai |
| [`solutions/`](solutions/) | `1_factorial.sh` … `9_grades_report.sh`: az órai feladatok megoldásai, kommentezve |
| [`exercise_5_solutions/`](exercise_5_solutions/) | Az 5. heti gyakorló feladatok megoldásai, a hozzájuk tartozó adatfájlokkal |

A megoldásokat a `tasks` mappából futtassuk:

```bash
cd tasks
chmod +x ../solutions/*.sh
../solutions/6_file_info.sh numbers_no_newline.txt
```

> **Fontos:** A `tasks` mappa fájljait **ne nyissuk meg és mentsük el szerkesztővel**: a szerkesztő mentéskor „kijavíthatja” a fájl végét, és eltűnik a bemutatni kívánt hiba. Nézni a `cat -et` paranccsal érdemes őket (lásd lejjebb).

---

## Fájlok olvasása és írása

### Átirányítások

Az előző órán a `<<<` kapcsán már láttuk az átirányítások családját. A fájlkezeléshez ezek kellenek:

| Operátor | Jelentés |
|---|---|
| `parancs < file.txt` | A bemenet egy fájlból jön. |
| `parancs > file.txt` | A kimenet a fájlba kerül, a fájl **régi tartalma törlődik** (ha nem létezett, létrejön). |
| `parancs >> file.txt` | A kimenet a fájl **végére íródik** (*append*), a régi tartalom megmarad. |
| `> file.txt` | Önmagában: a fájl kiürítése, vagy üres fájl létrehozása. |
| `parancs << EOF … EOF` | A scriptbe írt többsoros szövegblokk a bemenet (*here document*). |
| `parancs <<< "szöveg"` | Egyetlen szöveg vagy változó tartalma a bemenet (*here string*). |
| `parancs >&2` | A kimenet a standard errorra megy (hibaüzenetek). |

A `>` és a `>>` különbsége:

```bash
echo "alma"  > fruits.txt      # fruits.txt: alma
echo "körte" > fruits.txt      # fruits.txt: körte            (az alma eltűnt)
echo "szilva" >> fruits.txt    # fruits.txt: körte, szilva    (hozzáfűzés)
```

**Tipikus minta:** a kimeneti fájlt a ciklus előtt `>`-rel kiürítjük, a ciklusban `>>`-rel hozzáfűzünk. A kiürítés nélkül a script második futtatása az első eredmény végére írna.

```bash
> "$output_file"

while IFS= read -r line || [ -n "$line" ]; do
    echo "$line" >> "$output_file"
done < "$input_file"
```

> **Fontos:** Ha a bemeneti és a kimeneti fájl ugyanaz, a `>` **még az olvasás előtt** kiüríti, és minden adat elvész. Ilyenkor ideiglenes fájlba írunk, és utána `mv`-vel felülírjuk az eredetit (lásd 5. hét, 4. feladat). A `[ "$input_file" -ef "$output_file" ]` akkor igaz, ha a két név ugyanarra a fájlra mutat.

### Soronkénti olvasás

Valódi fájlokra ezt a formát használjuk:

```bash
while IFS= read -r line || [ -n "$line" ]; do
    echo "Line: $line"
done < "$file"
```

| Rész | Jelentés |
|---|---|
| `done < "$file"` | A teljes ciklus bemenete a fájl, a `read` minden körben a következő sort olvassa. |
| `-r` | A `\` karakter változatlanul megmarad. |
| `IFS=` | A sor eleji és végi szóközök megmaradnak. (Ha épp le akarjuk vágni őket, elhagyjuk.) |
| `\|\| [ -n "$line" ]` | Az utolsó sor akkor is feldolgozásra kerül, ha utána nincs újsor (lásd lejjebb). |

A teljes, bemásolható mintát lásd: [Univerzális minta](#univerzális-minta-fájl-beolvasása-soronként).

**Mezőkre bontás:** ha a sor elválasztott mezőkből áll (pl. `Kiss Anna;87`), az `IFS` az elválasztó karakter, a `read` pedig változókba teszi a mezőket. Ha több mező van, mint változó, a sor maradéka az utolsóba kerül.

```bash
while IFS=';' read -r name points || [ -n "$name" ]; do
    echo "$name: $points"
done < grades.txt
```

> **Figyelem:** A `for line in $(cat file)` **nem** soronként, hanem szavanként halad (a `Kiss Anna` két elemre esik szét), és az üres sorok eltűnnek. Soronkénti feldolgozáshoz mindig `while read` kell.

**`echo` vagy `printf`?** Az `echo` mindig újsort ír a szöveg után; az `echo -n` és a `printf '%s'` nem. Így keletkezik az újsor nélküli utolsó sor.

---

## Fájlvégek és sorvégek

### Mi az a sor?

Egy szöveges fájlban a sort az **újsor karakter** zárja. Hogy ez melyik karakter (vagy karakterpár), az rendszerenként más:

| Rendszer | Sorvég | Jelölés |
|---|---|---|
| Linux, macOS | LF (*line feed*) | `\n` |
| Windows | CR LF (*carriage return + line feed*) | `\r\n` |

A bash és a Unix-os parancsok (`read`, `grep`, `wc` …) a `\n`-t tekintik sorvégnek. Szabályos fájlban **az utolsó sor után is** áll egy `\n`. A négy tesztfájl tartalma ugyanaz, mégis mind más:

| Fájl | A fájl bájtjai | `cat -et` kimenete |
|---|---|---|
| `numbers_ok.txt` | `10\n20\n30\n` | `10$` `20$` `30$` |
| `numbers_no_newline.txt` | `10\n20\n30` | `10$` `20$` `30` (nincs `$`) |
| `numbers_empty_lines.txt` | `10\n20\n30\n\n\n` | `10$` `20$` `30$` `$` `$` |
| `numbers_crlf.txt` | `10\r\n20\r\n30\r\n` | `10^M$` `20^M$` `30^M$` |

**Hogyan nézzük meg?** A sima `cat` a láthatatlan karaktereket nem mutatja.

| Parancs | Mit mutat? |
|---|---|
| `cat -et file` | Minden sor végén `$`, a `\r` helyén `^M`, a tab helyén `^I`. Ha az utolsó sor végén nincs `$`, ott nincs újsor. (Linuxon a `cat -A` ugyanez.) |
| `od -c file` | A fájl összes bájtja, a `\n` és `\r` is. |
| `tail -c 1 file \| od -c` | A fájl utolsó bájtja. |

> **Gyakori félreértés:** A szerkesztők a szabályos fájl utolsó sora alatt még egy üres sort mutatnak. Ez **nem** plusz üres sor, csak a kurzor helye a záró `\n` után. Plusz üres sor akkor van, ha két `\n` áll egymás után.

### Sorvég, újsor, `\n`, `\r` – mik ezek?

A **sorvég** és az **újsor jel** ugyanazt jelenti: azt a karaktert (vagy karakterpárt), amely lezár egy sort.

| Jelölés | Neve | Mit csinál? | Hol sorvég? |
|---|---|---|---|
| `\n` | LF, *line feed* (soremelés) | Egy sorral lejjebb lép | Linux, macOS |
| `\r` | CR, *carriage return* (kocsi vissza) | A sor elejére áll vissza | önmagában ma már sehol |
| `\r\n` | CR LF | A kettő együtt, **ebben a sorrendben** (nem `\n\r`!) | Windows |

A nevek az írógépből jönnek: a „kocsi vissza” a papírt tartó kocsit tolja vissza a sor elejére, a „soremelés” egy sorral feljebb tekeri a papírt. A Windows mindkettőt megtartotta, a Unix-os rendszerek csak a `\n`-t.

A bash `read` parancsa **csak a `\n`-t** tekinti sorvégnek, ott vágja el a sort. Egy Windows-os `10\r\n` sorból ezért `10\r` kerül a változóba: a `\r` a szöveg része marad (lásd a [3. esetet](#3-windows-os-sorvég-crlf)). A `cat -et` kimenetében is ez a sorrend látszik: `10^M$`, ahol a `^M` a `\r`, a `$` a `\n`.

### 1. Nincs újsor az utolsó sor után

Gyakran előfordul: a Windows Jegyzettömb és több szerkesztő nem tesz újsort a fájl végére, scriptből pedig az `echo -n` / `printf '%s'` hoz létre ilyet.

| Tünet | Megoldás |
|---|---|
| A `while read` ciklus **kihagyja az utolsó sort**: a `read` beolvassa, de hamisat ad, mert nem talált újsort. | `while IFS= read -r line \|\| [ -n "$line" ]` – ha a `read` hamis, de a `line` nem üres, a ciklus még lefut. |
| A `wc -l` **eggyel kevesebbet** mond, mert az újsorokat számolja, nem a sorokat. | Ciklussal számolunk, vagy `grep -c '' file`. |
| A `>>` hozzáfűzés **az utolsó sorhoz ragad**: `Tóth Csilla,06705554433Szabó Dénes,06301112222` | Előtte pótoljuk az újsort: `[ -n "$(tail -c 1 file)" ] && echo >> file` |

A `tail -c 1` trükk: a `$( )` levágja a szöveg végi újsort, ezért ha a fájl `\n`-nel végződik, az eredmény üres; ha nem, akkor nem üres.

### 2. Plusz üres sor(ok) a fájl végén

A `read` az üres sorokat is beolvassa, így a ciklus többször fut le, mint ahány adat van: rossz lesz a darabszám és az átlag, a számellenőrzés „hibás sort” jelez, a másoló script üres sorokat is átír.

**Megoldás:** az üres sorokat kihagyjuk:

```bash
if [ -z "$line" ]; then
    continue
fi
```

### 3. Windows-os sorvég (CRLF)

Ha egy Windows-on készült fájlt Linuxon (vagy macOS-en, Git Bash-ben) olvasunk, a `read` a `\n`-nél vág, így a `\r` **a sor végén marad**. Nem látszik, de elrontja a feldolgozást:

| Mit csinálunk? | Mi történik? |
|---|---|
| `[[ $line =~ ^[0-9]+$ ]]` | Hamis, mert a `10\r` végén nem számjegy áll. |
| `[ "$line" == "vége" ]` | Hamis, mert a `vége\r` nem egyenlő a `vége` szöveggel. |
| `sum=$(( sum + line ))` | Hiba: `syntax error: invalid arithmetic operator` |
| `IFS=';' read -r name points` | A `\r` az **utolsó** mezőbe (`points`) kerül. |
| Maga a script CRLF-es | `/bin/bash^M: bad interpreter` vagy `$'\r': command not found` |

**Honnan jön?**
- A fájlt Windows-on hozták létre (Jegyzettömb, Excel CSV export).
- A **git Windows-on** (`core.autocrlf=true`) a letöltött fájlokat CRLF-re alakíthatja. Ezt a repó gyökerében lévő `.gitattributes` megakadályozza (a `.sh` és `.txt` fájlok mindenhol LF-fel kerülnek ki). Ebben a mappában egy saját [`.gitattributes`](.gitattributes) is van, amely a tesztfájlokhoz egyáltalán nem enged hozzányúlni, mert itt a CRLF szándékos.

**Megoldás:**

| Módszer | Hatás |
|---|---|
| `line=${line%$'\r'}` | A ciklusban: a sor végéről levágja a `\r`-t (a `$'\r'` a bash jelölése a CR karakterre). |
| `tr -d '\r' < in.txt > out.txt` | Az egész fájlból törli a `\r` karaktereket. |
| `tr -d '[:space:]'` | Minden szóköz jellegű karaktert töröl, a `\r`-t is (a ZH-n megadott segítség). A szavak közötti szóközt is törli! |
| `dos2unix file.txt` | Erre szolgáló program (Git Bash-ben van, máshol telepíteni kell). |

> **Megjegyzés:** A Git Bash a CRLF-es scripteket elnézőbben kezeli, mint egy Linuxos bash: attól, hogy Windows-on lefut, a ZH-gépen még hibát adhat.

### Próbáljuk ki

A naiv ciklus, amit elsőre leírnánk:

```bash
count=0; sum=0
while read -r number; do
    count=$(( count + 1 ))
    sum=$(( sum + number ))
done < "$file"
```

A [7. feladat](#7-számok-összegzése-fájlból-fájlba) biztonságos megoldásával összevetve:

| Fájl | Naiv: sorok | Naiv: összeg | Biztonságos: összeg |
|---|---|---|---|
| `numbers_ok.txt` | 3 | 60 | 60 |
| `numbers_no_newline.txt` | **2** | **30** | 60 |
| `numbers_empty_lines.txt` | **5** | 60 | 60 |
| `numbers_crlf.txt` | 3 | **hiba** | 60 |

---

## Univerzális minta: fájl beolvasása soronként

A fentiek összefoglalása: **így olvassunk be egy fájlt soronként**. Ez a minta szinte minden fájlkezelő feladathoz jó: bemásoljuk, és csak a „feldolgozás” részt írjuk át.

```bash
#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

file=$1

if [ ! -f "$file" ]; then
    echo "Error: file '$file' does not exist" >&2
    exit 1
fi

while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$'\r'}              # Windows-os sorvég (\r) levágása

    if [ -z "$line" ]; then         # üres sor kihagyása
        continue
    fi

    # --- a sor feldolgozása ---
    echo "$line"
done < "$file"
```

| Rész | Mit old meg? |
|---|---|
| `IFS= read -r line` | A sor pontosan úgy kerül a változóba, ahogy a fájlban van (szóközök, `\`). |
| `\|\| [ -n "$line" ]` | Az utolsó sor akkor sem vész el, ha utána nincs újsor. |
| `line=${line%$'\r'}` | Windows-os (CRLF) fájlnál a sor végén maradó `\r` levágása. |
| `[ -z "$line" ]` + `continue` | Az üres sorok (a fájl végén lévők is) kihagyása. |
| `done < "$file"` | A ciklus a fájlból olvas. Csővezetékkel (`cat file \| while …`) ellentétben a ciklusban módosított változók (pl. számláló) a ciklus után is megmaradnak. |

**Változatok:**

- **Mezőkre bontva** (pl. `név;pont`): `while IFS=';' read -r name points || [ -n "$name" ]; do`. A `\r` ilyenkor az **utolsó** mezőbe kerül, ezért azt vágjuk: `points=${points%$'\r'}`.
- **Szóközök nélkül** (pl. ha számokat olvasunk): `number=$(echo "$line" | tr -d '[:space:]')` – a szóközöket, tabokat és a `\r`-t is törli.
- **Fájlba írva:** a ciklus előtt `> "$output_file"` (kiürítés), a ciklusban `echo "…" >> "$output_file"`.

---

## Az előző óra gyakorló feladatainak megoldása

A megoldások az [`exercise_5_solutions/`](exercise_5_solutions/) mappában vannak, kommentekkel. Ebből a mappából futtassuk őket, mert az itteni `patients.txt`, `menu.txt` és `main_folder/` fájlokkal dolgoznak.

> **Megjegyzés:** Az 5. óra feladatainak **ciklusokkal** írt megoldásai az 5. hét mappájában vannak: [`../Exercise_5/solutions_with_loops/`](../Exercise_5/solutions_with_loops/).

| Feladat | Megoldás | A lényeg |
|---|---|---|
| 1. A 8. feladat bővítése `-y <év>` kapcsolóval | [`1_patients_query_year.sh`](exercise_5_solutions/1_patients_query_year.sh) | Új függvény és új `case` ág; az év ellenőrzése: `^[0-9]{4}$` |
| 2. `.txt` fájlok sorainak száma | [`2_txt_line_counts.sh`](exercise_5_solutions/2_txt_line_counts.sh) | `for file in "$dir"/*.txt`, `wc -l`, összegzés |
| 3. Egy hónap betegei ábécérendben | [`3_patients_in_month.sh`](exercise_5_solutions/3_patients_in_month.sh) | Paraméter, vagy ha nincs, `read`; `grep \| cut \| sort` |
| 4. Menü biztonsági mentéssel | [`4_menu_with_backup.sh`](exercise_5_solutions/4_menu_with_backup.sh) | A 7. feladat függvényben; hibánál `return`, nem `exit` (az a menüt is leállítaná) |

```bash
./2_txt_line_counts.sh main_folder
```

```text
main_folder/text1.txt: 2
main_folder/text3.txt: 0
Total: 2 line(s) in 2 file(s)
```

Itt látszik a mai téma: a `text3.txt` egy sort tartalmaz (`banan`), a `wc -l` mégis `0`-t mond, mert az utolsó sor után nincs újsor.

---

## Az óra feladatai

**Minden feladatra érvényes:** a script ellenőrizze a paraméterek számát és a fájl létezését; a hibaüzenetek a standard errorra menjenek (`>&2`), és a script `exit 1`-gyel álljon le.

### 1. Faktoriális

Megoldás: [`1_factorial.sh`](solutions/1_factorial.sh)

Írjunk shell script programot, ami kiszámolja egy szám (n) faktoriálisát!

```bash
../solutions/1_factorial.sh 5      # 5! = 120
../solutions/1_factorial.sh 21     # Error: the number must be at most 20
```

> **Tipp:** A szorzat 1-ről indul, így a `0!` is helyes. A bash 64 bites egészekkel számol, a `21!` már nem fér el.

### 2. Szavak rendezése

Megoldás: [`2_sorted_words.sh`](solutions/2_sorted_words.sh)

Írjunk script programot, ami szavakat olvas be egészen addig, míg a `vége` szót nem írjuk be, majd sorba rendezve kiírja a képernyőre azokat! Működjön akkor is, ha a bemenet fájlból jön (`< words.txt`).

```bash
../solutions/2_sorted_words.sh < words.txt
```

```text
Sorted words:
alma
barack
körte
szilva
```

Amit használunk: `while read … || [ -n "$word" ]`, `break`, tömb (`words+=("$word")`), `printf '%s\n' "${words[@]}" | sort`.

> **Tipp:** A `words.txt`-ben nincs `vége`, és az utolsó szó (`barack`) után nincs újsor. A ciklus a fájl végén is leáll, a `|| [ -n "$word" ]` miatt pedig a `barack` sem vész el.

### 3. Paraméterek összeadása

Megoldás: [`3_sum_parameters.sh`](solutions/3_sum_parameters.sh)

Írjunk programot, amelyik a paraméterül kapott számokat összeadja, és az összeget a szabványos kimenetre írja! A program maximum 10 számot tudjon összeadni! A számok helyett megadhatjuk a `--help` kapcsolót, aminek hatására írjunk ki rövid ismertetőt a programról!

```bash
../solutions/3_sum_parameters.sh 4 -2 10     # Sum: 12
../solutions/3_sum_parameters.sh 1 x         # Error: 'x' is not an integer
```

> **Tipp:** A `--help`-et a paraméterek számának ellenőrzése **előtt** nézzük meg. A kért súgó nem hiba: standard outputra írjuk, és `exit 0`.

### 4. Páros és páratlan sorok szétválogatása

Megoldás: [`4_odd_even_lines.sh`](solutions/4_odd_even_lines.sh)

Írjunk programot, ami szétválogat egy paraméterben megadott fájlt páros és páratlan sorokra, majd ezeket új fájlokban (`odd_lines.txt`, `even_lines.txt`) elhelyezi!

```bash
../solutions/4_odd_even_lines.sh lines.txt
cat odd_lines.txt        # asd, asd3, asd5
cat even_lines.txt       # asd2, asd4
```

> **Tipp:** A `lines.txt` utolsó sora (`asd5`) után nincs újsor: a `|| [ -n "$line" ]` nélkül kimaradna. A kimeneti fájlokat a ciklus előtt `>`-rel ürítjük ki, a ciklusban `>>`-rel írunk.

### 5. Telefonregiszter

Megoldás: [`5_phone_registry.sh`](solutions/5_phone_registry.sh)

Telefonregiszter program, amely a `phone_registry.txt` fájlban `Név,szám` formában tárolja az adatokat, és kapcsolók segítségével a következőket tudja:

| Kapcsoló | Hatás |
|---|---|
| `-a <név> <szám>` | Felvesz egy nevet és egy telefonszámot a listába (ügyeljünk a dupla elemekre) |
| `-d <név>` | Törli a nevet és a hozzá tartozó telefonszámot |
| `-s <minta>` | Megkeresi az illeszkedő neveket, és kiírja a telefonszámukat |
| `-c` | A tárolt telefonszámok darabszáma |
| `-o` | A nevek rendezve, egyszeresen |

```bash
../solutions/5_phone_registry.sh -a "Szabó Dénes" 06301112222     # Added: Szabó Dénes,06301112222
../solutions/5_phone_registry.sh -s szab                          # Szabó Dénes: 06301112222
../solutions/5_phone_registry.sh -c                               # Number of phone numbers: 4
../solutions/5_phone_registry.sh -d "Szabó Dénes"                 # Deleted: Szabó Dénes
```

Amit használunk: `case`, függvények, `grep -q "^$name,"` (van-e már ilyen név), `grep -v` + ideiglenes fájl + `mv` (törlés), `grep -i` + `while IFS=, read` (keresés), `grep -c ''`, `cut | sort -u`.

> **Tipp:** A `phone_registry.txt` utolsó sora után nincs újsor. Az új bejegyzés hozzáfűzése előtt ezt pótolni kell, különben az utolsó sorhoz ragad. A `-c` ezért nem `wc -l`-lel számol.

### 6. Mi van a fájl végén?

Megoldás: [`6_file_info.sh`](solutions/6_file_info.sh)

Írjunk scriptet, amely a paraméterként kapott fájlról kiírja: a sorok számát a `wc -l` és egy `read` ciklus szerint, hogy újsorral végződik-e, hány üres sora van, és hány sor végződik `\r\n`-nel.

```bash
../solutions/6_file_info.sh numbers_no_newline.txt
```

```text
File:                 numbers_no_newline.txt
Lines (wc -l):        2
Lines (read loop):    3
Ends with newline:    NO
Empty lines:          0
Lines ending in CRLF: 0
```

Futtassuk le mind a négy `numbers_*.txt` fájlra, és vessük össze az eredményt a `cat -et` kimenetével!

### 7. Számok összegzése fájlból fájlba

Megoldás: [`7_sum_numbers.sh`](solutions/7_sum_numbers.sh)

Írjunk scriptet, amely egy bemeneti fájlból (soronként egy egész szám) a helyes számokat átírja egy kimeneti fájlba, a végére pedig az összegüket írja: `Sum: <összeg>`. Az üres sorokat hagyja ki, a hibás sorokról írjon figyelmeztetést a sorszámmal. Mind az öt `numbers_*.txt` fájlon működjön helyesen!

```bash
../solutions/7_sum_numbers.sh numbers_mixed.txt result.txt
```

```text
Warning: line 6 is not an integer, skipped: 'abc'
Warning: line 8 is not an integer, skipped: '1.5'
Sum: 133
```

A `result.txt` tartalma: `15`, `-4`, `7`, `12`, `3`, `100`, `Sum: 133`.

> **Tipp:** A `tr -d '[:space:]'` egy lépésben törli a sorból a szóközöket, a tabokat és a Windows-os `\r`-t is.

### 8. Szöveges fájl rendbetétele

Megoldás: [`8_normalize_file.sh`](solutions/8_normalize_file.sh)

Írjunk scriptet, amely a bemeneti fájlból egy „tiszta” kimeneti fájlt készít: nincs benne `\r`, a sorok elején és végén nincs szóköz, nincsenek üres sorok, és az utolsó sor után is van újsor.

```bash
../solutions/8_normalize_file.sh messy.txt clean.txt
cat -et clean.txt
```

```text
Első sor$
Második sor, elején szóközzel$
Negyedik sor, előtte üres sor volt$
Ötödik sor$
```

> **Tipp:** A `tr -d '\r'` törli a `\r` karaktereket, a `read -r line` (**`IFS=` nélkül**) levágja a sor széleiről a szóközöket, az `echo` pedig minden sor után újsort ír.

### 9. Jegyek kiszámítása, jelentés fájlba

Megoldás: [`9_grades_report.sh`](solutions/9_grades_report.sh)

A `grades.txt` első sora fejléc, utána soronként `név;pont`. A fájlban CRLF sorvégek, üres sorok, egy hibás pontszám van, és az utolsó sor után nincs újsor. Írjunk scriptet, amely a kimeneti fájlba minden hallgatóhoz kiírja a nevét, pontszámát és jegyét, a végére pedig a hallgatók számát, az átlagot és a legjobb hallgatót.

Ponthatárok: `0–49`: 1, `50–59`: 2, `60–69`: 3, `70–84`: 4, `85–100`: 5.

```bash
../solutions/9_grades_report.sh grades.txt report.txt
cat report.txt
```

```text
name;points;grade
Kiss Anna;87;5
Nagy Béla;45;1
Tóth Csilla;92;5
Kovács Dániel;38;1
Szabó Emese;71;4
Varga Gergő;60;3
Molnár Hanna;55;2
---
Students: 7
Average: 64
Best: Tóth Csilla (92)
```

> **Tipp:** A `\r` a sor **utolsó** mezőjébe, a `points` változóba kerül. Ha nem töröljük, egyetlen pontszám sem lesz „szám”.

---

## Gyakori hibák

| Hibás | Helyes | Magyarázat |
|---|---|---|
| `while read -r line` | `while IFS= read -r line \|\| [ -n "$line" ]` | Újsor nélküli utolsó sornál kimarad az utolsó sor. |
| `for line in $(cat file)` | `while IFS= read -r line …; done < file` | A `for` szavakra bont, nem sorokra. |
| `wc -l` mint sorok száma | `grep -c '' file` vagy ciklus | A `wc -l` az újsorokat számolja. |
| `echo "$new" >> file` vakon | előtte `[ -n "$(tail -c 1 file)" ] && echo >> file` | Az új sor az utolsóhoz ragadhat. |
| `[[ $line =~ ^[0-9]+$ ]]` Windows-os fájlon | előtte `line=${line%$'\r'}` | A sor végén ott a láthatatlan `\r`. |
| `>>` a ciklusban, előtte kiürítés nélkül | a ciklus előtt `> "$out"` | A második futtatás az előző eredmény végére ír. |
| `parancs < f.txt > f.txt` | ideiglenes fájl, majd `mv` | A `>` olvasás előtt kiüríti a fájlt. |
| `avg=$(( sum / count ))` ellenőrzés nélkül | előtte `if [ "$count" -eq 0 ]` | Üres fájlnál osztás nullával. |

---

## További gyakorlás

Minden feladat **fájlból olvas és fájlba ír**. A bemeneti fájlok a [`tasks/`](tasks/) mappában vannak, és tartalmazzák a mai óra csapdáit. A kimeneti fájlt minden futtatáskor újra hozzuk létre.

1. **Sorok számozása.** A [`poem.txt`](tasks/poem.txt) sorait írjuk egy új fájlba `<sorszám>: <sor>` formában. Az üres sorok üresen maradjanak, és ne kapjanak sorszámot. Az utolsó sor (`Vége a versnek.`) után nincs újsor; a kimenetben `5:` sorszámmal kell szerepelnie.

2. **Raktárkészlet értéke.** Az [`inventory.txt`](tasks/inventory.txt) első sora fejléc, utána `termék;darab;egységár` sorok jönnek (CRLF, üres sorok). Az `inventory_report.txt`-be írjuk ki soronként a terméket és az értékét (`darab * egységár`), a végére a teljes értéket. A hibás sorok a sorszámukkal az `errors.txt`-be kerüljenek. Elvárt eredmény: teljes érték `18840`, 2 hibás sor (`szilva`, `narancs`).

3. **Naplófájl szétválogatása.** A [`server.log`](tasks/server.log) sorai `dátum idő SZINT üzenet` formájúak. Válogassuk szét a sorokat szintenként (`info.log`, `warning.log`, `error.log`), és írjuk ki, melyik szintből hány sor volt. Többszöri futtatás után is ugyanaz legyen az eredmény. Elvárt eredmény: 5 INFO, 2 WARNING, 2 ERROR (az utolsó sor után nincs újsor!).

4. **Két fájl összefésülése.** A [`names.txt`](tasks/names.txt) és az [`emails.txt`](tasks/emails.txt) i. sora összetartozik. Írjuk a `contacts.txt`-be `név;email` formában; ha az egyik fájl rövidebb, a hiányzó mező maradjon üres (`Szabó Emese;`). Segítség: olvassuk be mindkét fájlt egy-egy tömbbe, és indexes `for` ciklussal járjuk be őket.

5. **Telefonregiszter bővítése.** Bővítsük az 5. feladatot egy `-e <név> <új szám>` (módosítás) és egy `-i <fájl>` (importálás) kapcsolóval. Importáláskor a szóközöket és a `\r`-t vágjuk le, a hibás sorokat és a már meglévő neveket hagyjuk ki. Próbafájl: [`new_contacts.txt`](tasks/new_contacts.txt). Elvárt eredmény: 2 új név (`Varga Gergő`, `Molnár Hanna`), a `Kiss Anna` már szerepel, a `Hibás Sor` hibás.

---

## További anyagok

| Forrás | Leírás |
|---|---|
| [`Material_5.md`](../Exercise_5/Material_5.md) | Az előző óra anyaga |
| https://mywiki.wooledge.org/BashFAQ/001 | Hogyan olvassunk fájlt soronként (és miért `IFS= read -r`) |
| https://www.shellcheck.net/ | Shell scriptek automatikus ellenőrzése |
