# Folyamatok - Processes

A Unix- és Linux-rendszerek többfeladatos (**multitasking**) operációs rendszerek, amelyek időosztásos (**time-sharing**) módszerrel több program futtatását is lehetővé teszik.

A CPU gyors váltása miatt a felhasználó számára úgy tűnik, mintha a programok egyidejűleg futnának. Több processzort vagy processzormagot használó rendszereken bizonyos folyamatok ténylegesen párhuzamosan is futhatnak.

A párhuzamosan futtatott feladatokat, vagyis folyamatokat, kezelni is tudjuk: lekérdezhetjük, leállíthatjuk, időzíthetjük és priorizálhatjuk őket.

A Unix/Linux minden futó folyamathoz egy azonosítót, **PID-et (Process ID)** rendel. Ennek segítségével az egyszerre futó, akár azonos programok példányai is megkülönböztethetők.

A PID egy egész szám. A Linux rendszerindításakor jellemzően a PID 1-et kapja az első userspace folyamat (például `systemd`), majd további PID-ek kerülnek kiosztásra. A PID-ek nem egyszerűen egyesével növekvő, soha újra fel nem használt sorszámok: a rendszer a PID-eket újra is használhatja.

A legnagyobb engedélyezett PID érték lekérdezhető:

```bash
cat /proc/sys/kernel/pid_max
```

---

## Folyamatok kezelése / lekérdezése

A futó folyamatokat a `ps` paranccsal kérhetjük le:

```bash
ps
```

A kimenetben gyakran az alábbi oszlopokkal találkozhatunk:

- **PID** – a folyamat azonosítója
- **TTY** – a folyamathoz tartozó vezérlő terminál
- **STAT** – a folyamat állapota
- **TIME** – a folyamat által eddig felhasznált CPU-idő

A rendszerben futó folyamatokat részletesebben például az alábbi paranccsal kérhetjük le:

```bash
ps aux
```

Ekkor többek között a folyamat tulajdonosát, CPU- és memóriahasználatát, indítási idejét és egyéb információkat is láthatunk.

> **Megjegyzés:** A `ps aux` és a `ps -aux` nem ugyanaz a szintaxis. Linuxon a `ps aux` használata javasolt.

A manual elérhető:

```bash
man ps
```

A `STAT` mező legfontosabb állapotai:

```text
D    uninterruptible sleep (usually IO)
R    running or runnable (on run queue)
S    interruptible sleep (waiting for an event to complete)
T    stopped, either by a job control signal or because it is being traced.
X    dead (should never be seen)
Z    defunct ("zombie") process, terminated but not reaped by its parent.
```

További, BSD formátum esetén megjelenő karakterek:

```text
<    high-priority (not nice to other users)
N    low-priority (nice to other users)
L    has pages locked into memory
s    is a session leader
l    is multi-threaded
+    is in the foreground process group
```

### `top`

```bash
top
```

A `top` folyamatosan frissülő információt ad a folyamatokról és a rendszer erőforrás-használatáról.

A megjelenített információk között többek között CPU-, memória- és processzinformációkat láthatunk. A frissítési időköz módosítható.

Kilépés:

```text
q
```

### `htop`

```bash
htop
```

A `htop` interaktív folyamatnéző, amely a folyamatokat áttekinthetőbb, színesebb felületen jeleníti meg, és a CPU-, memória- és swap-használatról is ad információt.

---

## Process erőforrás-felhasználás

```bash
time <parancsnév>
```

Ha egy parancs elé a `time` kulcsszót írjuk, a program befejezése után statisztikai adatokat kapunk a futásáról. Többek között megmutatja, mennyi valós idő telt el, illetve mennyi CPU-időt használt a program felhasználói és rendszermódban.

### Példa

```bash
time ls
```

A legfontosabb értékek:

- **real** – az eltelt valós idő
- **user** – felhasználói módban felhasznált CPU-idő
- **sys** – rendszermódban, vagyis kernelműveletek végrehajtására felhasznált CPU-idő

---

## `strace`

```bash
strace <parancsnév>
```

A `strace` hibakereséshez és a program működésének vizsgálatához használható. A futtatott program által végrehajtott **rendszerhívásokat (system calls)** és azok eredményét jeleníti meg.

### Példák

```bash
strace ls
```

A kimenet fájlba menthető:

```bash
strace -o output.txt ls
```

Gyakran látható rendszerhívások:

- **open / openat** – fájl megnyitása
- **read** – adat olvasása file descriptorból
- **write** – adat írása file descriptorba
- **close** – file descriptor lezárása
- **stat / lstat** – fájl vagy könyvtár adatainak lekérdezése
- **access** – hozzáférési jogosultság vizsgálata
- **ioctl** – eszköz- vagy I/O-vezérlés
- **mmap** – memória- és fájlleképezés

### `mmap`

Az `mmap` egy Linux/Unix rendszerhívás, amely lehetővé teszi fájlok vagy egyéb objektumok leképezését a folyamat virtuális címtartományába. Így a leképezett terület a program számára memórián keresztül is elérhetővé válik.

---

# Programok indítása

## Programok indítása előtérben

A program alapértelmezés szerint az előtérben (**foreground**) fut.

Amíg az előtérben futó program be nem fejeződik, a shellben nem kapunk új parancssort. Az előtérben futó jobhoz tartozik a terminál vezérlése, ezért a billentyűzetről érkező vezérlőjelek is ehhez a jobhoz kapcsolódhatnak.

Egy korábban háttérbe tett vagy megállított jobot az `fg` paranccsal hozhatunk előtérbe:

```bash
fg
```

vagy megfelelő jobazonosítóval:

```bash
fg %1
```

## Programok indítása háttérben

Háttérben (**background**) úgy indíthatunk programot, hogy a parancs végére `&` jelet írunk:

```bash
sleep 20 &
```

Így a shell azonnal visszaadja a parancssort, és közben a `sleep` a háttérben fut.

### Példa

1. Adjuk ki:

```bash
sleep 20
```

A parancs 20 másodpercig előtérben fut, ezért a shell vezérlését csak ezután kapjuk vissza.

2. Adjuk ki:

```bash
sleep 20 &
```

A `&` miatt a parancs háttérben indul, így közben tovább használhatjuk a terminált.

A shell általában két azonosítót írhat ki:

- az első a **job azonosítója** a shellben,
- a második a rendszerben érvényes **PID**.

---

# Jelek - Signals

A Unix/Linux rendszer a folyamatok vezérlésére többek között **jeleket (signals)** használ.

A signal egy szoftveres értesítés egy folyamat számára arról, hogy valamilyen esemény történt, vagy a folyamatnak valamilyen műveletet kell végrehajtania.

A jelek érkezhetnek például felhasználói művelet, terminálvezérlés vagy rendszerhiba miatt.

| Signal | Szám | Leírás |
|---|---:|---|
| `SIGHUP` | 1 | A terminálkapcsolat megszakadásához kapcsolódó jel |
| `SIGINT` | 2 | Megszakítás; terminálon tipikusan `Ctrl+C` |
| `SIGQUIT` | 3 | Kilépési jel; terminálon tipikusan `Ctrl+\` |
| `SIGFPE` | 8 | Hibás aritmetikai művelethez kapcsolódó jel |
| `SIGKILL` | 9 | Azonnali leállítás; nem kezelhető és nem ignorálható |
| `SIGALRM` | 14 | Időzítő lejárásához kapcsolódó jel |
| `SIGTERM` | 15 | A folyamat szabályos leállítására szolgáló jel |

> **Fontos:** `Ctrl+D` nem `SIGQUIT`. A `Ctrl+D` a terminálon EOF (End of File) jelzésként működik.

A rendszer által támogatott signalok listája:

```bash
kill -l
```

Minden signalhoz tartozik egy alapértelmezett művelet. A program bizonyos signalok esetén saját signal-handlert is beállíthat, illetve egyes jeleket figyelmen kívül hagyhat.

A `SIGKILL` és `SIGSTOP` különlegesek: ezeket a folyamat nem tudja kezelni vagy figyelmen kívül hagyni.

## Signal küldése

Az egyik leggyakoribb módszer a `kill` parancs:

```bash
kill -signal pid
```

### Példa

```bash
kill -1 1001
```

Ez `SIGHUP` jelet küld az 1001-es PID-del rendelkező folyamatnak.

```bash
kill -9 1001
```

Ez `SIGKILL` jelet küld a folyamatnak, amelyet a kernel azonnal leállít. A folyamatnak nincs lehetősége cleanup műveleteket végrehajtani.

> **Javasolt gyakorlat:** normál leállításra általában először `SIGTERM` használatos:
>
> ```bash
> kill 1001
> ```
>
> A `kill` alapértelmezés szerint `SIGTERM` jelet küld. A `SIGKILL` inkább végső megoldás, ha a folyamat nem reagál.

### Saját folyamatok és jogosultságok

Alapesetben egy felhasználó a saját folyamatait vezérelheti. Megfelelő jogosultsággal más felhasználó folyamatai is kezelhetők.

---

# Csapdák - Felülírások szignálok esetén

Shell scriptekben a `trap` paranccsal megadhatjuk, hogy egy signal érkezésekor milyen műveletet hajtson végre a shell.

Ez különösen hasznos lehet ideiglenes fájlok törlésére vagy más cleanup műveletekre.

### Példa

```bash
trap 'rm -f "$WORKDIR/work1$$" "$WORKDIR/dataout$$"; exit' 2
```

A fenti példa azt mondja meg, hogy `SIGINT` (2-es signal) érkezésekor a megadott ideiglenes fájlokat törölje, majd lépjen ki.

A `$$` a shell aktuális processzazonosítóját jelenti, ezért gyakran használják ideiglenes fájlok nevének egyedivé tételére.

Egy egyszerűbb példa:

```bash
trap 'echo ELTE!' 2
```

Ezután `Ctrl+C` megnyomásakor az `ELTE!` szöveget írja ki.

A trap visszaállítása az alapértelmezett kezelésre:

```bash
trap - 2
```

vagy:

```bash
trap - SIGINT
```

---

# Midnight Commander (`mc`)

A **Midnight Commander** egy kétpaneles, interaktív fájlkezelő program. Hasonlít a klasszikus Norton Commanderhez.

Használható többek között:

- fájlok és könyvtárak kezelésére,
- fájlok másolására és mozgatására,
- fájlok megtekintésére és szerkesztésére,
- távoli fájlrendszerekkel való munkára.

Telepítés Debian/Ubuntu rendszeren:

```bash
sudo apt install mc
```

Indítás:

```bash
mc
```

A két panel lehet lokális fájlrendszer, illetve megfelelő konfigurációval távoli fájlrendszer is.

---

# Sorok manipulációja - Szűrők

## 1. Számoljuk meg az aktuális könyvtárban lévő bejegyzések számát.

### Megoldás

```bash
ls | wc -l
```

`wc -l` a bemenet sorainak számát számolja.

> **Megjegyzés:** Ez egy egyszerű oktatási megoldás, de nem minden esetben adja meg pontosan a könyvtár bejegyzéseinek számát, mert az `ls` kimenete formázástól és környezettől is függhet.

---

## 2. Listázzuk ki az aktuális könyvtár alkönyvtárait!

### Megoldás

```bash
find . -type d -not -path '*/.*' | grep -v 'temp'
```

A fenti parancs könyvtárakat keres az aktuális könyvtár alatt, a rejtett útvonalakat pedig kiszűri. A `grep -v 'temp'` a `temp` szöveget tartalmazó sorokat hagyja ki.

> **Megjegyzés:** A `find` ettől még a rejtett könyvtárakba is beléphet; a parancs csak a kimenetből szűri ki az ilyen útvonalakat.

Ha például egy konkrét könyvtárat szeretnénk vizsgálni:

```bash
find laszlo -type d -not -path '*/.*' | grep -v 'temp'
```

---

## 3. Listázzuk ki a bejelentkezett felhasználók azonosítóját és csak azt!

### Megoldás

```bash
who
```

A `who` a bejelentkezett felhasználói sessionöket jeleníti meg.

---

## 4. Listázzuk ki egy tetszőleges szöveges fájl sorait abc sorrendbe!

### Megoldás

```bash
sort file.txt
```

Fordított sorrend:

```bash
sort -r file.txt
```

> **Megjegyzés:** A `sort` alapértelmezés szerint szöveges/lexikografikus sorrendet használ. Numerikus rendezéshez például a `-n` kapcsoló használható.

### Példa – szöveges és numerikus rendezés

Ha a `numbers.txt` tartalma:

```text
10
2
30
4
```

```bash
sort numbers.txt
```

Eredménye:
```text
10
2
30
4
```

Ez azért van, mert a sort alapértelmezés szerint szövegként hasonlítja össze a sorokat.

Ha numerikusan szeretnénk rendezni:

```bash
sort -n numbers.txt
```

Eredménye:
```text
2
4
10
30
```

---

## 5. Cseréljük ki egy fájlban lévő karaktereket a nagybetűs párjukra!

### Megoldás

```bash
tr '[:lower:]' '[:upper:]' < file.txt > output.txt
```

`tr` → karakterek átalakítására/transzformálására használható.

- `< file.txt` → a `file.txt` tartalma a parancs standard inputjára kerül.
- `> output.txt` → a standard output az `output.txt` fájlba kerül.

A `tr` nem közvetlenül a fájlt módosítja, hanem a bemenetből olvas és az átalakított eredményt a kimenetre írja.

---

## 6. Számoljuk meg, hogy egy fájlban hány olyan sor van, amelyik az `alma` szót tartalmazza és semmi mást!

### Megoldás

```bash
grep -cx 'alma' apples.txt
```

Alternatív, kétlépéses megoldás:

```bash
grep -x 'alma' apples.txt | wc -l
```

- `grep` → mintára illeszkedő sorokat keres.
- `-x` → a **teljes sornak** meg kell egyeznie a mintával.
- `-c` → a megfelelő sorok számát írja ki.

> **Fontos:** A `grep -o 'alma' apples.txt | wc -l` nem pontos erre a feladatra, mert az `alma` szó előfordulásait számolja, nem azokat a sorokat, amelyek kizárólag az `alma` szót tartalmazzák.





> **Mikor lenne hasznos a `grep -o`?**
>
> Ha nem a megfelelő sorok számát, hanem a keresett szó **összes előfordulását** szeretnénk megszámolni, akkor a `grep -o` jó megoldás.
>
> Például ha az `apples.txt` tartalma:
>
> ```text
> alma körte alma
> körte alma
> alma
> ```
>
> akkor:
>
> ```bash
> grep -o 'alma' apples.txt | wc -l
> ```
>
> eredménye:
>
> ```text
> 4
> ```
>
> Itt az `alma` szó összes előfordulását számoljuk meg, nem azt, hogy hány sor tartalmazza kizárólag az `alma` szót.

---

## 7. Csak az egészeket tartalmazó sorokat szűrje ki és jelenítse meg egy `numbers.txt` fájlból.

### Megoldás

```bash
grep -E '^[0-9]+$' numbers.txt
```

Ha fájlba szeretnénk menteni:

```bash
grep -E '^[0-9]+$' numbers.txt > filtered_file.txt
```

A reguláris kifejezés részei:

- `^` → a sor eleje
- `[0-9]` → egy számjegy
- `+` → egy vagy több előfordulás
- `$` → a sor vége

Ezért a teljes sornak egy vagy több számjegyből kell állnia.

> **Megjegyzés:** Ez a megoldás a nemnegatív, előjel nélküli egész számokat (`0`, `12`, `123` stb.) kezeli. A `-12` például nem illeszkedik erre a mintára.


### Extra – negatív egész számok kezelése

Ha a negatív egész számokat is szeretnénk elfogadni, a `-` jelet opcionálissá tehetjük:

```bash
grep -E '^-?[0-9]+$' numbers.txt
```

A `?` azt jelenti, hogy az előtte álló - jel `0 vagy 1 alkalommal` szerepelhet.

Így például az alábbi sorok illeszkednek:

```text
0
12
123
-5
-42
-100
```

Míg például ezek nem:

```text
12.5
+10
abc
10a
```


**Egy apró pontosítás:** ha a `+10`-et is egész számként szeretnéd elfogadni, arra külön regex kell:

```bash
grep -E '^[+-]?[0-9]+$' numbers.txt
```

Regexek gyakorlásához:

https://regex101.com/
