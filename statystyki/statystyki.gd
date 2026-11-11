extends Node
## Statystyki tygodnia (autoload `Statystyki`): liczby na ekran końca.
## Moduły same je zgłaszają (sklep, zakład, rozmowa), tak jak zgłaszają czas zegarowi.

var minuty_w_kolejkach: int = 0
var zakupy: int = 0
var odejscia_z_niczym: int = 0
var wymiany: int = 0
var prezenty: int = 0
var zmiany_w_pracy: int = 0
var zalatwione: int = 0
var wpadki: int = 0


func resetuj() -> void:
	minuty_w_kolejkach = 0
	zakupy = 0
	odejscia_z_niczym = 0
	wymiany = 0
	prezenty = 0
	zmiany_w_pracy = 0
	zalatwione = 0
	wpadki = 0


## Gotowe linie do wyświetlenia, żeby ekran końca nie musiał znać pól.
func podsumowanie() -> Array[String]:
	return [
		"Czas w kolejkach: %d h %02d min" % [minuty_w_kolejkach / 60, minuty_w_kolejkach % 60],
		"Udane zakupy: %d" % zakupy,
		"Odejścia z pustymi rękami: %d" % odejscia_z_niczym,
		"Wymiany: %d, prezenty: %d" % [wymiany, prezenty],
		"Zmiany w pracy: %d" % zmiany_w_pracy,
		"Załatwione na boku: %d, wpadki: %d" % [zalatwione, wpadki],
	]
