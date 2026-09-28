#!/bin/bash
# Szövegek (stringek) összefűzése.
#
# Futtatás:
#   ./4_string_combine.sh

# Értékadásnál az = jel körül NEM lehet szóköz.
string1="ELTE "
string2="IK"

# 1. Összefűzés egyszerűen egymás mellé írással.
echo "$string1$string2"

# 2. Összefűzés új változóba. A ${valtozo} forma egyértelművé teszi,
#    hogy hol ér véget a változó neve (pl. "${string2}_2024").
string3="${string1}${string2}"

# 3. Hozzáfűzés meglévő változóhoz a += operátorral.
string3+=" University"
echo "$string3"

# A szöveg hossza: ${#valtozo}
echo "Length: ${#string3}"

# Idézőjelek közti különbség:
#   "..."  a változók behelyettesítődnek
#   '...'  minden karakter szó szerint értendő
echo "Double quotes: $string2"
echo 'Single quotes: $string2'
