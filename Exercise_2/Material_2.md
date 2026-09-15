### ELTE bejelentkezési adatok:

szamrend.inf.elte.hu

bejelentkezés/jelszó: INF domain azonosító/jelszó

Kettő opcióval kivitelezhető: Putty alkalmazás segítésgével, vagy terminálban `ssh` parancs használatával.

SSH paranccsal:
```
ssh [infes_azonosító (kisbetűvel a neptun code)]@szamrend.inf.elte.hu
```
Példa:
```
Példa: ssh 123abc@szamrend.inf.elte.hu
```

---

### Bevezetés

Unix - 1969-ben kifejlesztett operációs rendszer

Linux - Maga a kernel, amire épülnek a különböző disztribúciók pl. Ubuntu, Manjaro, Arch etc.

Windows - A Microsoft lemezes operációs rendszere, az MS-DOS

---

### Shell, Shell script, PowerShell

Shell - Unix alapú operációs rendszerek parancs gyűjteménye, amelyeket scripben foglalva egymás után futtathatunk le (.sh)
később ezek bővítésre kerültek és megjelentek egyéb shellek mint pl. a zsh amit a Mac OS is átvett nem olyan régen.

PowerShell - egy többplatformos feladat automatizálási megoldás, amely egy parancssori shellből, egy szkript nyelvből és egy konfigurációkezelési keretrendszerből áll

---

### UNIX alapú rendszerek, Linux disztribúciók

Linux disztribúciók szerkezete: kernel, parancsértelmező (shell), programok

- A kernel végzi a rendszer erőforrásainak megosztását és a futó folyamatok ütemezését, valamint a felhasználói programok számára egy interfészt biztosít a hardver felé
- A kernel körül helyezkedik el a shell (héj, burok) ami biztosítja a kapcsolatot a felhasználó és a kernel között.


Fontosabb könyvtárak különböző Linux disztibúciókon:

```

/                    - A főkönyvtár, a könyvtárfa kiindulópontja
/home                - Ehhez csatlakoznak a felhasználók könyvtárai
/dev                 - A hardvereszközöket reprezentáló fájlok
/etc                 - A legfontosabb konfigurációs fájlok
/usr/bin             - Közhasználatú parancsok
/usr/doc             - Dokumentációs fájlok
/usr/local/man       - Kézikönyv oldalak
/sbin                - A superuser és a rendszerindító parancsok
/tmp                 - Ideiglenes fájlok
/var                 - Konfigurációs fájlok (Linkek az /usr-ből)
/lib                 - Megosztott programkönyvtárak
/proc                - A processzek fájlrendszere
/opt                 - Kiegészítő alkalmazásszoftver-csomagok telepítésére van fenntartva

```

#### Alap parancsok:


##### Jelszavak 

```
passwd - Beállítja és módosítja a felhasználók jelszavait

kpasswd - megváltoztatja egy megadott Kerberos-tag jelszavát (Kerberos principal)

```

You must use passwd if you want to change your UNIX password.
With kpasswd can change a password for a Kerberos principal that is not a valid UNIX user

Traditionally, a principal is divided into three parts: the primary, the instance, and the realm. The format of a typical Kerberos V5 principal is primary/instance@REALM.


A Kerberos egy számítógépes hálózati hitelesítési protokoll, amely egy nem biztonságos hálózaton keresztül úgy teszi lehetővé a csomópontok közötti kommunikációt, hogy biztonságos módon igazolják személyazonosságukat egymás felé

##### Felhasználó, és elérési út

```
who vagy whoami - Meghíváskor kiírja az aktuális felhasználó aktuális felhasználónevét

pwd - szabványos kimenetre írja az aktuális könyvtár teljes elérési útját (a gyökérkönyvtárból)

```

##### Listázások

```

ls  - fájlok felsorolására használják (könyvtárak, fájlok etc.)

ls -l - lehetővé teszi a felhasználók számára a könyvtár tartalmának felsorolását

ls -al vagy -a - felsorolja az összes fájlt, beleértve a ponttal kezdődő fájlokat is (azaz a rejtett fájlokat).


```

ls -l estén a kövezkező oszpolokat látjuk:

- File Type and Permissions
- Number of Hard Links
- Owner
- Group 
- File Size in Bytes
- Modification Date and Time 
- File/Directory Name

##### Fájl létrehozása VIM (Vim is a free and open-source, screen-based text editor program) segítségével

Fájl létrehozása:
```
vim a.txt
```
Ekkor megnyilik az editor felülete a vimnek.

- Ahhoz, hogy tartalmat tudjunk begépelni a text fájlunkba, meg kell nyomnunk az `i` betűt azaz, `INSERT`.
- Ezt követően begépelhetjük a szövegünket, vagy módosíthatjuk azt.
- Ha befejeztük a módosításainkat, szövegbevitelt, akkot az `Esc` gombbal ki tudunk lépni az `INSERT` módból.
- Írjunk egy `:` (kettőspont) karaktert, majd adjuk ki a következő parancsot a vim számára, hogy a módosításainkat mentse majd lépjen ki: `wq`. Egyben amit írni kell: `:wq`
- A vim bezáródik és újra a terminál felületünket láthatjuk.


In Vim, `:wq` is a command used to save (write) the changes made to the file and then quit the editor. Here's a breakdown:

- `:w` stands for "write", which saves the file.
- `:q` stands for "quit", which closes the editor.


##### Mappák, másolások, mozgatások

```
cd - lehetővé teszi a könyvtárak közötti mozgást

mkdir - mappa létrehozása

rmdir - mappa törlése -> ha nem üres hibát dob

rm -r - törlés a contextel együtt

rm * - minden törlése az aktuális könyvtárból

cp - másolás pl. cp a.txt b.txt ('a.txt' teljes tartalmával létrejön egy 'b.txt' nevű másolat)

mv - mozgatás pl. mv a.txt test2 (az 'a.txt' filet átmásolja a 'test2' mappába)

cat - fájl tartalmának megnézése

tail - alapértelmezett esetben a fájl utolsó 10 sorát jeleníti meg, pl. tail -n 2 a.txt (az 'a.txt' fájl utolsó kettő sorát írja ki)

```

#### Tartalom mentése, megjelenítése

```

pwd - nézzük meg "hol is vagyunk pontosan"

ls /home/laszlo/test > /home/laszlo/saved_content (a test mappa tartalmát egy 'save_content' fájlba menti)

more /saved_content (megjeleníti a fájl tartalmát)

```

Ugyan ezt lehet pipeline-al összekövtve is, a fájlba mentés kihagyásával

```

ls /home/laszlo/test | more (kilistázza a 'test' könyvtár tartalmát és megjeleníti azt - pipelineként összekötöttünk két műveleti lépést)

```

#### Csomagolásra egy példa

```

zip -r archive_name.zip folder_to_zip (megadjuk mi legyen a .zip fájl neve, majd azt amit csomagolunk mappa nevét)

```

Ha nincs zip programunk, akkor a megfelelő package managerrel telepítsük fel.
Ubuntun pl. sudo apt-get install zip

A sudo (superuser do or substitute user do) egy olyan alkalmazás az Unix-szerű operációs rendszert futtató számítógépek számára, amely lehetővé teszi egy felhasználó számára, hogy egy másik felhasználó biztonsági jogosultságaival futtasson programokat. 

#### Jogosultságok

https://www.onlineconversion.com/html_chmod_calculator.htm

```

chmod +x a.txt (execute (végrehajtási) jogosultságot adtunk az ownernek az a.txt fájlra mint példa)

chmod 644 file_név - Olvasási és írási jogosultságot ad a tulajdonos, csak olvasási jogosultságot ad minden egyéb felhasználó számára

chown - tulajdonjog megváltoztatása (chown owner_name file_name)

```

---

#### SMTP és IMAP

###### Bevezető röviden:

Az IMAP az üzenetek lekérésére, az SMTP pedig az adatok küldésére szolgál.

Az IMAP a szerver és a kliens között működik a kommunikációban vállal szerepet.
Az SMTP pedig a szerverek között az információk átvitelében.

Az IMAP lehetővé teszi a felhasználók számára az e-mailek rendszerezését a szerveren, míg az SMTP lehetővé teszi az e-mailek klienstárhelyen történő rendszerezését.

###### Pontosabban:

SMTP

SMTP (Simple Mail Transfer Protocol) is a widely used TCP protocol for sending e-mails. The SMTP protocol is primarily used for clients to send e-mails to servers or for e-mail communication between servers.
There are 2 types of SMTP servers: Relays and Receivers. 

The SMTP workflow consists of 3 steps:

- The SMTP client will connect to the SMTP server.
- The email is transferred using that connection.
- The client and the server terminate the connection.

SMTP client uses text-based commands such as HELLO, MAIL FROM, EHLO, and RCPT to send messages to the SMTP server. SMTP server responds to these messages using numeric codes like 220, 250, and 354.


IMAP

The Internet Message Access Protocol, also known as IMAP, is a protocol for receiving emails from a server. Since IAMP allows access to emails from multiple locations simultaneously, it keeps the email on the server after being delivered. Also, it doesn't;t download the entire email until the recipient opens it.

Currently, the 4th version of the IMAP protocol is in use, and it is one of the most used protocols for email receiving.


POP3

Post Office Protocol is a more user-friendly method of accessing mailboxes. Version 3 is the most widely used version of this standard, and it is popular among users due to its low reliance on Internet connections. POP3 transfers emails from the server to the client, allowing you to read them even if you are not connected to the internet.
