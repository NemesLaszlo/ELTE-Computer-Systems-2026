# Shell scriptek – gyakorlás és összetett feladatok

Az előző órán megismertük a shell scriptek alapjait: változók, paraméterek, elágazások, ciklusok, függvények, reguláris kifejezések és átirányítás (lásd [`Material_4.md`](../Exercise_4/Material_4.md)). Ezen az órán ezeket **együtt** használjuk: a feladatok egymásra épülnek, és egyre több elemet kell bennük alkalmazni.

Az óra felépítése:

1. Rövid ismétlés és néhány új alap: bemenet beolvasása, hibakezelés, `case`, szűrők.
2. Az előző óra gyakorló feladatainak megoldása.
3. Az óra feladatai, részletes leírással és megoldással.

## Tartalom

1. [A mappa tartalma](#a-mappa-tartalma)
2. [Rövid ismétlés és új alapok](#rövid-ismétlés-és-új-alapok)
   - [Bemenet beolvasása: paraméterek és `read`](#bemenet-beolvasása-paraméterek-és-read)
   - [Hibakezelés](#hibakezelés)
   - [A `case` szerkezet](#a-case-szerkezet)
   - [Szűrők és csővezeték](#szűrők-és-csővezeték)
   - [Fájlok bejárása ciklussal](#fájlok-bejárása-ciklussal)
3. [Az előző óra gyakorló feladatainak megoldása](#az-előző-óra-gyakorló-feladatainak-megoldása)
4. [Az óra feladatai](#az-óra-feladatai)
5. [Gyakori hibák](#gyakori-hibák)
6. [További gyakorlás](#további-gyakorlás)

## A mappa tartalma

```text
Exercise_5/
├── Material_5.md             ez a leírás
├── exercise_4_solutions/     az előző óra gyakorló feladatainak megoldásai
├── tasks/                    az órai feladatok kiindulási fájljai (ezekkel dolgozunk)
└── solutions/                az órai feladatok megoldásai
```

| Mappa / fájl | Tartalom |
|---|---|
| [`exercise_4_solutions/`](exercise_4_solutions/) | `1_greeting.sh` … `7_sum_until_zero.sh` – a 4. heti gyakorló feladatok megoldásai, kommentezve; `numbers.txt` – tesztadat a 6. feladathoz |
| [`tasks/source.txt`](tasks/source.txt) | Tesztfájl a másoláshoz (1. feladat) |
| [`tasks/menu.txt`](tasks/menu.txt) | Étlap, soronként egy étel (2. és 9. feladat) |
| [`tasks/main_folder/`](tasks/main_folder/) | Könyvtár alkönyvtárral és néhány szöveges fájllal (3. és 7. feladat) |
| [`tasks/all_lower.txt`](tasks/all_lower.txt) | Csupa kisbetűs fájl (4. feladat) |
| [`tasks/patients.txt`](tasks/patients.txt) | Betegnyilvántartás: `Név,ÉÉÉÉ-HH-NN,betegség` soronként (6., 8. és 9. feladat) |
| [`solutions/`](solutions/) | `1_copy.sh` … `9_menu.sh` – az órai feladatok megoldásai, kommentezve |

### Futtatás

A megoldásokat a `tasks` mappából érdemes futtatni, mert a scriptek az ottani fájlokkal dolgoznak:

```bash
cd tasks
chmod +x ../solutions/*.sh
../solutions/2_search_word.sh menu.txt bor
```

> **Megjegyzés:** A scriptekben a magyarázatok kommentként szerepelnek, érdemes a fájlokat megnyitni és a leírással párhuzamosan olvasni. Az órán először **saját magunk** próbáljuk megoldani a feladatot, és csak utána nézzük meg a megoldást.

---

## Rövid ismétlés és új alapok

### Bemenet beolvasása: paraméterek és `read`

Egy script kétféleképpen kaphat adatot a felhasználótól:

| | Parancssori paraméter | `read` |
|---|---|---|
| Honnan jön az adat? | A script indításakor, a parancs után | Futás közben, a billentyűzetről |
| Példa | `./script.sh menu.txt bor` | `read -r -p "Word: " word` |
| Mikor használjuk? | Fájlnevek, kapcsolók, minden, amit automatikusan (más scriptből) is meg lehet adni | Interaktív program: menü, kérdés-válasz, jelszó |

**Paraméterek** – a script elején mentsük őket beszédes nevű változókba, a többi kód így olvashatóbb:

```bash
file=$1
word=$2
month=${3:-01}      # alapértelmezett érték, ha nincs 3. paraméter
```

Az összes paraméter bejárása (a `"$@"` minden paramétert külön elemként ad):

```bash
for arg in "$@"; do
    echo "Parameter: $arg"
done
```

**`read`** – egy sort olvas be. Szinte mindig a `-r` kapcsolóval használjuk, a `-p` a kérdést írja ki:

```bash
read -r -p "Enter a word: " word
```

A `read` nemcsak a billentyűzetről tud olvasni. A bemenete lehet fájl, egy másik parancs kimenete vagy egy változó tartalma:

```bash
# Fájl soronként (az előző óráról ismert forma)
while read -r line; do
    echo "Line: $line"
done < menu.txt

# Egy parancs kimenete soronként, csővezetéken keresztül
find main_folder -type f | while read -r file; do
    echo "File: $file"
done

# Egy változó tartalmának szétszedése: az első szó a count,
# a sor többi része az illness változóba kerül
result="      3 fejfájás"
read -r count illness <<< "$result"
echo "$count / $illness"         # 3 / fejfájás
```

| Forma | A `read` bemenete |
|---|---|
| `read -r var` | billentyűzet (standard input) |
| `… done < file` | a fájl sorai |
| `parancs \| while read -r var; do … done` | a parancs kimenetének sorai |
| `read -r a b <<< "$str"` | a változó tartalma (*here string*), szavanként az `a`, `b`, … változókba |

> **Megjegyzés:** Ha a `read` több változót kap, a sort szóközöknél szavakra bontja: az első szó az első változóba kerül, a második a másodikba, és **a sor maradéka az utolsóba**.

#### Mi az a `<<<`?

A `<<<` a **here string** operátor: a jobb oldalán álló szöveget adja a parancs standard inputjára, mintha az egy egysoros fájl lenne. Az átirányítások családjában a helye:

| Operátor | A bemenet forrása |
|---|---|
| `< file.txt` | egy fájl |
| `<< EOF … EOF` | a scriptbe beírt többsoros szövegblokk (*here document*) |
| `<<< "szöveg"` | egyetlen string vagy változó tartalma (*here string*) |

Így a következő két sor ugyanazt teszi, csak az egyik fájlból, a másik egy változóból olvas:

```bash
read -r count illness < file.txt          # az első sor a fájlból
read -r count illness <<< "$result"       # a változó tartalma
```

Kézenfekvő lenne a csővezeték is (`echo "$result" | read -r count illness`), de az **nem működik**: a bash a csővezeték jobb oldalát külön folyamatban (*subshell*) futtatja, így a `count` és az `illness` ott kap értéket, a script többi részében pedig üres marad. A `<<<` esetén a `read` az aktuális shellben fut, ezért a változók megmaradnak.

```bash
result="      3 fejfájás"

echo "$result" | read -r count illness
echo "$count / $illness"                  #  /            (üres – a subshell miatt)

read -r count illness <<< "$result"
echo "$count / $illness"                  # 3 / fejfájás
```

> **Megjegyzés:** A `<<<` a bash saját bővítése, a sima `sh` nem ismeri. A scriptjeink `#!/bin/bash` shebanggal indulnak, ezért nyugodtan használható.

### Hibakezelés

Az alapelv: **ellenőrizzünk a script elején, és hiba esetén azonnal álljunk le** – hibaüzenettel a standard erroron (`>&2`) és nem nulla kilépési kóddal (`exit 1`). Így a script későbbi része már feltételezheti, hogy minden rendben van.

| Mit ellenőrzünk? | Hogyan? |
|---|---|
| A paraméterek száma | `[ "$#" -ne 2 ]` |
| Üres érték | `[ -z "$var" ]` |
| A fájl létezik / olvasható / írható | `[ ! -f "$file" ]`, `[ ! -r "$file" ]`, `[ ! -w "$file" ]` |
| A könyvtár létezik | `[ ! -d "$dir" ]` |
| Az érték formátuma (pl. egész szám) | `[[ ! $n =~ ^[0-9]+$ ]]` |
| Egy parancs sikeres volt-e | `if cp "$a" "$b"; then …` vagy `if ! grep -q "$word" "$file"; then …` |

Egy tipikus script eleje:

```bash
#!/bin/bash

# A használati útmutató függvénybe kerül, mert több helyről is hívhatjuk.
usage() {
    echo "Usage: $0 <file> <word>"
}

if [ "$#" -ne 2 ]; then
    usage >&2           # a függvény teljes kimenete a standard errorra megy
    exit 1
fi

file=$1
word=$2

if [ ! -f "$file" ]; then
    echo "Error: file '$file' does not exist" >&2
    exit 1
fi

# ... innentől a tényleges munka ...
```

**Parancsok sikeressége** – az `if` nemcsak a `[ ]` feltételt, hanem bármely parancs kilépési kódját tudja vizsgálni: `0` = siker (igaz), minden más = hiba (hamis). Nem kell `$?`-t külön megnézni:

```bash
if cp "$source" "$target"; then
    echo "Copied"
else
    echo "Error: copy failed" >&2
    exit 1
fi
```

A `grep` kilépési kódja külön is hasznos: `0` = volt találat, `1` = nem volt találat, `2` = hiba (pl. nincs ilyen fájl). A `-q` (*quiet*) kapcsolóval nem ír ki semmit, csak a kódot adja:

```bash
if grep -q "$word" "$file"; then
    echo "Found"
fi
```

**A `read` is lehet sikertelen** – ha a felhasználó `Ctrl+D`-t nyom (vége a bemenetnek). Egy `while true` ciklusban ezt kezelni kell, különben a script soha nem áll le:

```bash
if ! read -r -p "Your choice: " choice; then
    break
fi
```

> **Javasolt gyakorlat:** Minden hibaüzenet a standard errorra (`>&2`) megy, minden eredmény a standard outputra. Így a script kimenete fájlba irányítva vagy csővezetékbe kötve is tiszta marad.

### A `case` szerkezet

Ha egy értéket **több konkrét lehetőséggel** hasonlítunk össze (kapcsolók, menüpontok), az `if … elif … elif …` lánc helyett a `case` olvashatóbb:

```bash
case "$1" in
    -d)
        date
        ;;
    -w)
        whoami
        ;;
    -l)
        ls -l "$HOME"
        ;;
    *)
        echo "Error: unknown option '$1'" >&2
        exit 1
        ;;
esac
```

| Elem | Jelentés |
|---|---|
| `case érték in` | Az összehasonlítandó érték (idézőjelben) |
| `minta)` | Egy ág kezdete: ha az érték illeszkedik a mintára, ez az ág fut le |
| `;;` | Az ág vége (**kötelező**, enélkül a következő ág is lefutna) |
| `*)` | Bármire illeszkedik – az „egyéb” ág, ezért mindig **utolsónak** írjuk |
| `esac` | A szerkezet vége (`case` visszafelé) |

A minták a fájlneveknél megszokott **helyettesítő karaktereket** (globbing) használják, nem reguláris kifejezéseket:

| Minta | Illeszkedik |
|---|---|
| `-d)` | pontosan a `-d` szövegre |
| `-d\|--date)` | a `-d` **vagy** a `--date` szövegre |
| `[0-9])` | egyetlen számjegyre |
| `*.txt)` | bármire, ami `.txt`-re végződik |
| `*)` | bármire |

A rövid ágakat egy sorba is írhatjuk: `1) show_date ;;`

> **Fontos:** A `case` felülről lefelé vizsgálja a mintákat, és az **első** illeszkedő ág fut le. Ha a `*)` ágat előre tennénk, mindig az futna.

### Szűrők és csővezeték

Egy **szűrő** olyan parancs, amely a standard inputról olvas, és az eredményt a standard outputra írja. Csővezetékkel (`|`) egymás után köthetők: az egyik kimenete a másik bemenete lesz. Az előző hetekről ismert `grep`, `sort`, `tr` és `wc` mellett ezen az órán ezeket használjuk:

| Parancs | Hatás | Példa |
|---|---|---|
| `cut -d ',' -f 3` | A sorokat a megadott elválasztónál (`-d`) mezőkre vágja, és a kért mezőt (`-f`) adja vissza | `cut -d ',' -f 1 patients.txt` → a nevek |
| `sort` | Rendezés (szövegesen) | |
| `sort -n` | Rendezés szám szerint | |
| `sort -r` | Fordított sorrend | `sort -rn` → számok csökkenő sorrendben |
| `sort -u` | Rendezés + az ismétlődő sorokból csak egyet tart meg (*unique*) | |
| `uniq -c` | Az **egymás után** ismétlődő sorokat összevonja, és eléjük írja a darabszámot | |
| `head -n 1` | Csak az első `n` sor | |
| `tail -n 1` | Csak az utolsó `n` sor | |
| `wc -l` | A sorok száma | |

A `grep` ezen az órán használt kapcsolói:

| Kapcsoló | Jelentés |
|---|---|
| `-i` | Nem különbözteti meg a kis- és nagybetűket |
| `-w` | Csak egész szóra illeszkedik (`bor` igen, `borsó` nem) |
| `-c` | A találatok helyett az illeszkedő sorok számát írja ki |
| `-q` | Nem ír ki semmit, csak a kilépési kódjával jelez (`if` feltételben) |
| `-r` | Rekurzívan, egy könyvtár összes fájljában (alkönyvtárakban is) keres |
| `-l` | A találati sorok helyett a fájlok nevét írja ki |

**A klasszikus „leggyakoribb elem” csővezeték** – lépésről lépésre a `patients.txt` fájlon:

```bash
cut -d ',' -f 3 patients.txt
```

```text
fejfájás
fejfájás
fejfájás
megfázás
megfázás
gyomorpanaszok
...
```

```bash
cut -d ',' -f 3 patients.txt | sort | uniq -c
```

```text
   6 fejfájás
   1 gyomorpanaszok
   3 lábfájás
   4 megfázás
```

```bash
cut -d ',' -f 3 patients.txt | sort | uniq -c | sort -rn | head -n 1
```

```text
   6 fejfájás
```

> **Fontos:** A `uniq` csak az **egymás után** álló azonos sorokat vonja össze, ezért előtte mindig `sort` kell. `sort` nélkül a `fejfájás` háromszor is szerepelne a listában.

> **Megjegyzés:** A `tr '[:lower:]' '[:upper:]'` csak az ékezet nélküli betűket alakítja át, az `á`, `é` stb. változatlan marad.

### Fájlok bejárása ciklussal

Egy könyvtár fájljait a `for` ciklus és a `*` helyettesítő karakter segítségével járjuk be:

```bash
for file in "$dir"/*.txt; do
    if [ ! -f "$file" ]; then
        continue
    fi
    echo "$file"
done
```

> **Fontos:** Ha a mintára egyetlen fájl sem illeszkedik, a bash **nem üres listát** ad, hanem a mintát **szó szerint** (pl. `main_folder/*.txt`) teszi a `file` változóba. Ezért kell a ciklus elején az `-f` vizsgálat.

A `*` csak a megadott könyvtárban keres, az alkönyvtárakba nem megy bele. Ha azokra is szükség van, a `find` parancsot kötjük csővezetékkel egy `while read` ciklushoz:

```bash
find "$dir" -type f | while read -r file; do
    echo "$file"
done
```

Két további parancs, amely a fájlnevek összeállításánál hasznos:

| Parancs | Hatás | Példa |
|---|---|---|
| `basename útvonal` | Az útvonal utolsó tagja | `basename a/b/main_folder` → `main_folder` |
| `date +%F` | A mai dátum `ÉÉÉÉ-HH-NN` formában | `backup_$(date +%F)` → `backup_2026-10-07` |

---

## Az előző óra gyakorló feladatainak megoldása

A megoldások az [`exercise_4_solutions/`](exercise_4_solutions/) mappában találhatók, részletes kommentekkel. Itt csak a lényeget emeljük ki.

### 1. Köszöntés

Fájl: [`1_greeting.sh`](exercise_4_solutions/1_greeting.sh)

> Paraméterként egy nevet vár, és köszönti az illetőt. Ha nem kap paramétert, a bejelentkezett felhasználó nevét használja.

A kulcs az alapértelmezett érték: `${1:-$USER}` – ha van első paraméter, azt adja, különben a `USER` környezeti változó értékét. Nem kell hozzá `if`.

```bash
name=${1:-$USER}
echo "Hello $name!"
```

```bash
./1_greeting.sh Laszlo      # Hello Laszlo!
./1_greeting.sh             # Hello <felhasználónév>!
```

### 2. Számológép

Fájl: [`2_calculator.sh`](exercise_4_solutions/2_calculator.sh)

> Két számot vár paraméterként, és kiírja az összegüket, különbségüket és szorzatukat. Hibás paraméterszám esetén használati útmutatót ír ki.

Két ellenőrzés: a paraméterek száma (`$# -ne 2`) és az, hogy mindkettő egész szám-e (reguláris kifejezés, opcionális előjellel). A számolás a `$(( ))` aritmetikai kifejezéssel történik.

```bash
if [[ ! $a =~ ^[+-]?[0-9]+$ || ! $b =~ ^[+-]?[0-9]+$ ]]; then
    echo "Error: both parameters must be integers" >&2
    exit 1
fi

echo "Sum:        $(( a + b ))"
```

```bash
./2_calculator.sh 7 3
```

```text
Sum:        10
Difference: 4
Product:    21
```

### 3. Fájl, könyvtár vagy nem létezik?

Fájl: [`3_path_type.sh`](exercise_4_solutions/3_path_type.sh)

> A paraméterként kapott útvonalról eldönti, hogy fájl, könyvtár, vagy nem létezik.

Az `-f`, `-d` és `-e` vizsgálatok `if … elif … else` láncban. A **sorrend számít**: az `-e` (létezik) fájlra és könyvtárra is igaz, ezért a konkrétabb `-f` és `-d` kerül előre.

```bash
if [ -f "$path" ]; then
    echo "'$path' is a file"
elif [ -d "$path" ]; then
    echo "'$path' is a directory"
else
    echo "'$path' does not exist"
fi
```

### 4. Páros számok

Fájl: [`4_even_numbers.sh`](exercise_4_solutions/4_even_numbers.sh)

> Kiírja 1-től a paraméterként kapott számig a páros számokat.

Két megoldás is van a fájlban: az egyik minden számon végigmegy, és a `(( i % 2 == 0 ))` feltétellel szűr; a másik 2-től indul, és kettesével lép (`i+=2`), így feltétel sem kell.

```bash
for (( i=2; i<=n; i+=2 )); do
    echo -n "$i "
done
```

```bash
./4_even_numbers.sh 10      # 2 4 6 8 10
```

### 5. Faktoriális függvénnyel

Fájl: [`5_factorial.sh`](exercise_4_solutions/5_factorial.sh)

> Függvény, amely a paraméterként kapott szám faktoriálisát számolja ki, majd meghívjuk a script első paraméterével.

A függvény az eredményt `echo`-val adja vissza, a hívó a `$( )` parancsbehelyettesítéssel menti el. A `local` változók csak a függvényen belül léteznek.

```bash
Factorial() {
    local n=$1
    local result=1
    local i
    for (( i=2; i<=n; i++ )); do
        result=$(( result * i ))
    done
    echo "$result"
}

result=$(Factorial "$1")
echo "$1! = $result"
```

```bash
./5_factorial.sh 5          # 5! = 120
```

> **Megjegyzés:** A bash 64 bites egész számokkal dolgozik, ezért a `20!` a legnagyobb, amit még helyesen kiszámol.

### 6. Negatív egész számok

Fájl: [`6_negative_numbers.sh`](exercise_4_solutions/6_negative_numbers.sh), tesztadat: [`numbers.txt`](exercise_4_solutions/numbers.txt)

> Reguláris kifejezés, amely csak a negatív egész számokat tartalmazó sorokra illeszkedik.

```bash
grep -E '^-[0-9]+$' "$file"
```

| Rész | Jelentés |
|---|---|
| `^` | A sor eleje |
| `-` | Kötelező mínuszjel |
| `[0-9]+` | Legalább egy számjegy |
| `$` | A sor vége – nem jöhet utána semmi, így a `-13.321` tizedes tört nem illeszkedik |

```bash
./6_negative_numbers.sh
```

```text
Negative integers in numbers.txt:
-7
-42
-100
Count: 3
```

### 7. Számok összegzése 0-ig

Fájl: [`7_sum_until_zero.sh`](exercise_4_solutions/7_sum_until_zero.sh)

> Addig kér be számokat a felhasználótól, amíg `0`-t nem ad meg, majd kiírja az összegüket.

`while true` végtelen ciklus, amelyből `break` utasítással lépünk ki, ha a szám `0`. A hibás (nem szám) bemenetet a `continue` ugorja át. A `Ctrl+D` esetét is kezeljük: ha a `read` sikertelen, kilépünk.

```bash
while true; do
    if ! read -r -p "Enter a number (0 to finish): " number; then
        break
    fi
    if [[ ! $number =~ ^[+-]?[0-9]+$ ]]; then
        echo "Error: '$number' is not an integer, try again" >&2
        continue
    fi
    if (( number == 0 )); then
        break
    fi
    sum=$(( sum + number ))
done
```

---

## Az óra feladatai

A feladatok egymásra épülnek:

| Feladat | Fő elem | Mit gyakorlunk? |
|---|---|---|
| 1–4. | Egy-egy parancs (`cp`, `grep`, `find`, `tr`) scriptbe csomagolva | Paraméterek, ellenőrzés, hibaüzenet, kilépési kód |
| 5. | `case` | Kapcsolók feldolgozása, használati útmutató |
| 6. | Csővezeték | `cut`, `sort`, `uniq`, `head`, reguláris kifejezés változóval |
| 7. | Ciklus fájlokon | `for`, `cp`, `mkdir`, számláló, `date`, `basename` |
| 8. | Függvények + `case` | Az 5. és 6. feladat ötvözése, lekérdezések |
| 9. | Interaktív menü | `while` + `read` + `case` + függvények – minden együtt |

**Minden feladatra érvényes:**

- A script ellenőrizze a paraméterek számát, és hiba esetén írjon ki használati útmutatót (`Usage: …`).
- A hibaüzenetek a standard errorra menjenek (`>&2`), és a script nem nulla kilépési kóddal (`exit 1`) álljon le.
- A nem létező fájlt / könyvtárat is kezeljük hibaként.
- A változókat idézőjelben használjuk (`"$file"`).

A tesztfájlok a [`tasks/`](tasks/) mappában találhatók, a megoldások a [`solutions/`](solutions/) mappában.

### 1. Fájl másolása

Megoldás: [`1_copy.sh`](solutions/1_copy.sh)

Írjunk scriptet, amely két parancssori paramétert vár: egy forrásfájl és egy célfájl nevét. A script a forrásfájl tartalmát másolja át a célfájlba. Ha a célfájl nem létezik, a script hozza létre, és erről tájékoztassa a felhasználót. (Lényegében egy „burkoló” a `cp` parancs felett, hibakezeléssel.)

- Ha a forrásfájl nem létezik vagy nem olvasható, a script hibaüzenettel álljon le.
- A másolás sikerességét a `cp` kilépési kódja alapján döntsük el.

```bash
../solutions/1_copy.sh source.txt target.txt
```

```text
Destination file 'target.txt' does not exist, creating it.
Content copied from 'source.txt' to 'target.txt'.
```

```bash
../solutions/1_copy.sh nope.txt target.txt
```

```text
Error: source file 'nope.txt' does not exist
```

Amit használunk: `$#`, `-f`, `-r`, `-e`, `touch`, `cp`, `if parancs; then`, `>&2`, `exit`.

> **Tipp:** Az `if cp "$source" "$target"; then …` forma közvetlenül a `cp` sikerességét vizsgálja.

### 2. Sorok keresése egy fájlban

Megoldás: [`2_search_word.sh`](solutions/2_search_word.sh)

Írjunk scriptet, amely két paramétert vár: egy fájlnevet és egy szót. A script írja ki a fájl azon sorait, amelyek tartalmazzák a szót. A `menu.txt` fájlban a `bor` szóra keresve a `Bor` és a `bor` is találat legyen.

- Ha egyetlen sor sem tartalmazza a szót, erről a script üzenetben tájékoztasson, és nem nulla kóddal lépjen ki.

```bash
../solutions/2_search_word.sh menu.txt bor
```

```text
Saláta Bor
Tészta bor
Ponty Bor
```

```bash
../solutions/2_search_word.sh menu.txt sajt
```

```text
No line contains the word 'sajt'.
```

Amit használunk: `grep -i`, `grep -w`, a `grep` kilépési kódja az `if` feltételében.

> **Tipp:** A találatokat maga a `grep` írja ki, a scriptnek csak azt kell megnéznie, hogy volt-e találat: `if ! grep -iw "$word" "$file"; then …`.

### 3. Szót tartalmazó fájlok keresése könyvtárban

Megoldás: [`3_find_files_with_word.sh`](solutions/3_find_files_with_word.sh)

Írjunk scriptet, amely egy könyvtárban **és annak alkönyvtáraiban** megkeresi azokat a fájlokat, amelyek tartalmazzák a megadott szót, és kiírja a nevüket. Az első paraméter a kiindulási könyvtár, a második a keresett szó.

```bash
../solutions/3_find_files_with_word.sh main_folder banan
```

```text
main_folder/text1.txt
main_folder/text3.txt
main_folder/sub_folder/text2.txt
```

Amit használunk: `-d`, `find -type f`, `|`, `while read -r file`, `grep -q`.

A `find` kilistázza az összes fájlt, a `while read` ciklus pedig fájlonként megnézi `grep -q`-val, hogy benne van-e a szó:

```bash
find "$directory" -type f | while read -r file; do
    if grep -q "$word" "$file"; then
        echo "$file"
    fi
done
```

> **Tipp:** Ugyanez egyetlen paranccsal is megoldható: `grep -rl "$word" "$directory"` (`-r` rekurzív keresés, `-l` csak a fájlnevek). Az órán a ciklusos megoldást írjuk meg, mert azt később bármilyen fájlonkénti feladathoz tudjuk alakítani.

### 4. Fájl tartalmának nagybetűsítése

Megoldás: [`4_uppercase.sh`](solutions/4_uppercase.sh)

Írjunk scriptet, amely paraméterként egy fájlnevet (vagy teljes elérési utat) vár, és a fájl tartalmát átírja a nagybetűs megfelelőjére. **Magát a fájlt kell módosítani**, nem egy új fájlt létrehozni.

```bash
../solutions/1_copy.sh all_lower.txt test.txt      # előbb egy másolaton dolgozunk
../solutions/4_uppercase.sh test.txt
cat test.txt
```

```text
ALMA
KORTE
BANAN
NARANCS
FENYOFA
```

Amit használunk: `-f`, `-w`, `tr`, `<` és `>` átirányítás, ideiglenes fájl, `mv`.

> **Fontos:** A `tr … < "$file" > "$file"` **nem működik**: a shell a `>` miatt már a `tr` indulása előtt kiüríti a fájlt, így a `tr` egy üres fájlt olvasna. Ezért előbb egy ideiglenes fájlba írunk (`"$file.tmp"`), majd az `mv` paranccsal azzal írjuk felül az eredetit.

### 5. Kapcsolók

Megoldás: [`5_switches.sh`](solutions/5_switches.sh)

Írjunk scriptet, amely a kapott kapcsolótól függően más-más parancsot futtat:

| Kapcsoló | Hatás |
|---|---|
| `-d` | A `date` parancs futtatása |
| `-w` | A bejelentkezett felhasználó nevének kiírása |
| `-l` | A felhasználó saját könyvtárának listázása |

Ha nem megfelelő kapcsolót kap (vagy egyet sem), a script szövegesen tájékoztassa a felhasználót a használható kapcsolókról, és nem nulla kóddal lépjen ki.

```bash
../solutions/5_switches.sh -w
```

```text
laszlo
```

```bash
../solutions/5_switches.sh -x
```

```text
Error: unknown option '-x'
Usage: ../solutions/5_switches.sh -d | -w | -l
  -d  print the current date and time
  -w  print the name of the logged in user
  -l  list the home directory of the user
```

Amit használunk: `case`, `usage` függvény, `usage >&2`, `whoami` / `$USER`, `$HOME`.

> **Tipp:** A használati útmutatót tegyük függvénybe, mert két helyről is hívjuk (kevés paraméter, ismeretlen kapcsoló). A `usage >&2` a függvény teljes kimenetét a standard errorra irányítja.

### 6. A hónap leggyakoribb betegsége

Megoldás: [`6_most_common_illness.sh`](solutions/6_most_common_illness.sh)

A `patients.txt` fájl soronként egy beteget tartalmaz, `Név,ÉÉÉÉ-HH-NN,betegség` formában:

```text
Kiss Béla,2023-10-13,fejfájás
Kiss Bertalan,2023-10-13,fejfájás
Tóth Emese,2023-10-20,megfázás
...
```

Írjunk scriptet, amely két paramétert vár: a fájl nevét és egy hónapot (két számjeggyel, `01`–`12`). A script írja ki, hogy az adott hónapban melyik betegség volt a leggyakoribb, és hány beteg volt vele.

- A hónapot ellenőrizzük: csak `01`–`12` fogadható el.
- Ha az adott hónapban nem volt beteg, erről írjon ki üzenetet.

```bash
../solutions/6_most_common_illness.sh patients.txt 10
```

```text
Most common illness in month 10: fejfájás (3 patient(s))
```

```bash
../solutions/6_most_common_illness.sh patients.txt 02
```

```text
No patients in month 02.
```

Amit használunk: reguláris kifejezés csoporttal és választással (`^(0[1-9]|1[0-2])$`), `grep -E` **változót tartalmazó** mintával, `cut`, `sort`, `uniq -c`, `sort -rn`, `head -n 1`, `$( )`, `-z`, `read … <<<`.

A megoldás lelke egy csővezeték:

```bash
grep -E ",[0-9]{4}-$month-[0-9]{2}," "$file" | cut -d ',' -f 3 | sort | uniq -c | sort -rn | head -n 1
```

| Lépés | Hatás |
|---|---|
| `grep -E ",[0-9]{4}-$month-[0-9]{2},"` | Csak a megadott hónap sorai maradnak. A minta **dupla** idézőjelben van, hogy a `$month` behelyettesítődjön. |
| `cut -d ',' -f 3` | Csak a betegség mezője marad |
| `sort \| uniq -c` | Betegségenként a darabszám |
| `sort -rn \| head -n 1` | A legnagyobb darabszámú sor |

> **Tipp:** Építsük fel a csővezetéket lépésenként a terminálban, és minden lépés után nézzük meg a kimenetet. Csak akkor tegyük be a scriptbe, ha már jó az eredmény.

> **Tipp:** Az eredmény egy `      3 fejfájás` alakú sor. A `read -r count illness <<< "$result"` a számot a `count`, a betegséget az `illness` változóba teszi, így szépen formázva írhatjuk ki.

### 7. Biztonsági mentés

Megoldás: [`7_backup.sh`](solutions/7_backup.sh)

Írjunk scriptet, amely paraméterként egy könyvtár nevét várja, és biztonsági mentést készít a könyvtárban (közvetlenül) található `.txt` fájlokról:

- Hozzon létre az aktuális könyvtárban egy `<könyvtárnév>_backup_<mai dátum>` nevű könyvtárat (pl. `main_folder_backup_2026-10-07`).
- Másolja bele a `.txt` fájlokat, és minden másolt fájl nevét írja ki.
- A végén írja ki, hány fájlt mentett. Ha egyetlen `.txt` fájl sem volt, ezt jelezze, és az üres mentési könyvtárat törölje.

```bash
../solutions/7_backup.sh main_folder
```

```text
Copied: main_folder/text1.txt
Copied: main_folder/text3.txt
2 file(s) backed up to 'main_folder_backup_2026-10-07'.
```

Amit használunk: `-d`, `basename`, `date +%F`, `$( )` szövegben, `mkdir -p`, `for file in "$dir"/*.txt`, `-f` vizsgálat a ciklusban, `cp`, számláló (`((count++))`), `rmdir`.

> **Tipp:** Ha a könyvtárban nincs `.txt` fájl, a `"$dir"/*.txt` minta szó szerint kerül a ciklusváltozóba. Ezért a ciklus elején az `-f` vizsgálattal ugorjuk át (`continue`) a nem létező fájlt.

### 8. Lekérdezések a betegnyilvántartásból

Megoldás: [`8_patients_query.sh`](solutions/8_patients_query.sh)

Írjunk scriptet, amely a `patients.txt` fájlon különböző lekérdezéseket végez a kapott kapcsoló szerint. Az első paraméter a fájl neve, a második a kapcsoló, a harmadik (ha kell) a kapcsoló értéke:

| Kapcsoló | Hatás |
|---|---|
| `-i <betegség>` | Az adott betegséggel kezelt betegek nevének kiírása |
| `-m <hónap>` | Hány beteg volt az adott hónapban (`01`–`12`) |
| `-l` | Az előforduló betegségek listája ábécérendben, mindegyik egyszer |
| `-c` | Betegségenként a betegek száma, a leggyakoribbal kezdve |
| `-h` | Használati útmutató |

Minden kapcsolóhoz **külön függvény** tartozzon. Hiányzó érték (`-i` vagy `-m` érték nélkül), ismeretlen kapcsoló és hibás hónap esetén hibaüzenettel lépjen ki.

```bash
../solutions/8_patients_query.sh patients.txt -i fejfájás
```

```text
Kiss Béla
Kiss Bertalan
Nemes László
Molnár Erika
Horváth Zita
Nagy Ilona
```

```bash
../solutions/8_patients_query.sh patients.txt -c
```

```text
   6 fejfájás
   4 megfázás
   3 lábfájás
   1 gyomorpanaszok
```

Amit használunk: függvények `local` változókkal, `case`, `grep -i` mintában változóval és `$` horgonnyal (`",$illness$"`), `grep -c`, `cut`, `sort -u`, `sort | uniq -c | sort -rn`, `-z`.

> **Tipp:** A betegség a sor végén áll, ezért a `",$illness$"` mintával keressük: a vessző és a sor vége (`$`) biztosítja, hogy a teljes mezőnek kell egyeznie, nem csak egy részének.

> **Tipp:** A `file` változó a függvényeken kívül kap értéket, ezért globális: minden függvény látja. A függvények saját változóit (`local`) viszont csak ők.

### 9. Interaktív menü

Megoldás: [`9_menu.sh`](solutions/9_menu.sh)

Írjunk scriptet, amely a `tasks` mappából futtatva egy menüt jelenít meg, bekéri a felhasználó választását, és elvégzi a kért műveletet. A menü addig jelenjen meg újra, amíg a felhasználó a `0`-t nem választja. Kilépéskor a script írja ki, hány műveletet futtatott.

```text
===== MENU =====
1) Current date and time
2) Logged in user and home directory
3) Number of .txt files in the current directory
4) List of illnesses (patients.txt)
5) Search a word in menu.txt
0) Exit
Your choice:
```

- Minden menüponthoz külön függvény tartozzon.
- Az 5. menüpont `read`-del kérje be a keresett szót, és a 2. feladat megoldását használja újra.
- Érvénytelen választásra írjon ki hibaüzenetet, és **ne** számolja műveletnek.
- A script induláskor ellenőrizze, hogy a `menu.txt` és a `patients.txt` létezik-e.
- A `Ctrl+D` lenyomására (sikertelen `read`) a script lépjen ki, ne kerüljön végtelen ciklusba.

```text
Your choice: 4
fejfájás
gyomorpanaszok
lábfájás
megfázás

===== MENU =====
...
Your choice: 7
Error: invalid choice '7'

===== MENU =====
...
Your choice: 0
Bye! You ran 1 operation(s).
```

Amit használunk: `while true`, `read -r -p` az `if` feltételében, `case` egysoros ágakkal, `break`, `continue`, függvények, `for` a fájlok ellenőrzésére, `grep -iw`, `cut | sort -u`, számláló.

> **Tipp:** A `continue` a `*)` ágban átugorja a ciklus végén lévő `((operations++))` sort, így az érvénytelen választás nem számít bele a műveletekbe. A `break` a `0)` ágban lép ki a ciklusból.

---

## Gyakori hibák

| Hibás | Helyes | Magyarázat |
|---|---|---|
| `tr … < f.txt > f.txt` | `tr … < f.txt > f.tmp && mv f.tmp f.txt` | A `>` már a parancs indulása előtt kiüríti a fájlt. |
| `grep $word $file` | `grep "$word" "$file"` | Idézőjel nélkül a szóközt tartalmazó érték több paraméterré esik szét. |
| `grep ",$month,"` aposztrófok között: `',$month,'` | `",$month,"` | Aposztrófok között a `$month` nem helyettesítődik be. |
| `cut -d ',' -f 3 f \| uniq -c` | `cut -d ',' -f 3 f \| sort \| uniq -c` | A `uniq` csak az egymás utáni azonos sorokat vonja össze. |
| `case` ág `;;` nélkül | minden ág végén `;;` | Enélkül a következő ág is lefut (vagy szintaktikai hiba). |
| `*)` ág elsőként | `*)` ág utolsóként | Az első illeszkedő ág fut le, a `*` mindenre illeszkedik. |
| `for f in *.txt` üres könyvtárban `-f` vizsgálat nélkül | `[ -f "$f" ] \|\| continue` | Találat nélkül a minta szó szerint kerül a változóba. |
| `find … \| while read; do ((n++)); done; echo $n` | `find … \| wc -l` | A csővezeték utáni ciklus külön folyamatban fut, a benne módosított változó kívül nem látszik (`n` értéke `0` marad). |
| `echo "$result" \| read -r a b` | `read -r a b <<< "$result"` | Ugyanaz a csapda: a csővezeték utáni `read` subshellben fut, az `a` és `b` üres marad. |
| `while true; do read -r x; …; done` `Ctrl+D` kezelése nélkül | `if ! read -r x; then break; fi` | Sikertelen `read` esetén a ciklus soha nem áll le. |
| `usage` hibaüzenetként stdout-ra | `usage >&2` | A használati útmutató hiba esetén a standard errorra való. |

---

## További gyakorlás

1. Bővítsük a 8. feladat scriptjét egy `-y <év>` kapcsolóval, amely az adott évben kezelt betegek számát írja ki. Ellenőrizzük, hogy az év négy számjegyből áll-e.
2. Írjunk scriptet, amely paraméterként egy könyvtárat kap, és a benne lévő összes `.txt` fájlról kiírja a nevét és a sorainak számát (`wc -l`), a végén pedig az összes sor számát.
3. Írjunk scriptet, amely paraméterként egy hónapot kap, és a `patients.txt` fájlból az adott hónap betegeinek nevét ábécérendben kiírja. Ha nem kap paramétert, a hónapot `read`-del kérje be.
4. Bővítsük a 9. feladat menüjét egy új ponttal, amely a 7. feladat alapján biztonsági mentést készít a `main_folder` könyvtárról. A mentést végző kódot függvénybe tegyük.

---

## További anyagok

| Forrás | Leírás |
|---|---|
| [`Material_4.md`](../Exercise_4/Material_4.md) | Az előző óra anyaga: a shell scriptek alapjai |
| https://devhints.io/bash | Bash összefoglaló (cheat sheet) |
| https://www.shellcheck.net/ | Shell scriptek automatikus ellenőrzése |
| `man cut`, `man sort`, `man uniq` | Beépített kézikönyv a terminálban |
