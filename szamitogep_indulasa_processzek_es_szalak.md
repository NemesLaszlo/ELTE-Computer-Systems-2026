# A számítógép indulásának fő lépései

1. **Power button → firmware indul**
   - A bekapcsolás után az alaplap firmware-e (**UEFI/BIOS**) veszi át a vezérlést.
   - Inicializálja és ellenőrzi a szükséges hardvereket: CPU, RAM, GPU, háttértárak stb.
   - RAM esetén például megtörténhet a **memory training**, ahol a rendszer megpróbálja megfelelően beállítani a memóriát.
   - Hiba esetén az alaplap **hibakóddal, LED-del vagy sípolással (beeper)** jelezheti a problémát.

2. **Boot device kiválasztása → bootloader**
   - A firmware megkeresi a konfiguráció alapján azt az eszközt, amelyről az operációs rendszer indítható.
   - Modern UEFI rendszereknél általában az SSD-n található **EFI bootloader** indul el.
   - A bootloader feladata, hogy betöltse és elindítsa az operációs rendszer kernelét.

3. **Kernel betöltése és hardver inicializálása**
   - Az operációs rendszer **kernelje** átveszi a vezérlést.
   - Inicializálja és kezeli a hardvereket, valamint betölti a szükséges drivereket/modulokat.
   - Felállnak az operációs rendszer alapvető komponensei: memória-kezelés, processzek, fájlrendszerek, hálózat stb.

4. **Rendszerszolgáltatások elindítása**
   - Linuxon például az **`init`/systemd** indítja el a rendszer további szolgáltatásait.
   - A klasszikus Unix/Linux modellben az **init PID-je 1**, és a systemd is jellemzően PID 1-ként fut.
   - Elindulhatnak például:
     - hálózati szolgáltatások,
     - SSH,
     - naplózás,
     - grafikus környezethez szükséges szolgáltatások,
     - egyéb háttérben futó daemonok.

5. **Bejelentkezési felület**
   - A rendszer eljut a **login screenhez**.
   - Itt a felhasználó hitelesíti magát.
   - A rendszer létrehozza/indítja a felhasználói környezethez szükséges processzeket és szolgáltatásokat.

6. **Desktop Environment betöltése**
   - Ha grafikus Linux rendszerről beszélünk, elindul a **Desktop Environment (DE)**, például GNOME vagy KDE Plasma.
   - Ez biztosítja azt a grafikus környezetet, ahol ablakokat nyitunk, kattintunk, alkalmazásokat indítunk és interakcióba lépünk a rendszerrel.
   - Eközben további felhasználói és rendszerfolyamatok, illetve háttérszolgáltatások is elindulhatnak.

**Nagyon leegyszerűsítve tehát:**

**Power → UEFI/BIOS → hardver inicializálás → bootloader → kernel → system services → login → desktop environment → felhasználói alkalmazások**

---

# Processzek és szálak

Az operációs rendszerben érdemes különválasztani a **processzt (folyamatot)** és a **szálat (thread)**.

### Process (folyamat)

- A process egy futó program **elszigetelt végrehajtási környezete**.
- Saját virtuális címtérrel, erőforrásokkal és processzazonosítóval (**PID**) rendelkezik.
- POSIX rendszereken egy új processz létrehozásának klasszikus mechanizmusa a **`fork()`**.
- Fontos pontosítás: a `fork()` nem azt jelenti, hogy a teljes fizikai memória azonnal lemásolódik. A modern POSIX rendszerek jellemzően **copy-on-write (COW)** mechanizmust használnak: kezdetben a szülő és a gyermek megosztja a memórialapokat, és csak módosításkor készül tényleges másolat.
- A Windows hagyományosan nem a POSIX-féle `fork()` modellt használja. Új processzt például a **`CreateProcess()`** segítségével hoz létre, és a folyamat saját virtuális címtérrel rendelkezik.

### Thread (szál)

- A thread a processzen belüli **végrehajtási egység**.
- Egy processzen belül több thread is futhat párhuzamosan vagy konkurensen.
- A threadek **megosztják a processz címtérét és erőforrásainak jelentős részét**, ezért nincs szükség a processz teljes memóriájának lemásolására.
- Ugyanakkor minden threadnek van saját végrehajtási állapota, például **saját stackje, regiszterállapota és program countere (instruction pointere)**.
- A program létrehozhat több threadet, és az egyes threadeknek különböző feladatokat delegálhat.

### A legfontosabb különbség

| Process | Thread |
|---|---|
| Önálló végrehajtási környezet | Processzen belüli végrehajtási egység |
| Saját virtuális címtér | Megosztja a processz címtérét |
| Erősebb izoláció | Könnyebb kommunikáció |
| Létrehozása általában költségesebb | Létrehozása általában olcsóbb |
| Saját PID | Saját végrehajtási állapot és thread-azonosító |
| Más processz memóriáját alapból nem látja | A processz közös memóriáját látja |

**Egyszerű hasonlat:**

> A **process** egy külön iroda, saját helyiséggel és erőforrásokkal.  
> A **threadek** ugyanabban az irodában dolgozó emberek: közös erőforrásokat használnak, de mindegyiküknek saját feladata és saját végrehajtási állapota van.
