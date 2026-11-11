extends Node
var klatki: int = 0
var swiat: Node3D
var faza: int = 1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Po "zagraj ponownie" scena testowa laduje sie od nowa; faze trzymamy na root, ktory przezywa przeladowanie.
	faza = get_tree().root.get_meta("faza", 1)
	swiat = load("res://gra/swiat.tscn").instantiate()
	add_child(swiat)

func akcja(nazwa: String) -> void:
	var e := InputEventAction.new(); e.action = nazwa; e.pressed = true
	Input.parse_input_event(e)

func przycisk(kontener: Container, poczatek: String) -> Button:
	for d in kontener.get_children():
		if d is Button and (d as Button).text.begins_with(poczatek): return d
	return null

func _process(_delta: float) -> void:
	klatki += 1
	var gracz: CharacterBody3D = swiat.get_node("Gracz")
	var sklep: Sklep = swiat.get_node("Sklep")
	var os: Okno = swiat.get_node("OknoSklepu")
	var ek: Okno = swiat.get_node("EkranKonca")
	var hz: Label = swiat.get_node("HUD/EtykietaZadania")
	var czesc: Przedmiot = load("res://ekwipunek/przedmioty/czesc_do_pralki.tres")
	var talon: Przedmiot = load("res://ekwipunek/przedmioty/talon_na_pralke.tres")
	var kombinator: PostacNPC = swiat.get_node("Kombinator")
	var kierownik: PostacNPC = swiat.get_node("Zaklad/Kierownik")
	if faza == 2:
		if klatki == 2:
			print("[FAZA 2 po restarcie] dzien=", Zegar.numer_dnia, " ", Zegar.tekst_godziny(), " pieniadze=", Ekwipunek.pieniadze, " plecak: ", Ekwipunek.plecak.lista().map(func(p): return p.nazwa), " glod=", Potrzeby.glod, " energia=", Potrzeby.energia, " relacja kierownik=", Relacje.relacja(kierownik.dane), " kolejki=", Statystyki.minuty_w_kolejkach, " zakonczone=", Zadanie.zakonczone, " pauza=", get_tree().paused, " aktywne=", Okno.aktywne, " ekran=", ek.visible)
			print("  HUD:\n", hz.text)
			Zegar.numer_dnia = 7
			Zegar.przewin_do_godziny(7)
		if klatki == 4:
			print("[porazka] dzien=", Zegar.numer_dnia, " ekran=", ek.visible, " tytul=", (ek.get_node("%Tytul") as Label).text, " zakonczone=", Zadanie.zakonczone, " HUD dni: ", hz.text.split("\n")[0])
			akcja("ui_cancel")
		if klatki == 6:
			print("[Esc na ekranie konca] nadal widoczny=", ek.visible)
			get_tree().quit()
		return
	if klatki == 2:
		print("[HUD zadania]\n", hz.text)
		Ekwipunek.plecak.dodaj(load("res://ekwipunek/przedmioty/wodka.tres"), 1)
		Ekwipunek.plecak.dodaj(load("res://ekwipunek/przedmioty/kawa.tres"), 1)
		Relacje.zmien(kombinator.dane, 30); Relacje.zmien(kierownik.dane, 40)
		print("[wymiana u kombinatora] ", Rozmowa.wymien(kombinator, load("res://ekwipunek/przedmioty/wodka.tres"), czesc))
		print("[wymiana u kierownika] ", Rozmowa.wymien(kierownik, load("res://ekwipunek/przedmioty/kawa.tres"), talon))
		print("[HUD po wymianach] ", hz.text.replace("\n", " | "))
		Statystyki.minuty_w_kolejkach = 95
		gracz.global_position = Vector3(10, 0, -1.5)
	if klatki == 10:
		akcja("interakcja")
	if klatki == 12:
		var ptr: HBoxContainer = os.get_node("%Przyciski")
		print("[sklep 7:00 przyciski] ", ptr.get_children().map(func(b): return (b as Button).text))
		przycisk(ptr, "Zrealizuj").pressed.emit()
		print("[odbior z 1500 zl] ", (os.get_node("%Komunikat") as Label).text)
		Ekwipunek.dodaj_pieniadze(1500)
		przycisk(ptr, "Zrealizuj").pressed.emit()
	if klatki == 14:
		print("[po odbiorze] okno sklepu=", os.visible, " ekran konca=", ek.visible, " pauza=", get_tree().paused, " tytul=", (ek.get_node("%Tytul") as Label).text)
		print("  tresc: ", (ek.get_node("%Tresc") as Label).text.split("\n")[1])
		print("  statystyki: ", (ek.get_node("%Statystyki") as Label).text.replace("\n", " | "))
		print("  pieniadze=", Ekwipunek.pieniadze, " pralka=", Zadanie.czy_ma_cel(), " HUD: ", hz.text.replace("\n", " | "))
		get_tree().root.set_meta("faza", 2)
		(ek.get_node("%Ponownie") as Button).pressed.emit()
