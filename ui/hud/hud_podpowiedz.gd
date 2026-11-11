extends Label
## Podpowiedź „E: Śpij" na dole ekranu. Pokazuje się, gdy wykrywacz na graczu zgłosi cel.

func _ready() -> void:
	hide()


## Podłączone w scenie świata do sygnału `cel_zmieniony` wykrywacza interakcji.
func pokaz_podpowiedz(cel: Interakcja) -> void:
	if cel == null:
		hide()
		return
	text = "E: %s" % cel.nazwa_akcji
	show()
