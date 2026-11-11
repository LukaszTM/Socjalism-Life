#!/bin/bash
# Uruchamia test bez okna. Użycie: testy/uruchom.sh test_regresja
# Godot bierze z zmiennej GODOT albo z polecenia `godot` w PATH.
set -u
G="${GODOT:-godot}"
cd "$(dirname "$0")/.."
"$G" --headless --path . --import >/dev/null 2>&1
"$G" --headless --path . "res://testy/$1.tscn" 2>&1 | grep -vE "^\s*$|Godot Engine"
echo "kod wyjscia: ${PIPESTATUS[0]}"
