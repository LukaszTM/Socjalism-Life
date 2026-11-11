extends Okno
## Okno plecaka (klawisz I). Pokazuje pieniądze i listę przedmiotów gracza.
## Gdy otwiera je lodówka, dostaje jej schowek i pokazuje drugą kolumnę
## z przyciskami do przekładania. Pauzę i Esc załatwia wspólna klasa Okno.

const SCENA_WIERSZA: PackedScene = preload("res://ui/wspolne/wiersz_przedmiotu.tscn")

@onready var etykieta_pieniedzy: Label = %EtykietaPieniedzy
@onready var lista_plecaka: VBoxContainer = %ListaPlecaka
@onready var kolumna_schowka: VBoxContainer = %KolumnaSchowka
@onready var naglowek_schowka: Label = %NaglowekSchowka
@onready var lista_schowka: VBoxContainer = %ListaSchowka

## Schowek drugiej kolumny (np. lodówka). `null`, gdy otwarto sam plecak.
var _schowek: Schowek = null


func _ready() -> void:
	super()
	Ekwipunek.przedmioty_zmienione.connect(_odswiez)
	Ekwipunek.pieniadze_zmienione.connect(_odswiez_pieniadze)


func _unhandled_input(zdarzenie: InputEvent) -> void:
	super(zdarzenie)
	if zdarzenie.is_action_pressed("plecak"):
		if visible:
			zamknij()
		else:
			otworz_plecak()
		get_viewport().set_input_as_handled()


## Sam plecak, bez drugiej kolumny.
func otworz_plecak() -> void:
	_schowek = null
	_pokaz()


## Plecak obok innego schowka. Podłączone w scenie świata do sygnału `otworzono` lodówki.
func otworz_ze_schowkiem(schowek: Schowek, nazwa: String) -> void:
	if not czy_mozna_otworzyc():
		return
	_schowek = schowek
	_schowek.zmieniony.connect(_odswiez)
	naglowek_schowka.text = nazwa
	_pokaz()


func zamknij() -> void:
	if _schowek != null:
		_schowek.zmieniony.disconnect(_odswiez)
		_schowek = null
	super()


func _pokaz() -> void:
	if not czy_mozna_otworzyc():
		return
	kolumna_schowka.visible = _schowek != null
	# Najpierw pokazujemy, potem odświeżamy: _odswiez() pomija pracę, gdy okno jest schowane.
	otworz()
	_odswiez()
	_odswiez_pieniadze(Ekwipunek.pieniadze)


func _odswiez_pieniadze(ile: int) -> void:
	etykieta_pieniedzy.text = "Pieniądze: %d zł" % ile


func _odswiez() -> void:
	if not visible:
		return
	_wypelnij_liste(lista_plecaka, Ekwipunek.plecak, true)
	if _schowek != null:
		_wypelnij_liste(lista_schowka, _schowek, false)


## Buduje wiersze listy od nowa. Przedmiotów jest kilka, więc prościej wszystko
## odtworzyć niż śledzić, który wiersz zmienić.
func _wypelnij_liste(lista: VBoxContainer, schowek: Schowek, czy_plecak: bool) -> void:
	for dziecko: Node in lista.get_children():
		lista.remove_child(dziecko)
		# queue_free() zamiast free(): przebudowę często wywołuje kliknięcie przycisku
		# z tego właśnie wiersza, a obiektu nie można zwolnić, gdy jeszcze wysyła sygnał.
		dziecko.queue_free()
	if schowek.pusty():
		var pusto: Label = Label.new()
		pusto.text = "(pusto)"
		pusto.modulate = Color(1, 1, 1, 0.6)
		lista.add_child(pusto)
		return
	for przedmiot: Przedmiot in schowek.lista():
		lista.add_child(_zbuduj_wiersz(przedmiot, schowek.ile(przedmiot), czy_plecak))


func _zbuduj_wiersz(przedmiot: Przedmiot, ile: int, czy_plecak: bool) -> WierszPrzedmiotu:
	var wiersz: WierszPrzedmiotu = SCENA_WIERSZA.instantiate()
	# Wiersz trzeba najpierw dodać do drzewa, żeby jego węzły (@onready) były gotowe,
	# dlatego ustawiamy treść po add_child, w _po_dodaniu.
	wiersz.ready.connect(func() -> void:
		wiersz.ustaw(przedmiot, ile)
		if czy_plecak and przedmiot.jadalny:
			wiersz.dodaj_przycisk("Zjedz", func() -> void: Ekwipunek.zjedz(przedmiot))
		if _schowek != null:
			if czy_plecak:
				wiersz.dodaj_przycisk("Odłóż →", func() -> void: _przeloz(przedmiot, Ekwipunek.plecak, _schowek))
			else:
				wiersz.dodaj_przycisk("← Weź", func() -> void: _przeloz(przedmiot, _schowek, Ekwipunek.plecak))
	)
	return wiersz


func _przeloz(przedmiot: Przedmiot, skad: Schowek, dokad: Schowek) -> void:
	# Najpierw zabieramy, potem dodajemy: gdyby zabrać się nie dało, nic nie powielimy.
	if skad.zabierz(przedmiot, 1):
		dokad.dodaj(przedmiot, 1)
