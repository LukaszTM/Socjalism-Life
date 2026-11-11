class_name PozycjaDostawy
extends Resource
## Jedna linia dostawy: jaki przedmiot i ile sztuk. Osobny zasób, żeby w inspektorze
## dało się wygodnie układać zestawy bez równoległych list.

@export var przedmiot: Przedmiot
@export_range(1, 99) var ilosc: int = 1
