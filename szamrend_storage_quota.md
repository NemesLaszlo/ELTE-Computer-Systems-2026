# Tárhely (kvóta) probléma a szerveren / Disk quota problem on the server

- [Magyar](#magyar)
- [English](#english)

---

## Magyar

### A probléma

Előfordulhat, hogy a `szamrend.inf.elte.hu` szerveren betelik a felhasználói kvótád, és ezután **nem tudsz új fájlt létrehozni vagy feltölteni** (a szerkesztő nem tud menteni, a `touch`, `mkdir`, `cp` parancsok hibát adnak, stb.).

Bejelentkezéskor ilyesmi figyelmeztetést láthatsz:

```text
Disk quotas for user abc123 (uid 49622): none
Volume Name                  Quota       Used  %Used   Partition
user.abc123                 512000     512136  100%<<       44%    <<WARNING
```

- **Quota** – a rendelkezésedre álló hely (KB-ban, itt kb. 500 MB)
- **Used** – az általad jelenleg használt hely
- **%Used** – ha eléri a `100%`-ot, nem tudsz több adatot írni

A kvótát bármikor újra megnézheted a `quota` paranccsal.

> **Fontos:** Első ránézésre gyakran nem látszik olyan fájl, ami miatt betelt volna a hely. Ennek oka, hogy a helyet többnyire **rejtett mappák** (`.`-tal kezdődő nevűek) foglalják, amiket az `ls` alapból nem mutat. Ezeket az `ls -a` paranccsal láthatod.

### Melyik mappa foglalja a helyet?

Lépj a home könyvtáradba, és nézd meg az egyes mappák méretét:

```bash
cd ~
find . -mindepth 1 -maxdepth 1 -type d -exec du -sm {} + | sort -nr
```

Ez a home könyvtárad összes közvetlen almappáját (a rejtetteket is) kilistázza, méret szerint csökkenő sorrendben, MB-ban.

Alternatívák:

```bash
du -hsc *           # a látható fájlok/mappák mérete + összesen
du -hsc .[!.]*      # a rejtett fájlok/mappák mérete + összesen
```

> A `du -hsc *` **nem** veszi figyelembe a rejtett mappákat, ezért érdemes a fenti `find` parancsot vagy a `.[!.]*` mintát is használni.

### A leggyakoribb bűnös: a `.cache` mappa

A `~/.cache` mappa szokott a leghamarabb megtelni. Többnyire a **Chrome, Firefox, MS Teams és VS Code** gyorsítótárai (cache) vannak benne. Nézd meg, mi foglal benne sok helyet:

```bash
du -hsc ~/.cache/*
```

Ezután a nagy méretű mappák törölhetők, például:

```bash
rm -rf ~/.cache/google-chrome
rm -rf ~/.cache/mozilla
```

Vagy akár a teljes cache tartalma is:

```bash
rm -rf ~/.cache/*
```

A `.cache` tartalmát a programok szükség esetén újra létrehozzák, így törlése **nem okoz adatvesztést**.

> **Figyelem:** Az `rm -rf` visszavonhatatlanul töröl! Mindig ellenőrizd, hogy pontosan azt a mappát adtad-e meg, amit törölni szeretnél. Saját munkáidat (scriptek, házi feladatok) ne töröld.

Egyéb gyakori helyfoglalók:

| Mappa | Tartalom | Törölhető? |
|---|---|---|
| `~/.cache` | Böngészők, Teams, VS Code gyorsítótára | Igen |
| `~/.vscode-server` | VS Code Remote-SSH szerveroldali része | Igen, a következő csatlakozáskor újratelepül |
| `~/.local/share/Trash` | A grafikus felület lomtára | Igen (ezzel véglegesen törlöd a lomtár tartalmát) |

A törlés után ellenőrizd újra a kvótát a `quota` paranccsal – ha 100% alá csökkent, minden menni fog.

### Ha a laborgépen nem tudsz grafikusan belépni

Ha a kvóta betelt, a grafikus felületre való bejelentkezés is sikertelen lehet. Ilyenkor:

1. Nyomd meg a `Ctrl + Alt + F1` … `Ctrl + Alt + F6` billentyűkombinációk egyikét – ezzel karakteres (szöveges) konzolra váltasz.
2. Jelentkezz be a felhasználóneveddel és jelszavaddal.
3. Töröld a felesleges fájlokat a fent leírtak szerint.
4. Az `Alt + F7` kombinációval visszaválthatsz a grafikus felületre, és a bejelentkezés már működni fog.

> A **laborgépeken** csak a `Ctrl + Alt + F1` és a `Ctrl + Alt + F6` működik.

A fenti takarítás a **pandora**, **opsys**, **szamrend** és **labor** gépeken is elvégezhető.

### Röviden

```bash
quota                                                              # kvóta ellenőrzése
cd ~
find . -mindepth 1 -maxdepth 1 -type d -exec du -sm {} + | sort -nr  # mi foglalja a helyet?
du -hsc ~/.cache/*                                                 # mi van a cache-ben?
rm -rf ~/.cache/<mappa>                                            # felesleges cache törlése
quota                                                              # ellenőrzés újra
```

---

## English

### The problem

Your user quota on the `szamrend.inf.elte.hu` server may fill up, after which you **cannot create or upload new files** (your editor cannot save, commands like `touch`, `mkdir`, `cp` fail, etc.).

When you log in, you may see a warning like this:

```text
Disk quotas for user abc123 (uid 49622): none
Volume Name                  Quota       Used  %Used   Partition
user.abc123                 512000     512136  100%<<       44%    <<WARNING
```

- **Quota** – the space available to you (in KB, here about 500 MB)
- **Used** – the space you are currently using
- **%Used** – once it reaches `100%`, you cannot write any more data

You can check your quota at any time with the `quota` command.

> **Important:** At first glance you often won't see any file that could have filled up the space. This is because the space is usually taken by **hidden directories** (names starting with `.`), which `ls` does not show by default. Use `ls -a` to see them.

### Which directory is using the space?

Go to your home directory and check the size of each directory:

```bash
cd ~
find . -mindepth 1 -maxdepth 1 -type d -exec du -sm {} + | sort -nr
```

This lists every direct subdirectory of your home directory (including hidden ones), sorted by size in descending order, in MB.

Alternatives:

```bash
du -hsc *           # size of visible files/directories + total
du -hsc .[!.]*      # size of hidden files/directories + total
```

> `du -hsc *` does **not** include hidden directories, so it is worth using the `find` command above or the `.[!.]*` pattern as well.

### The usual culprit: the `.cache` directory

The `~/.cache` directory is usually the first to fill up. It mostly contains the caches of **Chrome, Firefox, MS Teams and VS Code**. Check what is taking up space in it:

```bash
du -hsc ~/.cache/*
```

Then delete the large directories, for example:

```bash
rm -rf ~/.cache/google-chrome
rm -rf ~/.cache/mozilla
```

Or even the entire contents of the cache:

```bash
rm -rf ~/.cache/*
```

Programs recreate the contents of `.cache` when needed, so deleting it **does not cause data loss**.

> **Warning:** `rm -rf` deletes permanently! Always double-check that you specified exactly the directory you want to delete. Do not delete your own work (scripts, assignments).

Other common space consumers:

| Directory | Contents | Safe to delete? |
|---|---|---|
| `~/.cache` | Browser, Teams, VS Code caches | Yes |
| `~/.vscode-server` | Server-side part of VS Code Remote-SSH | Yes, it is reinstalled on your next connection |
| `~/.local/share/Trash` | Trash of the graphical desktop | Yes (this permanently empties your trash) |

After deleting, check your quota again with `quota` – once it is below 100%, everything will work again.

### If you cannot log in graphically on a lab machine

If your quota is full, logging in to the graphical desktop may also fail. In that case:

1. Press one of `Ctrl + Alt + F1` … `Ctrl + Alt + F6` – this switches to a text console.
2. Log in with your username and password.
3. Delete unnecessary files as described above.
4. Press `Alt + F7` to switch back to the graphical desktop – logging in will now work.

> On the **lab machines** only `Ctrl + Alt + F1` and `Ctrl + Alt + F6` work.

The cleanup above can be done on the **pandora**, **opsys**, **szamrend** and **lab** machines.

### Summary

```bash
quota                                                              # check your quota
cd ~
find . -mindepth 1 -maxdepth 1 -type d -exec du -sm {} + | sort -nr  # what is using the space?
du -hsc ~/.cache/*                                                 # what is in the cache?
rm -rf ~/.cache/<directory>                                        # delete unneeded cache
quota                                                              # check again
```
