extends Okno
## Ekran końca tygodnia: sukces albo porażka, statystyki i „zagraj ponownie".
## Otwiera się na sygnały Zadania, zamykając wcześniej każde inne okno.

@onready var etykieta_tytulu: Label = %Tytul
@onready var etykieta_tresci: Label = %Tresc
@onready var etykieta_statystyk: Label = %Statystyki
@onready var przycisk_ponownie: Button = %Ponownie


func _ready() -> void:
	super()
	Zadanie.ukonczone.connect(_na_sukces)
	Zadanie.przegrane.connect(_na_porazke)
	przycisk_ponownie.pressed.connect(_zagraj_ponownie)


## Ekranu końca nie da się zamknąć klawiszem Esc: jedyna droga to „zagraj ponownie".
func _unhandled_input(_zdarzenie: InputEvent) -> void:
	pass


func _na_sukces() -> void:
	etykieta_tytulu.text = "Sukces!"
	etykieta_tresci.text = "Frania stoi w łazience i dudni jak czołg. Sąsiedzi zazdroszczą, kierownik kiwa głową, a pani Grażyna już wie, co odłożyć pod ladę w przyszłym tygodniu.\nZajęło ci to %s." % _odmiana_dni(Zegar.numer_dnia)
	_pokaz()


func _na_porazke() -> void:
	etykieta_tytulu.text = "Tydzień minął"
	etykieta_tresci.text = "Pralki nie ma. Pranie dalej w wannie, na tarze. Może w przyszłym tygodniu coś przywiozą, może ktoś kogoś pozna."
	_pokaz()


func _odmiana_dni(ile: int) -> String:
	return "1 dzień" if ile == 1 else "%d dni" % ile


func _pokaz() -> void:
	etykieta_statystyk.text = "\n".join(Statystyki.podsumowanie())
	# Koniec gry ma pierwszeństwo przed każdym innym oknem (np. sklepem, w którym kupiono pralkę).
	if aktywne != null and aktywne != self:
		aktywne.zamknij()
	otworz()


func _zagraj_ponownie() -> void:
	# Autoloady przeżywają przeładowanie sceny, więc każdy sprząta po sobie sam.
	Zegar.resetuj()
	Potrzeby.resetuj()
	Ekwipunek.resetuj()
	Relacje.resetuj()
	Statystyki.resetuj()
	Zadanie.resetuj()
	zamknij()
	get_tree().reload_current_scene()
