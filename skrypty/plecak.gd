extends CanvasLayer
## Okno plecaka (klawisz I). Pokazuje pieniądze i listę przedmiotów gracza.
## Gdy otwiera je lodówka, dostaje jej schowek i pokazuje drugą kolumnę
## z przyciskami do przekładania. Działa przy zatrzymanej grze (process_mode: Always),
## bo otwarte okno pauzuje całe drzewo: zegar stoi, gracz nie chodzi.

@onready var etykieta_pieniedzy: Label = %EtykietaPieniedzy
@onready var lista_plecaka: VBoxContainer = %ListaPlecaka
@onready var kolumna_schowka: VBoxContainer = %KolumnaSchowka
@onready var naglowek_schowka: Label = %NaglowekSchowka
@onready var lista_schowka: VBoxContainer = %ListaSchowka

## Schowek drugiej kolumny (np. lodówka). `null`, gdy otwarto sam plecak.
var _schowek: Schowek = null


func _ready() -> void:
	hide()
	Ekwipunek.przedmioty_zmienione.connect(_odswiez)
	Ekwipunek.pieniadze_zmienione.connect(_odswiez_pieniadze)


func _unhandled_input(zdarzenie: InputEvent) -> void:
	if zdarzenie.is_action_pressed("plecak"):
		if visible:
			zamknij()
		else:
			otworz()
		get_viewport().set_input_as_handled()
	elif visible and zdarzenie.is_action_pressed("ui_cancel"):
		zamknij()
		get_viewport().set_input_as_handled()


## Sam plecak, bez drugiej kolumny.
func otworz() -> void:
	_schowek = null
	_pokaz()


## Plecak obok innego schowka. Podłączone w scenie świata do sygnału `otworzono` lodówki.
func otworz_ze_schowkiem(schowek: Schowek, nazwa: String) -> void:
	_schowek = schowek
	_schowek.zmieniony.connect(_odswiez)
	naglowek_schowka.text = nazwa
	_pokaz()


func zamknij() -> void:
	if _schowek != null:
		_schowek.zmieniony.disconnect(_odswiez)
		_schowek = null
	hide()
	get_tree().paused = false


func _pokaz() -> void:
	kolumna_schowka.visible = _schowek != null
	# Najpierw pokazujemy, potem odświeżamy: _odswiez() pomija pracę, gdy okno jest schowane.
	show()
	_odswiez()
	_odswiez_pieniadze(Ekwipunek.pieniadze)
	get_tree().paused = true


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
		# queue_free() usuwa go bezpiecznie pod koniec klatki.
		dziecko.queue_free()
	if schowek.pusty():
		var pusto: Label = Label.new()
		pusto.text = "(pusto)"
		pusto.modulate = Color(1, 1, 1, 0.6)
		lista.add_child(pusto)
		return
	for przedmiot: Przedmiot in schowek.lista():
		lista.add_child(_zbuduj_wiersz(przedmiot, schowek.ile(przedmiot), czy_plecak))


func _zbuduj_wiersz(przedmiot: Przedmiot, ile: int, czy_plecak: bool) -> HBoxContainer:
	var wiersz: HBoxContainer = HBoxContainer.new()
	wiersz.add_theme_constant_override("separation", 10)

	var ikona: TextureRect = TextureRect.new()
	ikona.texture = przedmiot.ikona
	ikona.custom_minimum_size = Vector2(28, 28)
	ikona.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ikona.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	wiersz.add_child(ikona)

	var nazwa: Label = Label.new()
	nazwa.text = "%s × %d" % [przedmiot.nazwa, ile]
	nazwa.tooltip_text = przedmiot.opis
	nazwa.mouse_filter = Control.MOUSE_FILTER_PASS
	nazwa.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wiersz.add_child(nazwa)

	if czy_plecak and przedmiot.jadalny:
		var zjedz: Button = Button.new()
		zjedz.text = "Zjedz"
		zjedz.pressed.connect(func() -> void: Ekwipunek.zjedz(przedmiot))
		wiersz.add_child(zjedz)

	if _schowek != null:
		var przeloz: Button = Button.new()
		if czy_plecak:
			przeloz.text = "Odłóż →"
			przeloz.pressed.connect(func() -> void: _przeloz(przedmiot, Ekwipunek.plecak, _schowek))
		else:
			przeloz.text = "← Weź"
			przeloz.pressed.connect(func() -> void: _przeloz(przedmiot, _schowek, Ekwipunek.plecak))
		wiersz.add_child(przeloz)

	return wiersz


func _przeloz(przedmiot: Przedmiot, skad: Schowek, dokad: Schowek) -> void:
	# Najpierw zabieramy, potem dodajemy: gdyby zabrać się nie dało, nic nie powielimy.
	if skad.zabierz(przedmiot, 1):
		dokad.dodaj(przedmiot, 1)
