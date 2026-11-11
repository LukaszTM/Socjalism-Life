extends CanvasLayer
## Nakładka na ekran: dzień i godzina w rogu oraz podpowiedź interakcji na dole.
## HUD tylko wyświetla; o zmianach dowiaduje się z sygnałów, sam nic nie liczy.

@onready var etykieta_czasu: Label = %EtykietaCzasu
@onready var etykieta_podpowiedzi: Label = %EtykietaPodpowiedzi


func _ready() -> void:
	Zegar.minuta_minela.connect(_odswiez_czas)
	_odswiez_czas(Zegar.godzina(), Zegar.minuta())
	etykieta_podpowiedzi.hide()


func _odswiez_czas(_godzina: int, _minuta: int) -> void:
	etykieta_czasu.text = "%s, dzień %d    %s" % [Zegar.nazwa_dnia(), Zegar.numer_dnia, Zegar.tekst_godziny()]


## Podłączone w scenie świata do sygnału `cel_zmieniony` wykrywacza na graczu.
func pokaz_podpowiedz(cel: Interakcja) -> void:
	if cel == null:
		etykieta_podpowiedzi.hide()
		return
	etykieta_podpowiedzi.text = "E: %s" % cel.nazwa_akcji
	etykieta_podpowiedzi.show()
