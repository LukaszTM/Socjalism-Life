extends CanvasLayer
## Nakładka na ekran: dzień i godzina, paski potrzeb oraz podpowiedź interakcji.
## HUD tylko wyświetla; o zmianach dowiaduje się z sygnałów, sam nic nie liczy.

@onready var etykieta_czasu: Label = %EtykietaCzasu
@onready var etykieta_podpowiedzi: Label = %EtykietaPodpowiedzi
@onready var pasek_glodu: ProgressBar = %PasekGlodu
@onready var pasek_energii: ProgressBar = %PasekEnergii


func _ready() -> void:
	Zegar.minuta_minela.connect(_odswiez_czas)
	_odswiez_czas(Zegar.godzina(), Zegar.minuta())

	Potrzeby.glod_zmieniony.connect(_odswiez_glod)
	Potrzeby.energia_zmieniona.connect(_odswiez_energie)
	# Na starcie sygnały jeszcze nie przyszły, więc wartości bierzemy wprost.
	_odswiez_glod(Potrzeby.glod)
	_odswiez_energie(Potrzeby.energia)

	etykieta_podpowiedzi.hide()


func _odswiez_czas(_godzina: int, _minuta: int) -> void:
	etykieta_czasu.text = "%s, dzień %d    %s" % [Zegar.nazwa_dnia(), Zegar.numer_dnia, Zegar.tekst_godziny()]


func _odswiez_glod(wartosc: float) -> void:
	pasek_glodu.value = wartosc


func _odswiez_energie(wartosc: float) -> void:
	pasek_energii.value = wartosc


## Podłączone w scenie świata do sygnału `cel_zmieniony` wykrywacza na graczu.
func pokaz_podpowiedz(cel: Interakcja) -> void:
	if cel == null:
		etykieta_podpowiedzi.hide()
		return
	etykieta_podpowiedzi.text = "E: %s" % cel.nazwa_akcji
	etykieta_podpowiedzi.show()
