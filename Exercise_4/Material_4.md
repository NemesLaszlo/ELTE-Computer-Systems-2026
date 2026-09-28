# Shell scriptek és reguláris kifejezések

A **shell script** egy szöveges fájl, amelybe ugyanazokat a parancsokat írjuk, amelyeket a terminálba is begépelnénk. A shell (esetünkben a `bash`) a fájl sorait felülről lefelé, egymás után hajtja végre. Így az ismétlődő feladatok automatizálhatók, paraméterezhetők és újra felhasználhatók.

## Tartalom

1. [Az első script](#az-első-script)
2. [Változók](#változók)
3. [Script paraméterek](#script-paraméterek-script-arguments)
4. [Elágazások](#elágazások)
5. [Szövegműveletek](#szövegműveletek)
6. [Ciklusok](#ciklusok)
7. [Függvények](#függvények)
8. [Reguláris kifejezések](#reguláris-kifejezések)
9. [Szabványos adatfolyamok és átirányítás](#szabványos-adatfolyamok-és-átirányítás)
10. [Összetett példák](#összetett-példák)
11. [Gyakori hibák](#gyakori-hibák)
12. [Gyakorló feladatok](#gyakorló-feladatok)

## A mappa tartalma

| Fájl | Témakör |
|---|---|
| [`1_first_script.sh`](1_first_script.sh) | Shebang, `echo`, futtatás |
| [`2_script_with_arguments.sh`](2_script_with_arguments.sh) | Parancssori paraméterek: `$0`, `$1`, `$#`, `$*` |
| [`3_if_statement.sh`](3_if_statement.sh) | Elágazás, számok összehasonlítása |
| [`3_if_statement_logic.sh`](3_if_statement_logic.sh) | Beolvasás (`read`), szövegek összehasonlítása, logikai műveletek |
| [`4_string_combine.sh`](4_string_combine.sh) | Szövegek összefűzése, idézőjelek |
| [`4_substring.sh`](4_substring.sh) | Részszöveg kivágása, csere, kis- és nagybetűk |
| [`5_loops.sh`](5_loops.sh) | `while`, `until`, `for`, `break`, `continue` |
| [`6_functions.sh`](6_functions.sh) | Függvények, paraméterek, visszatérési érték |
| [`dir_tester.sh`](dir_tester.sh) | Összetett példa: könyvtár létezésének vizsgálata |
| [`line_counter.sh`](line_counter.sh) | Összetett példa: `grep` + reguláris kifejezés |
| [`line_writer.sh`](line_writer.sh) | Összetett példa: paraméterek ellenőrzése, ciklus |
| `numbers.txt` | Tesztadat a `line_counter.sh` scripthez |
| `test_dir/` | Tesztkönyvtár a `dir_tester.sh` scripthez |

> **Megjegyzés:** A scriptekben a magyarázatok kommentként szerepelnek, érdemes a fájlokat megnyitni és a leírással párhuzamosan olvasni.

---

## Az első script

Példa: [`1_first_script.sh`](1_first_script.sh)

```bash
#!/bin/bash
# Ez egy komment
echo "Hello world"
```

| Elem | Jelentés |
|---|---|
| `#!/bin/bash` | **Shebang** – megadja, hogy a scriptet melyik parancsértelmező futtassa. Mindig a fájl **első sora**. |
| `# ...` | **Komment** – a `#` utáni részt a shell figyelmen kívül hagyja. |
| `echo` | Szöveg kiírása a terminálra. |

### Futtatás lépésről lépésre

**1.** Futtatási jog (**x** – execute) beállítása, ezt fájlonként egyszer kell megtenni:

```bash
chmod +x 1_first_script.sh
```

**2.** A jogosultság ellenőrzése:

```bash
ls -l 1_first_script.sh
```

```text
-rwxr-xr-x 1 user user 398 Sep 28 10:00 1_first_script.sh
```

**3.** Futtatás:

```bash
./1_first_script.sh
```

```text
Hello world
```

### Futtatási módok

| Parancs | Kell `x` jog? | Mi történik? |
|---|:---:|---|
| `./script.sh` | igen | Új folyamatban fut, a shebang által megadott értelmezővel. |
| `bash script.sh` | nem | Új folyamatban fut, a megadott értelmezővel (a shebang ilyenkor csak komment). |
| `source script.sh` vagy `. script.sh` | nem | Az **aktuális shellben** fut, a scriptben létrehozott változók megmaradnak. |

> **Miért kell a `./`?** A shell a parancsokat csak a `PATH` változóban felsorolt könyvtárakban keresi, az aktuális könyvtár pedig alapesetben nincs ezek között. A `./` azt jelenti: „az aktuális könyvtárban lévő fájlt futtasd”.

---

## Változók

| Művelet | Szintaxis | Példa |
|---|---|---|
| Létrehozás / értékadás | `változónév=érték` | `var1="almafa"` |
| Érték elérése | `$változónév` vagy `${változónév}` | `echo "$var1"` |
| Törlés | `unset változónév` | `unset var1` |
| Parancs kimenetének mentése | `változónév=$(parancs)` | `today=$(date +%F)` |
| Számolás | `$(( kifejezés ))` | `sum=$(( 3 + 4 ))` |

### Szabályok

- Az `=` jel **előtt és után nem lehet szóköz**.
- Értékadásnál a változó neve elé **nem** kell `$` jel, az csak az érték elérésekor kell.
- A változó neve betűt, számot és `_` jelet tartalmazhat, de **nem kezdődhet számmal**. Ékezetes karaktereket ne használjunk.
- A nem definiált változó helyére **üres string** helyettesítődik be, hibaüzenet nélkül.
- `unset` után a változó a script további részében nem lesz definiálva.

```bash
var1="almafa"
echo "$var1"        # almafa

unset var1
echo "$var1"        # (üres sor)
```

### Idézőjelek

| Forma | Viselkedés | Példa | Eredmény |
|---|---|---|---|
| `"..."` | A változók és parancsok behelyettesítődnek | `echo "Hello $USER"` | `Hello laszlo` |
| `'...'` | Minden karakter szó szerint értendő | `echo 'Hello $USER'` | `Hello $USER` |
| `$(...)` | Parancsbehelyettesítés: a parancs kimenete kerül a helyére | `echo "Ma: $(date +%F)"` | `Ma: 2026-09-28` |

> **Javasolt gyakorlat:** a változókat szinte mindig idézőjelek között használjuk (`"$var"`). Így szóközt tartalmazó vagy üres érték esetén is helyesen működik a script.

### Neves környezetváltozók

A környezetváltozók minden script számára elérhetők az indulás pillanatától, és a rendszerről adnak hasznos információkat. Listázásuk:

```bash
env
```

| Változó | Jelentés |
|---|---|
| `HOME` | A felhasználó saját könyvtárának abszolút elérési útja |
| `PWD` | Az aktuális könyvtár abszolút elérési útja |
| `PATH` | A parancsok keresési helyeinek listája, `:` jellel elválasztva |
| `USER` | A felhasználónevünk |
| `SHELL` | A felhasználó alapértelmezett shellje |
| `RANDOM` | Véletlenszerű szám 0 és 32767 között (minden kiolvasáskor más) |
| `PS1` | A parancssori promptot meghatározó változó |

> **Megjegyzés:** A `RANDOM` és a `PS1` a bash saját (shell) változói, ezért az `env` kimenetében jellemzően nem szerepelnek, de a scriptekben ugyanúgy használhatók.

```bash
echo "Felhasználó: $USER, saját könyvtár: $HOME"
echo "Dobókocka: $(( RANDOM % 6 + 1 ))"
```

---

## Script paraméterek (Script Arguments)

Példa: [`2_script_with_arguments.sh`](2_script_with_arguments.sh)

| Változó | Jelentés |
|---|---|
| `$0` | A script neve (ahogyan elindítottuk) |
| `$1` … `$9` | Az első … kilencedik paraméter |
| `${10}`, `${11}`, … | A tizedik paramétertől kapcsos zárójel szükséges |
| `$#` | A paraméterek száma |
| `$*` | Az összes paraméter egyetlen szövegként |
| `$@` | Az összes paraméter külön-külön (idézőjelben használjuk: `"$@"`) |
| `$?` | Az utoljára futtatott parancs kilépési kódja (`0` = siker) |
| `$$` | A futó script folyamatazonosítója (PID) |

### Példa

```bash
./2_script_with_arguments.sh Laszlo Nemes
```

```text
Script name: ./2_script_with_arguments.sh
My first name is Laszlo
My surname is Nemes
Total number of arguments is 2
All arguments: Laszlo Nemes
```

> **Megjegyzés:** A paramétereket szóköz választja el. Ha egy érték szóközt tartalmaz, tegyük idézőjelbe: `./2_script_with_arguments.sh "Laszlo Peter" Nemes` – ekkor is 2 paramétert kap a script.

---

## Elágazások

Példák: [`3_if_statement.sh`](3_if_statement.sh), [`3_if_statement_logic.sh`](3_if_statement_logic.sh)

### Szintaxis

```bash
if [ feltétel ]; then
    # ha a feltétel igaz
elif [ másik_feltétel ]; then
    # ha a másik feltétel igaz
else
    # minden más esetben
fi
```

> **Fontos:** a `[` után és a `]` előtt **kötelező a szóköz**. A `[` valójában egy parancs (a `test` parancs másik neve), a feltétel részei pedig a paraméterei.

### Számok összehasonlítása

| Operátor | Jelentés | Példa |
|---|---|---|
| `-eq` | egyenlő (*equal*) | `[ "$a" -eq 10 ]` |
| `-ne` | nem egyenlő (*not equal*) | `[ "$a" -ne 10 ]` |
| `-lt` | kisebb (*less than*) | `[ "$a" -lt 10 ]` |
| `-le` | kisebb vagy egyenlő (*less or equal*) | `[ "$a" -le 10 ]` |
| `-gt` | nagyobb (*greater than*) | `[ "$a" -gt 10 ]` |
| `-ge` | nagyobb vagy egyenlő (*greater or equal*) | `[ "$a" -ge 10 ]` |

Számoknál az aritmetikai forma is használható, a megszokott operátorokkal:

```bash
if (( n < 10 )); then
    echo "egyjegyű"
fi
```

### Szövegek összehasonlítása

| Operátor | Jelentés | Példa |
|---|---|---|
| `==` | a két szöveg egyezik | `[[ $name == "admin" ]]` |
| `!=` | a két szöveg különbözik | `[[ $name != "admin" ]]` |
| `-z` | a szöveg üres | `[ -z "$name" ]` |
| `-n` | a szöveg nem üres | `[ -n "$name" ]` |
| `=~` | illeszkedik a reguláris kifejezésre (csak `[[ ]]`) | `[[ $n =~ ^[0-9]+$ ]]` |

### Fájlok vizsgálata

| Operátor | Igaz, ha… |
|---|---|
| `-e` | a megadott útvonal létezik |
| `-f` | létezik és sima fájl |
| `-d` | létezik és könyvtár |
| `-s` | létezik és nem üres |
| `-r` / `-w` / `-x` | olvasható / írható / futtatható |

### Logikai műveletek

| Művelet | `[[ ]]` szerkezetben | Példa |
|---|---|---|
| ÉS | `&&` | `[[ $user == "admin" && $pass == "secret" ]]` |
| VAGY | `\|\|` | `[[ $ext == "jpg" \|\| $ext == "png" ]]` |
| Tagadás | `!` | `[[ ! -f "$file" ]]` |

### `[ ]` vagy `[[ ]]`?

| | `[ ]` | `[[ ]]` |
|---|---|---|
| Hol működik? | Minden POSIX shellben | bash, zsh, ksh |
| `&&`, `\|\|` a feltételen belül | nem | igen |
| Reguláris kifejezés (`=~`) | nem | igen |
| Idézőjel nélküli változó | hibát okozhat | biztonságos |

> **Javasolt gyakorlat:** bash scriptben (`#!/bin/bash`) nyugodtan használjuk a `[[ ]]` formát. A `[ ]` formát is ismerni kell, mert nagyon sok meglévő scriptben ezzel találkozunk.

### Adat bekérése a felhasználótól

```bash
read -r -p "Enter username: " username
```

| Kapcsoló | Jelentés |
|---|---|
| `-r` | A `\` karaktert nem kezeli speciálisan (szinte mindig érdemes megadni) |
| `-p "szöveg"` | Beolvasás előtt kiírja a megadott szöveget |
| `-s` | A begépelt szöveg nem jelenik meg (jelszavakhoz) |

---

## Szövegműveletek

Példák: [`4_string_combine.sh`](4_string_combine.sh), [`4_substring.sh`](4_substring.sh)

A példákban: `str="ELTE IK University"`

| Művelet | Szintaxis | Példa | Eredmény |
|---|---|---|---|
| Összefűzés | `"$a$b"` | `"${s1}${s2}"` | `ELTE IK` |
| Hozzáfűzés | `a+="szöveg"` | `s3+=" University"` | `ELTE IK University` |
| Hossz | `${#str}` | `${#str}` | `18` |
| Részszöveg | `${str:kezdet:hossz}` | `${str:5:2}` | `IK` |
| Részszöveg a végéig | `${str:kezdet}` | `${str:8}` | `University` |
| Részszöveg a végétől | `${str: -hossz}` | `${str: -10}` | `University` |
| Első előfordulás cseréje | `${str/mit/mire}` | `${str/IK/TTK}` | `ELTE TTK University` |
| Összes előfordulás cseréje | `${str//mit/mire}` | `${str//E/e}` | `eLTe IK University` |
| Nagybetűssé alakítás | `${str^^}` | `${str^^}` | `ELTE IK UNIVERSITY` |
| Kisbetűssé alakítás | `${str,,}` | `${str,,}` | `elte ik university` |
| Alapértelmezett érték | `${var:-érték}` | `${1:-10}` | `10`, ha nincs 1. paraméter |

A karakterek sorszámozása **0-tól** indul:

```text
E  L  T  E     I  K     U  n  i  v  e  r  s  i  t  y
0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17
               └──┘
            ${str:5:2}
```

> **Megjegyzés:** A `${valtozo}` forma akkor is hasznos, ha a változó után közvetlenül további szöveg következik: a `"$file_backup"` a `file_backup` nevű változót keresi, a `"${file}_backup"` viszont a `file` változó értékéhez fűzi hozzá a `_backup` szöveget.

---

## Ciklusok

Példa: [`5_loops.sh`](5_loops.sh)

| Ciklus | Mikor használjuk? |
|---|---|
| `while` | Addig ismétel, amíg a feltétel **igaz** |
| `until` | Addig ismétel, amíg a feltétel **hamis** |
| `for … in …` | Lista elemeinek bejárása (szavak, fájlok, számtartomány) |
| `for (( … ))` | Számlálós ciklus, C stílusú szintaxissal |

### While

```bash
count=1
while [ "$count" -le 5 ]; do
    echo "$count"
    ((count++))
done
```

### Until

```bash
count=1
until [ "$count" -gt 3 ]; do
    echo "$count"
    ((count++))
done
```

### For – lista, számtartomány, fájlok

```bash
for fruit in alma korte banan; do
    echo "Fruit: $fruit"
done

for i in {1..5}; do
    echo "$i"
done

for file in *.sh; do
    echo "Script: $file"
done
```

### For – C stílusú

```bash
for (( counter=10; counter>0; counter-- )); do
    echo -n "$counter "
done
printf "\n"
```

```text
10 9 8 7 6 5 4 3 2 1
```

### A ciklus vezérlése

| Utasítás | Hatás |
|---|---|
| `break` | Azonnal kilép a ciklusból |
| `continue` | A ciklusmag hátralévő részét kihagyja, és a következő körrel folytatja |

### Fájl feldolgozása soronként

Gyakori feladat, hogy egy fájl minden sorával el kell végezni valamit:

```bash
while read -r line; do
    echo "Sor: $line"
done < numbers.txt
```

---

## Függvények

Példa: [`6_functions.sh`](6_functions.sh)

```bash
Rectangle_Area() {
    local area=$(( $1 * $2 ))
    echo "Area is : $area"
}

Rectangle_Area 10 20
```

```text
Area is : 200
```

### Tudnivalók

- A függvényt a használata **előtt** kell definiálni.
- Híváskor csak a nevét írjuk le, **zárójelek nélkül**, a paramétereket szóközzel elválasztva.
- A függvény a paramétereit ugyanúgy éri el, mint a script: `$1`, `$2`, `$#`, `$@`.
- A `local` kulcsszóval létrehozott változó csak a függvényen belül létezik. Enélkül a változó **globális**, vagyis a script többi részében is látszik és felülírható.

### Eredmény visszaadása

| Módszer | Mire való? | Példa |
|---|---|---|
| `echo` + `$( )` | Tetszőleges érték (szöveg, szám) visszaadása | `result=$(Square 7)` |
| `return` | Állapotkód (0–255): `0` = siker, más = hiba | `if Is_Even 4; then …` |

```bash
Square() {
    echo $(( $1 * $1 ))
}

result=$(Square 7)
echo "Square of 7 is : $result"     # Square of 7 is : 49
```

> **Fontos:** A `return` nem úgy működik, mint más programozási nyelvekben: csak egy 0 és 255 közötti állapotkódot ad vissza, amelyet a `$?` változóból olvashatunk ki. Számítási eredmény visszaadására az `echo` + `$( )` párost használjuk.

---

## Reguláris kifejezések

Reguláris kifejezésekkel keresendő vagy cserélendő karakterláncok (stringek) **mintáját** írhatjuk le. Többek között a `grep`, a `sed` és az `awk` parancsok, valamint a bash `[[ … =~ … ]]` szerkezete használja őket.

Gyakorláshoz és a kifejezések kipróbálásához: https://regex101.com/

### Alapok

- A legtöbb karakter (betűk, számok) **önmagára** illeszkedik.
- A speciális jelentésű **metakarakterek** (pl. `.`, `*`, `[`, `(`, `?`, `+`) elé `\` jelet kell írni, ha magát a karaktert keressük. Például a `\.` a pont karakterre illeszkedik.
- Ha `\` jelet keresünk, akkor `\\`-t kell írni.

### Karakterek és karakterosztályok

| Minta | Mire illeszkedik? | Példa |
|---|---|---|
| `.` | Bármely egy karakter | `a.a` → `aba`, `a1a` |
| `[abc]` | A felsorolt karakterek bármelyike | `[0123456789]` → egy számjegy |
| `[a-d]` | Tartomány, ugyanaz mint `[abcd]` | `[a-z]` → egy kisbetű |
| `[^abc]` | Bármely karakter, ami **nem** szerepel a listában | `[^0-9]` → nem számjegy |
| `\w` | Betű, számjegy vagy `_` | `\w+` → egy „szó” |
| `\W` | Bármi, ami nem betű, számjegy vagy `_` | |
| `[[:digit:]]` | Számjegy (POSIX osztály) | ugyanaz, mint `[0-9]` |
| `[[:alpha:]]` | Betű (POSIX osztály) | |
| `[[:space:]]` | Szóköz, tabulátor, sortörés (POSIX osztály) | |

> **Megjegyzés:** A `[ ]` jelek között a legtöbb speciális karakter elveszti a jelentését, ezért például a `.` vagy a `*` elé a listában nem kell `\` jelet írni: a `[.,]` a pontra vagy a vesszőre illeszkedik.

### Horgonyok

| Minta | Hol illeszkedik? | Példa |
|---|---|---|
| `^` | A sor elején | `^alma` → az `alma` szöveggel kezdődő sorok |
| `$` | A sor végén | `alma$` → az `alma` szövegre végződő sorok |
| `\b` | Szóhatáron | `\bkorte\b` → a `korte` mint önálló szó |

A `^alma$` csak arra a sorra illeszkedik, amely pontosan az `alma` szövegből áll.

### Ismétlések

Egy karakter vagy csoport mögé írva megadják, hogy az hányszor szerepelhet:

| Minta | Az előző tag… | Példa |
|---|---|---|
| `?` | 0-szor vagy 1-szer illeszkedik (opcionális) | `-?[0-9]` → `5`, `-5` |
| `*` | 0-szor vagy többször illeszkedik | `ab*` → `a`, `ab`, `abbb` |
| `+` | 1-szer vagy többször illeszkedik | `[0-9]+` → `7`, `2026` |
| `{n}` | pontosan n-szer illeszkedik | `[0-9]{4}` → `2026` |
| `{n,}` | legalább n-szer illeszkedik | `[0-9]{2,}` → `10`, `12345` |
| `{,m}` | legfeljebb m-szer illeszkedik | `[0-9]{,3}` → `1`, `123` |
| `{n,m}` | legalább n-szer és legfeljebb m-szer illeszkedik | `[0-9]{2,4}` → `12`, `1234` |

### Csoportok és választás

| Minta | Jelentés | Példa |
|---|---|---|
| `( )` | Csoport – az utána írt ismétlés a teljes csoportra vonatkozik | `(abcd)+` → `abcd`, `abcdabcd` |
| `\|` | Választás (vagy) | `(alma\|korte\|banan)` |
| `\1`, `\2`, … | Hivatkozás a csoportra a sorszámával (pl. `sed` parancsban) | lásd lent |

Az `alma(korte)x([0-9]+)` kifejezésben:

| Csoport | Tartalom |
|---|---|
| 0. | A teljes megtalált kifejezés |
| 1. | A `korte` string |
| 2. | Az `x` után következő, legalább 1 darab számjegy |

Példa a csoportokra való hivatkozásra – két szó felcserélése:

```bash
echo "alma korte" | sed -E 's/(\w+) (\w+)/\2 \1/'
```

```text
korte alma
```

### Használat `grep` paranccsal

| Kapcsoló | Jelentés |
|---|---|
| `-E` | Bővített reguláris kifejezések (`+`, `?`, `\|`, `( )`, `{ }` használata `\` nélkül) |
| `-c` | A találatok helyett az illeszkedő sorok **számát** írja ki |
| `-i` | Nem különbözteti meg a kis- és nagybetűket |
| `-v` | Azokat a sorokat adja vissza, amelyek **nem** illeszkednek |
| `-o` | Csak az illeszkedő részt írja ki, nem a teljes sort |
| `-n` | A találatok elé kiírja a sor számát |
| `-x` | A teljes sornak illeszkednie kell a mintára |

```bash
grep -E '^[0-9]+$' numbers.txt
```

```text
123
321
11
```

> **Fontos:** A mintát mindig **aposztrófok** (`'...'`) közé írjuk! Különben a shell értelmezné a speciális karaktereket (`$`, `*`, `?`, `\`), mielőtt a minta eljutna a `grep` parancshoz.

> **Megjegyzés:** A `grep -E` nem ismeri a más nyelvekből megszokott `\d` jelölést, helyette `[0-9]` vagy `[[:digit:]]` használható.

### Használat bash feltételben

```bash
if [[ $times =~ ^[0-9]+$ ]]; then
    echo "Ez egy nemnegatív egész szám"
fi
```

Itt a mintát **nem** tesszük idézőjelbe, mert akkor a bash sima szövegként kezelné.

---

## Szabványos adatfolyamok és átirányítás

Minden folyamatnak három szabványos adatfolyama van, mindegyiket egy szám (**file descriptor**) azonosítja:

| Szám | Név | Szerep |
|:---:|---|---|
| `0` | stdin (standard input) | bemenet |
| `1` | stdout (standard output) | normál kimenet |
| `2` | stderr (standard error) | hibaüzenetek |

### Mit jelent a `>&2`?

A példascriptekben a hibaüzenetek végén ez szerepel:

```bash
echo "File not found: $1" >&2
```

A `>&2` az `echo` kimenetét a standard output helyett a **standard errorra** irányítja.

| Rész | Jelentés |
|---|---|
| `>` | A kimenet átirányítása. Alapértelmezetten az stdout-ra vonatkozik, vagyis az `1>` rövidítése. |
| `&2` | A cél a 2-es adatfolyam (stderr). |

> **Fontos:** Az `&` jel nem hagyható el! A `>2` nem a standard errorra írna, hanem egy `2` nevű **fájlba**.

### Miért hasznos?

A terminálon mindkét adatfolyam a képernyőn jelenik meg, ezért ott nem látunk különbséget. A különbség akkor derül ki, amikor a kimenetet átirányítjuk:

```bash
./line_counter.sh nope.txt > result.txt
```

```text
File not found: nope.txt
```

A `result.txt` fájlba csak az stdout kerül. A hibaüzenet a terminálon jelenik meg, és nem íródik bele a fájlba úgy, mintha az a script eredménye lenne.

Ugyanez igaz a csővezetékre (`|`) és a parancsbehelyettesítésre is:

```bash
count=$(./line_counter.sh nope.txt)
```

A `count` változóba csak az stdout tartalma kerül, a hibaüzenet nem.

### Átirányítási formák

| Forma | Jelentés |
|---|---|
| `parancs > out.txt` | Az stdout fájlba kerül (a fájl tartalmát felülírja) |
| `parancs >> out.txt` | Az stdout a fájl végéhez fűződik |
| `parancs < in.txt` | Az stdin a fájlból érkezik |
| `parancs 2> err.txt` | Az stderr fájlba kerül |
| `parancs 2>/dev/null` | A hibaüzenetek eldobása |
| `parancs > all.txt 2>&1` | Mindkét kimenet ugyanabba a fájlba kerül |
| `parancs >&2` | Az stdout az stderr-re kerül |
| `parancs1 \| parancs2` | Az első parancs stdout-ja a második parancs stdin-je lesz |

> **Javasolt gyakorlat:** A hibaüzeneteket és a használati útmutatót (`Usage: ...`) mindig az stderr-re írjuk (`>&2`), és hiba esetén nem nulla kilépési kóddal (`exit 1`) lépjünk ki.

---

## Összetett példák

### `dir_tester.sh` – könyvtár vizsgálata

Fájl: [`dir_tester.sh`](dir_tester.sh)

Bekér egy könyvtárnevet. Ha a könyvtár létezik, jelzi, ha nem, akkor létrehozza.

```bash
./dir_tester.sh
```

```text
Enter directory name: test_dir
Directory exist
```

Felhasznált elemek: `read`, `-z` és `-d` vizsgálat, `mkdir -p`, hibaüzenet a standard errorra (`>&2`), kilépési kód (`exit 1`).

### `line_writer.sh` – szöveg ismételt kiírása

Fájl: [`line_writer.sh`](line_writer.sh)

Az első paraméter megadja, hogy a második paramétert hányszor írja ki.

```bash
./line_writer.sh 3 "Hello ELTE"
```

```text
Hello ELTE
Hello ELTE
Hello ELTE
```

Hibás paraméterezés esetén a script hibaüzenettel és nem nulla kilépési kóddal áll le:

```bash
./line_writer.sh x y
```

```text
Error: 'x' is not a non-negative integer
```

### `line_counter.sh` – sorok számolása reguláris kifejezéssel

Fájl: [`line_counter.sh`](line_counter.sh)

Megszámolja a fájl azon sorait, amelyek csak egy számot tartalmaznak, és a szám 1-esre végződik.

```bash
./line_counter.sh numbers.txt
```

```text
The script counts the number of lines that contain only numbers and end with 1
4
```

A felhasznált reguláris kifejezés:

```text
^[+-]?([0-9]+[.,])?[0-9]*1$
```

| Rész | Jelentés |
|---|---|
| `^` | A sor eleje |
| `[+-]?` | Opcionális előjel |
| `([0-9]+[.,])?` | Opcionális egészrész tizedesjellel (pl. `12.` vagy `13,`) |
| `[0-9]*` | Tetszőleges számú számjegy |
| `1` | Az utolsó számjegy 1-es |
| `$` | A sor vége |

A `numbers.txt` sorainak kiértékelése:

| Sor | Illeszkedik? | Miért? |
|---|:---:|---|
| `12.1` | igen | Tizedes tört, 1-esre végződik |
| `-13.321` | igen | Negatív tizedes tört, 1-esre végződik |
| `123` | nem | 3-asra végződik |
| `321` | igen | Egész szám, 1-esre végződik |
| `asd` | nem | Nem szám |
| `valami` | nem | Nem szám |
| `11` | igen | Egész szám, 1-esre végződik |

### Kilépési kódok

Minden parancs és script egy **kilépési kóddal** (exit status) fejeződik be, amelyet a `$?` változóból olvashatunk ki.

| Kód | Jelentés |
|---|---|
| `0` | Sikeres futás |
| `1`–`255` | Valamilyen hiba történt |

```bash
./line_writer.sh 1 teszt
echo $?     # 0

./line_writer.sh
echo $?     # 1
```

> **Javasolt gyakorlat:** A script elején ellenőrizzük a paramétereket. Hiba esetén írjunk ki használati útmutatót (`Usage: ...`) a standard errorra, és lépjünk ki nem nulla kóddal.

---

## Gyakori hibák

| Hibás | Helyes | Magyarázat |
|---|---|---|
| `var = "alma"` | `var="alma"` | Az `=` körül nem lehet szóköz. |
| `$var="alma"` | `var="alma"` | Értékadásnál nem kell `$` jel. |
| `if [$n -lt 10]` | `if [ "$n" -lt 10 ]` | A `[` után és a `]` előtt kötelező a szóköz. |
| `[ $a == $b ]` | `[ "$a" == "$b" ]` | Idézőjel nélkül az üres vagy szóközt tartalmazó érték hibát okoz. |
| `[ "$n" < 10 ]` | `[ "$n" -lt 10 ]` | A `<` a `[ ]` között átirányítást jelent, nem összehasonlítást. |
| `while [ $valid ]` | `while [ "$valid" == "true" ]` | A `[ $valid ]` csak azt vizsgálja, hogy a string nem üres-e, így `false` értéknél is igaz. |
| `` `mkdir $dir` `` | `mkdir "$dir"` | A `` ` ` `` parancsbehelyettesítés, a kimenetet parancsként próbálná futtatni. |
| `grep ^[0-9]+$ f.txt` | `grep -E '^[0-9]+$' f.txt` | Aposztrófok nélkül a shell értelmezi a speciális karaktereket. |
| `cat f.txt \| grep x \| wc -l` | `grep -c x f.txt` | A `grep` maga is tud fájlt olvasni és sorokat számolni. |
| `F1()` (híváskor) | `F1` | Függvényhíváskor nem kell zárójel. |

> **Megjegyzés:** Ha a script Windows alatt készült, a sorvégek (`CRLF`) miatt `bad interpreter` vagy `$'\r': command not found` hibát kaphatunk. Javítás: `dos2unix script.sh` vagy `sed -i 's/\r$//' script.sh`.

### Hibakeresés

| Parancs | Hatás |
|---|---|
| `bash -n script.sh` | Csak a szintaxist ellenőrzi, nem futtatja a scriptet |
| `bash -x script.sh` | Futtatás közben kiír minden végrehajtott parancsot, a behelyettesített értékekkel |
| `set -x` / `set +x` | A scripten belül be-, illetve kikapcsolja a fenti nyomkövetést |

A scriptek automatikus ellenőrzésére hasznos eszköz a **ShellCheck**: https://www.shellcheck.net/

---

## Gyakorló feladatok

1. Írjunk scriptet, amely paraméterként egy nevet vár, és köszönti az illetőt (`Hello <név>!`). Ha nem kap paramétert, a bejelentkezett felhasználó nevét használja.
2. Írjunk scriptet, amely két számot vár paraméterként, és kiírja az összegüket, a különbségüket és a szorzatukat. Hibás paraméterszám esetén írjon ki használati útmutatót.
3. Írjunk scriptet, amely a paraméterként kapott útvonalról eldönti, hogy fájl, könyvtár, vagy nem létezik.
4. Írjunk scriptet, amely kiírja 1-től a paraméterként kapott számig a páros számokat.
5. Írjunk függvényt, amely a paraméterként kapott szám faktoriálisát számolja ki, majd hívjuk meg a script első paraméterével.
6. Bővítsük a `numbers.txt` fájlt, és írjunk reguláris kifejezést, amely csak a negatív egész számokat tartalmazó sorokra illeszkedik.
7. Írjunk scriptet, amely addig kér be számokat a felhasználótól, amíg az `0`-t nem ad meg, majd kiírja a megadott számok összegét.

---

## További anyagok

| Forrás | Leírás |
|---|---|
| https://devhints.io/bash | Bash összefoglaló (cheat sheet) |
| https://regex101.com/ | Reguláris kifejezések kipróbálása, magyarázattal |
| https://www.shellcheck.net/ | Shell scriptek automatikus ellenőrzése |
| https://www.gnu.org/software/bash/manual/ | A bash hivatalos dokumentációja |
| `man bash`, `man grep` | Beépített kézikönyv a terminálban |
