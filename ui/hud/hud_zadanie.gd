extends Label
## Podgląd zadania głównego pod zegarem: cel, pozostałe dni i lista kroków.

func _ready() -> void:
	Zadanie.postep_zmieniony.connect(_odswiez)
	Zegar.dzien_minal.connect(func(_d: int) -> void: _odswiez())
	_odswiez()


func _odswiez() -> void:
	var linie: Array[String] = ["Cel: %s (zostało dni: %d)" % [Zadanie.cel.nazwa, Zadanie.dni_pozostale()]]
	for krok: Array in Zadanie.kroki():
		linie.append("%s %s" % ["[x]" if krok[1] else "[ ]", krok[0]])
	text = "\n".join(linie)
