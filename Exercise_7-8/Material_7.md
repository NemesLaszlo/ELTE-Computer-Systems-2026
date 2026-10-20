# Shell scriptek – gyakorlás: reguláris kifejezések, szövegfeldolgozás és kulcs-érték tároló

Az előző három órán megismertük a shell scriptek alapjait ([`Material_4.md`](../Exercise_4/Material_4.md)), az összetett scripteket, kapcsolókat és függvényeket ([`Material_5.md`](../Exercise_5/Material_5.md)), valamint a fájlok olvasását és írását, a fájlvégek csapdáival ([`Material_6.md`](../Exercise_6/Material_6.md)). Ezen a két órán **gyakorlunk**: a feladatok a ZH-ra készítenek fel, és mindegyikben ugyanazt a néhány eszközt használjuk újra és újra: soronkénti fájlolvasás, reguláris kifejezések, szövegműveletek, tömbök. Új elem a **kulcs-érték tároló** (asszociatív tömb), amellyel darabszámokat gyűjtünk egy fájlból.

> **Videó:** A 12 órai feladat megoldása lépésről lépésre, úgy, ahogy az órán is dolgozunk: https://youtu.be/PnZwul4jvLc

Az óra felépítése:

1. Rövid ismétlés: reguláris kifejezések a scriptben, szövegműveletek, tömbök; új elem: a kulcs-érték tároló.
2. Az előző óra gyakorló feladatainak megoldása.
3. Az óra feladatai: 13 feladat, részletes leírással és megoldással.
4. További gyakorlás: hasonló feladatok önálló megoldásra.

## Tartalom

1. [A mappa tartalma](#a-mappa-tartalma)
2. [Rövid ismétlés és új alapok](#rövid-ismétlés-és-új-alapok)
   - [Az univerzális minta](#az-univerzális-minta)
   - [Reguláris kifejezések a scriptben](#reguláris-kifejezések-a-scriptben)
   - [Szövegműveletek](#szövegműveletek)
   - [Tömbök](#tömbök)
   - [Kulcs-érték tároló: asszociatív tömb](#kulcs-érték-tároló-asszociatív-tömb)
3. [Az előző óra gyakorló feladatainak megoldása](#az-előző-óra-gyakorló-feladatainak-megoldása)
4. [Az óra feladatai](#az-óra-feladatai)
5. [Gyakori hibák](#gyakori-hibák)
6. [További gyakorlás](#további-gyakorlás)
7. [További anyagok](#további-anyagok)

## A mappa tartalma

```text
Exercise_7-8/
├── Material_7.md             ez a leírás
├── Officia_Doc.pdf           a gyakorlat hivatalos feladatsora (1–12. feladat)
├── .gitattributes            megakadályozza, hogy a git átírja a tesztfájlok sorvégeit
├── exercise_6_solutions/     az előző óra „További gyakorlás” feladatainak megoldásai és adatfájljai
├── tasks/                    az órai és a további gyakorló feladatok bemeneti fájljai
└── solutions/                az órai feladatok megoldásai
```

| Fájl | Tartalom |
|---|---|
| [`tasks/numbers_mixed.txt`](tasks/numbers_mixed.txt) | Számok és szövegek vegyesen, tizedes törtek, előjel; az utolsó sor után nincs újsor (1. feladat) |
| [`tasks/letters.txt`](tasks/letters.txt) | Csak betűs és vegyes sorok (2. feladat) |
| [`tasks/sentences.txt`](tasks/sentences.txt) | Mondatok, több sorban a `harmadik` szó (3. feladat) |
| [`tasks/fruits.txt`](tasks/fruits.txt) | Mondatok `alma`, `körte` és `asd` szavakkal (4. feladat) |
| [`tasks/replace.txt`](tasks/replace.txt) | Három mondat az `alma` szóval (5. feladat) |
| [`tasks/two_digit_numbers.txt`](tasks/two_digit_numbers.txt) | Kétjegyű számok (6. feladat) |
| [`tasks/word_pairs.txt`](tasks/word_pairs.txt) | Soronként két szó (7. feladat) |
| [`tasks/numbers.txt`](tasks/numbers.txt) | Számok, egy hibás sorral (8. feladat) |
| [`tasks/numbers_and_text.txt`](tasks/numbers_and_text.txt) | Számok és szövegek vegyesen (9. feladat) |
| [`tasks/lines.txt`](tasks/lines.txt) | Négy sor a megfordításhoz (12. feladat) |
| [`tasks/patients_messy.txt`](tasks/patients_messy.txt) | „Piszkos” betegnyilvántartás: fejléc, szóközök, írásjelek, CRLF, hibás sor (13. feladat) |
| `tasks/palindromes.txt`, `word_lines.txt`, `story.txt`, `banned_words.txt`, `numbers_digits.txt`, `text.txt`, `visits.txt` | A [További gyakorlás](#további-gyakorlás) bemeneti fájljai |
| [`solutions/`](solutions/) | `1_numeric_lines.sh` … `13_most_common_illness_per_month.sh`: az órai feladatok megoldásai, kommentezve |
| [`exercise_6_solutions/`](exercise_6_solutions/) | A 6. heti gyakorló feladatok megoldásai, a hozzájuk tartozó adatfájlokkal |

A megoldásokat a `tasks` mappából futtassuk:

```bash
cd tasks
chmod +x ../solutions/*.sh
../solutions/1_numeric_lines.sh numbers_mixed.txt
```

> **Fontos:** Az 5. és a 12. feladat **magát a fájlt írja át**. Ezeket egy másolaton próbáljuk ki (`cp replace.txt test.txt`), különben a következő futtatáshoz a `git checkout tasks/replace.txt` paranccsal kell visszaállítani az eredetit. A `tasks` mappa fájljait szerkesztővel ne mentsük el, mert a szerkesztő „kijavíthatja” a szándékos hibákat (CRLF, hiányzó záró újsor).

> **Megjegyzés:** A scriptekben a magyarázatok kommentként szerepelnek, érdemes a fájlokat megnyitni és a leírással párhuzamosan olvasni. Az órán először **saját magunk** próbáljuk megoldani a feladatot, és csak utána nézzük meg a megoldást (vagy a videót).

---

## Rövid ismétlés és új alapok

### Az univerzális minta

Minden fájlt olvasó megoldás a 6. heti [univerzális mintából](../Exercise_6/Material_6.md#univerzális-minta-fájl-beolvasása-soronként) indul ki. Ezt másoljuk be, és csak a „feldolgozás” részt írjuk át:

```bash
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
| `IFS= read -r line` | A sor pontosan úgy kerül a változóba, ahogy a fájlban van. |
| `\|\| [ -n "$line" ]` | Az utolsó sor akkor sem vész el, ha utána nincs újsor (`numbers_mixed.txt`, `patients_messy.txt`). |
| `line=${line%$'\r'}` | Windows-os (CRLF) fájlnál a sor végén maradó `\r` levágása, különben a `$` horgony és a `==` nem illeszkedik. |
| `[ -z "$line" ]` + `continue` | Az üres sorok kihagyása. |
| `done < "$file"` | A ciklus a fájlból olvas; a ciklusban módosított változók (számláló, tömb) a ciklus után is megmaradnak. |

A mezőkre bontást ezen az órán **nem** az `IFS=',' read` formával a `while`-ban, hanem a ciklus belsejében végezzük, így a minta eleje mindig ugyanaz marad:

```bash
    IFS=',' read -r name date illness <<< "$line"      # a sor szétszedése a vesszőknél
    read -r word1 word2 rest <<< "$line"               # a sor szétszedése a szóközöknél
```

### Reguláris kifejezések a scriptben

A `[[ $line =~ minta ]]` szerkezet akkor igaz, ha a sor **illeszkedik** a mintára; a `!` tagadja: `[[ ! $line =~ minta ]]`. A 4. heti [táblázat](../Exercise_4/Material_4.md#reguláris-kifejezések) elemeiből ezen az órán ezeket használjuk:

| Minta | Jelentés | Hol? |
|---|---|---|
| `^` … `$` | A sor eleje és vége: a **teljes** sornak kell illeszkednie, nem csak egy részének | minden feladat |
| `[0-9]+` | Legalább egy számjegy | 8., 9., 10., 11. |
| `[0-9]{2}` | Pontosan két számjegy | 6. |
| `[0-9]{4}-[0-9]{2}-[0-9]{2}` | `ÉÉÉÉ-HH-NN` alakú dátum | 13. |
| `[+-]?` | Opcionális előjel (a `?` = 0 vagy 1 darab) | 1. |
| `[0-9]*\.?[0-9]+` | Tizedes tört: számjegyek, opcionális pont, legalább egy számjegy. A `\.` a pont karakter (a sima `.` bármit jelent) | 1. |
| `[[:alpha:]]`, `[[:space:]]` | POSIX karakterosztály: bármely betű, ill. szóköz/tab. Egy közös zárójelben: `[[:alpha:][:space:]]` | 2. |

```bash
if [[ $line =~ ^[+-]?[0-9]*\.?[0-9]+$ ]]; then      # 23, -12.2, +7, .5 igen; 33.3o, 12. nem
```

**Regex vagy glob minta?** Ha csak azt kell eldönteni, hogy egy szó **része-e** a sornak, nem kell regex: a `==` és `!=` a fájlneveknél megszokott helyettesítő karakteres (glob) mintát használja, ahol a `*` bármilyen szöveg:

```bash
if [[ $line == *"$word"* ]]; then       # a sor tartalmazza a szót
if [[ $line != *alma* && $line != *körte* ]]; then      # egyiket sem tartalmazza
```

A `$word` idézőjelben van, így a benne lévő speciális karakterek is betű szerint illeszkednek.

**Ugyanez `grep`-pel:** minden ciklusos megoldásnak van egysoros, `grep`-es változata is, ezeket a scriptek végén kommentben megtaláljuk. A ciklus előnye, hogy soronként bármilyen további feldolgozást hozzá tudunk írni.

| Ciklussal | `grep`-pel |
|---|---|
| `[[ $line =~ minta ]]` + `echo` | `grep -E 'minta' file` |
| `[[ ! $line =~ minta ]]` + `echo` | `grep -v -E 'minta' file` |
| `[[ $line =~ minta ]]` + számláló | `grep -c -E 'minta' file` |
| `[[ $line != *"$word"* ]]` + `echo` | `grep -v "$word" file` |

### Szövegműveletek

A 4. hétről ismert [szövegműveletek](../Exercise_4/Material_4.md#szövegműveletek), amelyekre ezen az órán szükség van:

| Művelet | Jelentés | Példa (`s="1234"`) |
|---|---|---|
| `${#s}` | A szöveg hossza | `4` |
| `${s:i:1}` | Az `i`-edik karakter (0-tól számozva) | `${s:0:1}` → `1`, `${s:3:1}` → `4` |
| `${s//a/b}` | Minden `a` cseréje `b`-re (egy `/`: csak az első) | `${s//1/X}` → `X234` |
| `${s%$'\r'}` | A záró `\r` levágása | |
| `${key%%:*}` | A **kettőspont előtti** rész (a leghosszabb `:*` végződés levágva) | `10:fejfájás` → `10` |
| `${key#*:}` | A **kettőspont utáni** rész (a legrövidebb `*:` kezdet levágva) | `10:fejfájás` → `fejfájás` |

Egy szám **számjegyeinek bejárása** a hossz és a karakterkivágás összerakása (10. és 11. feladat):

```bash
for (( i=0; i<${#number}; i++ )); do
    digit=${number:i:1}
    sum=$(( sum + digit ))
done
```

Hátulról előre ugyanez: `for (( i=${#number}-1; i>=0; i-- ))`. Így fordítunk meg egy szöveget külön parancs nélkül.

A `tr` paranccsal (5. és 6. hét) egész karakterosztályokat törlünk vagy cserélünk:

| Parancs | Hatás |
|---|---|
| `tr -d '[:space:]'` | Minden szóköz, tab és `\r` törlése (pl. egy számból) |
| `tr -d '[:punct:]'` | Az írásjelek (`. , ! ? ;` …) törlése (pl. a `fejfájás.` végéről) |
| `tr '[:upper:]' '[:lower:]'` | Kisbetűsítés (az ékezet nélküli betűkre biztosan működik) |
| `sed 's/^[[:space:]]*//; s/[[:space:]]*$//'` | Csak a sor **eleji és végi** szóközök levágása, a belső szóközök megmaradnak (`  Molnár Hanna ` → `Molnár Hanna`) |

A **sed** csere parancsát a 4. héten láttuk: `s/minta/csere/g`, ahol a `g` miatt a sor minden előfordulása cserélődik. Egy egész fájlban így cserélünk ki egy szót (5. feladat):

```bash
sed "s/$old/$new/g" "$file" > "$file.tmp"
mv "$file.tmp" "$file"
```

> **Fontos:** Ugyanabba a fájlba nem írhatunk, amelyből olvasunk: a `>` már a parancs indulása előtt kiüríti a fájlt. Ezért ideiglenes fájlba írunk, és `mv`-vel felülírjuk vele az eredetit (5. hét, 4. feladat). Ugyanez igaz a `while read` ciklusra is: `done < "$file" > "$file.tmp"`, majd `mv`.

### Tömbök

Az 5. hétről ismert tömbök (12. feladat, és a további gyakorlás több feladata):

| Művelet | Jelentés |
|---|---|
| `lines=()` | Üres tömb |
| `lines+=("$line")` | Új elem a tömb végére |
| `${#lines[@]}` | Az elemek száma |
| `${lines[i]}` | Az `i`-edik elem (0-tól) |
| `"${lines[@]}"` | Az összes elem, külön-külön |
| `read -r -a words <<< "$line"` | A sor szavai egy tömbbe |

Egy tömb bejárása **hátulról előre**: az utolsó elem indexe `${#lines[@]}-1`.

```bash
for (( i=${#lines[@]}-1; i>=0; i-- )); do
    echo "${lines[i]}"
done
```

### Kulcs-érték tároló: asszociatív tömb

**Új elem.** A sima tömb indexe csak szám lehet. Az **asszociatív tömb** (más nyelvekben: map, dictionary, hash) kulcsa tetszőleges szöveg, és egy kulcshoz egy érték tartozik. Darabszámok gyűjtésére ideális: a kulcs az, **amit** számolunk, az érték a **darabszám**.

```bash
declare -A counts                   # létrehozás (a -A kötelező!)

counts["alma"]=3                    # érték beállítása
counts["alma"]=$(( ${counts["alma"]:-0} + 1 ))     # növelés; ha a kulcs még nincs, 0-ról indul

echo "${counts["alma"]}"            # egy érték:        4
echo "${!counts[@]}"                # az összes KULCS (a ! miatt), sorrend nélkül
echo "${#counts[@]}"                # a kulcsok száma
```

Szavak gyakorisága egy tömbből:

```bash
declare -A counts
words=("alma" "körte" "alma" "szilva" "körte" "alma")

for word in "${words[@]}"; do
    counts["$word"]=$(( ${counts["$word"]:-0} + 1 ))
done

for word in "${!counts[@]}"; do
    echo "$word: ${counts["$word"]}"
done
```

```text
szilva: 1
körte: 2
alma: 3
```

**Maximumkeresés** a tárolón: végigmegyünk a kulcsokon, és megjegyezzük, melyiknél volt eddig a legnagyobb érték.

```bash
max_count=0
max_word=""

for word in "${!counts[@]}"; do
    if [ "${counts["$word"]}" -gt "$max_count" ]; then
        max_count=${counts["$word"]}
        max_word=$word
    fi
done

echo "Most common: $max_word ($max_count)"
```

**Összetett kulcs.** Ha két dolog szerint kell számolni (pl. hónap **és** betegség), a kulcsot összefűzzük egy elválasztóval: `key="$month:$illness"`. Később a `${key%%:*}` és a `${key#*:}` szedi szét. Ezt használja a 13. feladat.

> **Megjegyzés:** Az asszociatív tömb a bash 4-es verziójától létezik, a szamrend szerveren, Linuxon és a Git Bash-ben megvan. A kulcsok bejárási sorrendje nincs meghatározva: ha rendezett kimenet kell, a kulcsokat a `sort` parancson átvezetve járjuk be (lásd a 13. feladatot).

---

## Az előző óra gyakorló feladatainak megoldása

A megoldások az [`exercise_6_solutions/`](exercise_6_solutions/) mappában vannak, kommentekkel. Ebből a mappából futtassuk őket, mert az itteni adatfájlokkal dolgoznak. Mindegyik a 6. heti univerzális mintával olvas, és a 6. heti csapdákkal (CRLF, üres sorok, hiányzó záró újsor, szóközök) is megbirkózik.

| Feladat | Megoldás | A lényeg |
|---|---|---|
| 1. Sorok számozása | [`1_number_lines.sh`](exercise_6_solutions/1_number_lines.sh) | Az üres sor **nem** `continue`, hanem üres sor a kimenetbe, sorszám nélkül; az újsor nélküli utolsó sor is sorszámot kap |
| 2. Raktárkészlet értéke | [`2_inventory_value.sh`](exercise_6_solutions/2_inventory_value.sh) | `IFS=';' read`, fejléc kihagyása, `tr -d '[:space:]'` a számokon, hibás sorok külön fájlba sorszámmal; eredmény `18840`, 2 hibás sor |
| 3. Naplófájl szétválogatása | [`3_split_log.sh`](exercise_6_solutions/3_split_log.sh) | `read -r date time level message <<< "$line"`, `case` a szintre, három kimeneti fájl kiürítése a ciklus előtt; 5 INFO, 2 WARNING, 2 ERROR |
| 4. Két fájl összefésülése | [`4_merge_files.sh`](exercise_6_solutions/4_merge_files.sh) | Két tömb, a hosszabb hosszáig indexes `for`; a hiányzó elem üres szöveg |
| 5. Telefonregiszter bővítése | [`5_phone_registry_extended.sh`](exercise_6_solutions/5_phone_registry_extended.sh) | `-e`: soronkénti átírás ideiglenes fájlba; `-i`: importálás, hibás sor és meglévő név `continue`-val (nem `exit`); 2 új név |

```bash
cd exercise_6_solutions
./2_inventory_value.sh inventory.txt
cat inventory_report.txt
```

```text
4 product(s) written to 'inventory_report.txt', total value: 18840
2 invalid line(s) written to 'errors.txt'
alma;2500
körte;1520
banán;2940
szőlő;11880
Total: 18840
```

> **Tipp:** Az 5. feladat scriptje módosítja a `phone_registry.txt` fájlt. Az eredeti állapot a `git checkout phone_registry.txt` paranccsal állítható vissza.

---

## Az óra feladatai

Az 1–12. feladat a gyakorlat hivatalos feladatsora ([`Officia_Doc.pdf`](Officia_Doc.pdf)), a 13. a kulcs-érték tárolót gyakoroltatja. A feladatok megoldását a [videón](https://youtu.be/PnZwul4jvLc) is végigkövethetjük.

| Feladat | Fő elem | Mit gyakorlunk? |
|---|---|---|
| 1–2. | Regex `=~` | Számok és betűs sorok felismerése, számlálás |
| 3–4. | Glob minta `*"$word"*` | Sorok szűrése szó alapján, fájlba írás |
| 5. | `sed s/…/…/g` | Csere a fájl minden sorában, ideiglenes fájl + `mv` |
| 6., 10., 11. | `${s:i:1}`, `${#s}` | Számjegyek bejárása, megfordítás, összegzés |
| 7. | `read … <<<` | Sor szavakra bontása |
| 8–9. | Regex + számláló / fájlba írás | Számok összegzése, hibás sorok kezelése |
| 12. | Tömb | Sorok tárolása, bejárás hátulról |
| 13. | Asszociatív tömb | Számlálás kulcs szerint, maximumkeresés, piszkos adat tisztítása |

**Minden feladatra érvényes:** a script ellenőrizze a paraméterek számát és a fájl létezését; a hibaüzenetek a standard errorra menjenek (`>&2`), és a script `exit 1`-gyel álljon le. A fájlokat az univerzális mintával olvassuk.

### 1. Csak számot tartalmazó sorok

Megoldás: [`1_numeric_lines.sh`](solutions/1_numeric_lines.sh)

Készítsünk scriptet, amelyik a paraméterében megadott fájlból a csak számokat tartalmazó sorokat írja ki! Valós számokra (tizedes tört, előjel) is gondoljunk.

```bash
../solutions/1_numeric_lines.sh numbers_mixed.txt
```

```text
23
11
12.2
-12.2
```

Amit használunk: `=~`, `^[+-]?[0-9]*\.?[0-9]+$`.

> **Tipp:** A `33.3o` és az `asd2` azért esik ki, mert a `^` és a `$` miatt a **teljes** sornak kell számnak lennie. A `-12.2` az utolsó sor, utána nincs újsor: a `|| [ -n "$line" ]` nélkül nem jelenne meg.

### 2. Csak betűket tartalmazó sorok száma

Megoldás: [`2_count_letter_lines.sh`](solutions/2_count_letter_lines.sh)

Készítsünk scriptet, amelyik megszámolja, hány csak betűket tartalmazó sor van a fájlban!

```bash
../solutions/2_count_letter_lines.sh letters.txt
```

```text
There are 2 lines in the file that contain only letters.
```

Amit használunk: `[[:alpha:][:space:]]`, számláló.

> **Tipp:** Az `asd3asd` nem számít, mert van benne számjegy. Egy sorban: `grep -c -E '^[[:alpha:][:space:]]+$' letters.txt`.

### 3. Szót tartalmazó sorok kihagyása másoláskor

Megoldás: [`3_copy_without_word.sh`](solutions/3_copy_without_word.sh)

Készítsünk scriptet, amelyik egy adott (paraméterként megadott) szót tartalmazó sorokat **nem** másolja át egy másik fájlba! Ha a célfájl nem létezik, hozzuk létre.

```bash
../solutions/3_copy_without_word.sh sentences.txt filtered.txt harmadik
cat filtered.txt
```

```text
Destination file 'filtered.txt' does not exist, creating it.
Lines not containing 'harmadik' copied to 'filtered.txt'.
ez egy mondat
ez egy másik mondat
valami
```

Amit használunk: `[[ $line != *"$word"* ]]`, `> file` kiürítés a ciklus előtt, `>>` a ciklusban.

> **Tipp:** A célfájlt a ciklus előtt `>`-rel ürítjük ki: enélkül a második futtatás az első eredmény végére írna. Egy sorban: `grep -v harmadik sentences.txt > filtered.txt`.

### 4. Több szó kizárása

Megoldás: [`4_exclude_words.sh`](solutions/4_exclude_words.sh)

Készítsünk scriptet, amelyik a paraméterében megadott fájlból csak azokat a sorokat írja ki, amelyekben sem az `alma`, sem a `körte` szó nem szerepel, továbbá a (paraméterben) megadott szó sem!

```bash
../solutions/4_exclude_words.sh fruits.txt asd
```

```text
masik mondat
utolso mondat
```

Amit használunk: három `!=` feltétel `&&`-del összekötve.

### 5. Szó cseréje a fájlban

Megoldás: [`5_replace_word.sh`](solutions/5_replace_word.sh)

Cseréljük ki egy fájlban szereplő minden (paraméterben megadott) szót egy másikra! Magát a fájlt módosítsuk.

```bash
cp replace.txt test.txt
../solutions/5_replace_word.sh test.txt alma barack
cat test.txt
```

```text
Word 'alma' replaced with 'barack' in 'test.txt'.
ez egy mondat barack szóval
ez egy mondat körte szóval
az barack egy gyümölcs
```

Amit használunk: `sed "s/$old/$new/g"` (4. hét), ideiglenes fájl, `mv`. Ez az egyetlen órai feladat, amelyhez nem kell ciklus: a `sed` magától végigmegy a fájl sorain.

> **Tipp:** A `sed … "$file" > "$file"` **nem** működik (a `>` előbb kiüríti a fájlt): ezért ideiglenes fájl és `mv`. A `sed` részszót is cserél (az `almafa` is `barackfa` lenne); a script végén kommentben szerepel a szóhatáros (`\b`) és a ciklusos (`${line//…}`) változat is.

### 6. Kétjegyű számok megfordítása

Megoldás: [`6_reverse_two_digits.sh`](solutions/6_reverse_two_digits.sh)

Egy fájlban kétjegyű számok vannak. Írjuk ki fordított sorrendben a számjegyeket!

```bash
../solutions/6_reverse_two_digits.sh two_digit_numbers.txt
```

```text
21
12
65
09
```

Amit használunk: `^[0-9]{2}$`, `${number:1:1}${number:0:1}`.

> **Tipp:** Linuxon a `rev` parancs is megfordít egy szöveget (`echo 12 | rev`), de a Git Bash-ben nincs meg, ezért a részszöveg-kivágást használjuk, amely mindenhol működik.

### 7. Két szó sorrendjének megcserélése

Megoldás: [`7_swap_words.sh`](solutions/7_swap_words.sh)

Egy fájlban soronként két szó van. Cseréljük meg a szavak sorrendjét a sorokban!

```bash
../solutions/7_swap_words.sh word_pairs.txt
```

```text
asd2 asd1
asd4 asd3
ketto egy
```

Amit használunk: `read -r word1 word2 rest <<< "$line"`.

> **Tipp:** A `read` a szóközöknél bontja a sort, a sor maradéka az **utolsó** változóba kerül. Ezért van egy harmadik, nem használt `rest` változó: ha a sorban több szó lenne, az nem ragadna a `word2` végére.

### 8. Számok összeadása fájlból

Megoldás: [`8_sum_numbers.sh`](solutions/8_sum_numbers.sh)

Egy fájlban számokat találunk, soronként egyet-egyet. Adjuk össze ezeket! A nem szám sorokra figyelmeztessünk.

```bash
../solutions/8_sum_numbers.sh numbers.txt
```

```text
Warning: skipping invalid number: 'asd'
Sum of numbers in the file: 20
```

Amit használunk: `^[0-9]+$`, `sum=$(( sum + number ))`, `>&2`.

### 9. Nem csak számot tartalmazó sorok másolása

Megoldás: [`9_copy_non_numeric.sh`](solutions/9_copy_non_numeric.sh)

Egy fájlban számokat és szövegeket tárolunk vegyesen. A **nem csak számokat** tartalmazó sorokat másoljuk át egy új fájlba!

```bash
../solutions/9_copy_non_numeric.sh numbers_and_text.txt text_only.txt
cat text_only.txt
```

```text
Non-numeric lines copied to 'text_only.txt'.
asd
asd2
asd3
asd4
valami
```

Amit használunk: `[[ ! $line =~ ^[0-9]+$ ]]`, `>` és `>>`.

> **Tipp:** Ez a 1. feladat „fordítottja”: ugyanaz a minta, a `!` tagadással. Egy sorban: `grep -v -E '^[0-9]+$' numbers_and_text.txt > text_only.txt`.

### 10. Szám megfordítása

Megoldás: [`10_reverse_number.sh`](solutions/10_reverse_number.sh)

Írjunk programot, ami beolvas egy számot a bemenetről (`read`), majd kiírja azt fordítva!

```bash
../solutions/10_reverse_number.sh
```

```text
Enter a number: 1234
Reversed number: 4321
```

Amit használunk: `read -r -p`, `${#number}`, `${number:i:1}`, `for` hátulról előre, szöveg összefűzése.

> **Tipp:** A számot **szövegként** kezeljük: a karakterein hátulról előre lépkedünk, és egy új szöveghez fűzzük őket. Az `1200` megfordítva `0021` lesz. A hivatalos feladatsor aritmetikai megoldása (`% 10` és `/ 10`) a script végén kommentben szerepel.

### 11. Számjegyek összege

Megoldás: [`11_digit_sum.sh`](solutions/11_digit_sum.sh)

Írjunk programot, ami beolvas egy számot a bemenetről, majd kiírja a számjegyek összegét!

```bash
echo 1234 | ../solutions/11_digit_sum.sh
```

```text
Enter a number: Sum of digits: 10
```

Amit használunk: `for (( i=0; i<${#number}; i++ ))`, `${number:i:1}`, `$(( ))`.

### 12. Fájl sorainak megfordítása

Megoldás: [`12_reverse_lines.sh`](solutions/12_reverse_lines.sh)

Írjunk programot, ami megfordítja soronként a paraméterben megadott fájl tartalmát (az utolsó sor lesz az első)! Átmeneti tárolásra egy tömböt használjunk.

```bash
cp lines.txt test.txt
../solutions/12_reverse_lines.sh test.txt
cat test.txt
```

```text
Lines in the file 'test.txt' have been reversed.
asd4
asd3
asd2
asd
```

Amit használunk: `lines+=("$line")`, `${#lines[@]}`, `for (( i=${#lines[@]}-1; i>=0; i-- ))`, `printf '%s\n' "${arr[@]}" > "$file"`.

> **Tipp:** A fájlba csak akkor írhatunk vissza, amikor már **az összes sort beolvastuk** a tömbbe. Az utolsó elem indexe `${#lines[@]}-1`, mert az indexelés 0-tól indul.

### 13. Havonta a leggyakoribb betegség (kulcs-érték tárolóval)

Megoldás: [`13_most_common_illness_per_month.sh`](solutions/13_most_common_illness_per_month.sh)

A `patients_messy.txt` egy sora `Név, ÉÉÉÉ-HH-NN, betegség` alakú, de a fájl „piszkos”: az első sor fejléc, a vesszők körül szóközök vannak, a betegség végén néha írásjel (`fejfájás.`, `fejfájás!`, `megfázás,`), a kis- és nagybetű keveredik (`Fejfájás`), van üres és hibás sor (`Hibás Sor`), a sorvégek Windows-osak, és az utolsó sor után nincs újsor. Írjunk scriptet, amely **minden hónapra** kiírja a leggyakoribb betegséget és a betegek számát! A hibás sorokra figyelmeztessünk.

```bash
../solutions/13_most_common_illness_per_month.sh patients_messy.txt
```

```text
Warning: invalid line skipped: 'Név, Dátum, Betegség'
Warning: invalid line skipped: 'Hibás Sor'
Month 05: lábfájás (3 patient(s))
Month 09: gyomorpanaszok (2 patient(s))
Month 10: fejfájás (3 patient(s))
Month 11: megfázás (3 patient(s))
```

Amit használunk: `declare -A`, `IFS=',' read … <<<`, `tr -d '[:space:][:punct:]'` (szóközök és írásjelek törlése), `tr '[:upper:]' '[:lower:]'`, `${date:5:2}`, összetett kulcs `"$month:$illness"`, `${counts[$key]:-0}`, `"${!counts[@]}"`, `${key%%:*}`, `${key#*:}`, maximumkeresés, `sort`.

A megoldás három lépése:

1. **Tisztítás és számlálás.** Minden érvényes sorból a `hónap:betegség` kulcs darabszámát növeljük. A fejléc és a `Hibás Sor` a dátum ellenőrzésén (`^[0-9]{4}-[0-9]{2}-[0-9]{2}$`) bukik el.
2. **Maximumkeresés hónaponként.** Végigmegyünk a kulcsokon, szétszedjük hónapra és betegségre, és két másik asszociatív tömbben (`max_count[hónap]`, `max_illness[hónap]`) megjegyezzük a hónap eddigi legnagyobb értékét.
3. **Rendezett kiírás.** A kulcsok sorrendje véletlenszerű, ezért a hónapokat a `sort`-on átvezetve járjuk be.

> **Tipp:** A tisztítás nélkül a `fejfájás`, a `fejfájás.` és a `Fejfájás` **három különböző kulcs** lenne, és a 10. hónapban mindegyik csak 1-et számolna. Mindig nézzük meg a nyers adatot (`cat -A`), mielőtt számolni kezdünk vele!

> **Tipp:** Ugyanez a feladat az 5. héten `grep | cut | sort | uniq -c | sort -rn | head -n 1` csővezetékkel szerepelt egy hónapra. Az asszociatív tömbbel egy menetben, minden hónapra megkapjuk az eredményt, és a tisztítást is soronként elvégezhetjük.

---

## Gyakori hibák

| Hibás | Helyes | Magyarázat |
|---|---|---|
| `[[ $line =~ [0-9]+ ]]` | `[[ $line =~ ^[0-9]+$ ]]` | Horgonyok nélkül az `asd2` is illeszkedik, mert van benne számjegy. |
| `[[ $line =~ "^[0-9]+$" ]]` | `[[ $line =~ ^[0-9]+$ ]]` | Idézőjelben a minta **szó szerinti** szöveg lesz, nem regex. |
| `[[ $line == "$word" ]]` a „tartalmazza” vizsgálatra | `[[ $line == *"$word"* ]]` | A `*` nélkül csak a pontosan egyező sorra igaz. |
| `[[ $line =~ ^[0-9]+$ ]]` Windows-os fájlon | előtte `line=${line%$'\r'}` | A sor végén ott a láthatatlan `\r`, a `$` nem illeszkedik. |
| `sed … "$file" > "$file"` | `sed … "$file" > "$file.tmp" && mv "$file.tmp" "$file"` | A `>` már a `sed` indulása előtt kiüríti a fájlt. |
| `echo "$line" >> out.txt` kiürítés nélkül | a ciklus előtt `> out.txt` | A második futtatás az előző eredmény végére ír. |
| `for (( i=${#lines[@]}; i>=0; i-- ))` | `for (( i=${#lines[@]}-1; i>=0; i-- ))` | Az utolsó index elemszám−1; az első kör egy üres elemet adna. |
| `counts[$key]=$(( counts[$key] + 1 ))` `declare -A` nélkül | előtte `declare -A counts` | Enélkül sima (szám indexű) tömb lesz, és minden szöveges kulcs a 0 indexre kerül. |
| `for key in ${!counts[@]}` | `for key in "${!counts[@]}"` | Idézőjel nélkül a szóközt tartalmazó kulcs (`Kiss Lajos`) két részre esik. |
| `read -r number` után `${number:i:1}` ellenőrzés nélkül | előtte `[[ $number =~ ^[0-9]+$ ]]` | Betűt tartalmazó bemenetnél a `$(( sum + digit ))` hibát ad. |
| `echo "$x" \| rev` | `${x:i:1}` ciklussal | A `rev` nem minden rendszeren van meg (Git Bash). |

---

## További gyakorlás

A bemeneti fájlok a [`tasks/`](tasks/) mappában vannak, és tartalmazzák a 6. heti csapdákat (CRLF, hiányzó záró újsor, üres sorok, szóközök). Minden megoldás az univerzális mintából induljon.

1. **Palindromok.** Írjuk ki a [`palindromes.txt`](tasks/palindromes.txt) azon sorait, amelyek visszafelé olvasva ugyanazok. A szóközöket és a kis-/nagybetűt ne vegyük figyelembe (`a man a plan a canal panama`, `Never odd or even`). Segítség: `tr -d ' '`, `tr '[:upper:]' '[:lower:]'`, majd a 10. feladat megfordítása. Elvárt eredmény: 6 sor, az utolsó (`Never odd or even`) után nincs újsor.

2. **Szavak megfordítása soronként.** A 7. feladat általánosítása: a [`word_lines.txt`](tasks/word_lines.txt) minden sorában fordítsuk meg a szavak sorrendjét, akárhány szó van benne. Segítség: `read -r -a words <<< "$line"`, majd a tömb bejárása hátulról. Elvárt eredmény: `harom ketto egy`, `korte alma`, `e d c b a`, `csak`, `mondat. egy Ez`.

3. **Tiltott szavak cseréje.** A [`banned_words.txt`](tasks/banned_words.txt) soronként egy tiltott szót tartalmaz (Windows-os sorvégekkel!). A [`story.txt`](tasks/story.txt) minden sorában cseréljük ki a tiltott szavakat `***`-ra, az eredményt írjuk a `censored.txt`-be, és írjuk ki, hány sor változott. Segítség: a tiltott szavakat olvassuk egy tömbbe, majd soronként `${line//$word/***}` minden szóra. Elvárt eredmény: 3 sor változott (`titok` 2, `jelszó` 2, `pénz` 1 sorban szerepel). Ha a `\r`-t nem vágjuk le a tiltott szavakról, egyetlen csere sem történik!

4. **Számjegyek összege fájlból.** A [`numbers_digits.txt`](tasks/numbers_digits.txt) soronként egy számot tartalmaz (szóközökkel, hibás és üres sorokkal). Írjuk a `digit_sums.txt`-be minden érvényes számhoz `szám: számjegyek összege` alakban az összeget, a végére pedig a legnagyobb számjegyösszegű számot. A hibás sorokra figyelmeztessünk a sorszámukkal. Elvárt eredmény: 6 érvényes szám, 2 hibás sor (`abc`, `12a`), `Max: 99 (18)`.

5. **Leghosszabb sor és leghosszabb szó.** A [`text.txt`](tasks/text.txt) fájlról írjuk ki a leghosszabb sort és a leghosszabb szót, a hosszukkal együtt. Segítség: `${#line}`, `read -r -a words <<< "$line"`. Elvárt eredmény: a leghosszabb sor 59 karakteres, a leghosszabb szó `parancsbehelyettesites` (22).

6. **Szűrő kapcsolókkal.** Írjunk scriptet, amely a fájlt (1. paraméter) a kapcsoló szerint szűri: `-n` csak a számokat tartalmazó sorok, `-t` csak a szöveges sorok, `-w <szó>` a szót tartalmazó sorok. Ismeretlen kapcsolóra használati útmutató és `exit 1`. Az 1., a 9. és a 3. feladat megoldását használjuk újra függvényekben, `case`-zel (5. hét). Elvárt eredmény a `numbers_and_text.txt`-re: `-n` → 2 sor, `-t` → 5 sor, `-w asd` → 4 sor.

7. **A legtöbbször megjelent beteg (kulcs-érték tárolóval).** A [`visits.txt`](tasks/visits.txt) sorai `Név, megjelenések száma, utolsó dátum` alakúak; egy név **több sorban** is szerepelhet, ilyenkor a számok összeadódnak. Írjuk ki, ki járt a legtöbbször a rendelőben, és hányszor. Figyeljünk a szóközökre és a CRLF sorvégekre. Segítség: `declare -A visits`, `visits["$name"]=$(( ${visits["$name"]:-0} + count ))`, majd maximumkeresés. Elvárt eredmény: `Kiss Lajos - 12`.

---

## További anyagok

| Forrás | Leírás |
|---|---|
| https://youtu.be/PnZwul4jvLc | Videó: az 1–12. feladat megoldása lépésről lépésre |
| [`Officia_Doc.pdf`](Officia_Doc.pdf) | A gyakorlat hivatalos feladatsora, a `grep`/`sed`/`awk` egysoros megoldási ötleteivel |
| [`Material_6.md`](../Exercise_6/Material_6.md) | Az előző óra anyaga: fájlok olvasása és írása, az univerzális minta |
| [`Material_4.md`](../Exercise_4/Material_4.md#reguláris-kifejezések) | Reguláris kifejezések, szövegműveletek |
| https://regex101.com/ | Reguláris kifejezések kipróbálása, magyarázattal (a „PCRE” helyett a „POSIX ERE” módot érdemes nézni) |
| https://www.shellcheck.net/ | Shell scriptek automatikus ellenőrzése |
