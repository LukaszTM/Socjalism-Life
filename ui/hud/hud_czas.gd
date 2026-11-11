extends Label
## Napis z dniem i godziną. Słucha zegara i tylko przepisuje tekst.

func _ready() -> void:
	Zegar.minuta_minela.connect(_odswiez)
	_odswiez(Zegar.godzina(), Zegar.minuta())


func _odswiez(_godzina: int, _minuta: int) -> void:
	text = "%s, dzień %d    %s" % [Zegar.nazwa_dnia(), Zegar.numer_dnia, Zegar.tekst_godziny()]
