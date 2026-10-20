#!/bin/bash
# 1. feladat: Köszöntés.
# A script paraméterként egy nevet vár, és köszönti az illetőt.
# Ha nem kap paramétert, a bejelentkezett felhasználó nevét használja.
#
# Futtatás:
#   ./1_greeting.sh Laszlo     -> Hello Laszlo!
#   ./1_greeting.sh            -> Hello <felhasználónév>!

# ${1:-$USER}: ha van első paraméter, azt használjuk, különben a USER
# környezeti változó értékét (alapértelmezett érték megadása).
# Ugyanezt if-fel is leírhatnánk, de így egyetlen sor.
name=${1:-$USER}

echo "Hello $name!"
