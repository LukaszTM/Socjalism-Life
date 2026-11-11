extends Node
var klatki: int = 0
var swiat: Node3D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
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
	var zaklad: Zaklad = swiat.get_node("Zaklad")
	var okno: Okno = swiat.get_node("OknoPracy")
	var tresc: Label = okno.get_node("%Tresc")
	var przyciski: HBoxContainer = okno.get_node("%Przyciski")
	var podp: Label = swiat.get_node("HUD/EtykietaPodpowiedzi")
	var k: Postac = zaklad.kierownik
	if klatki == 2:
		print("[start] relacja z kierownikiem=", Relacje.relacja(k), " (", Relacje.opis(k), ") dzien roboczy=", zaklad.czy_dzien_roboczy(), " stan=", zaklad.stan())
		gracz.global_position = Vector3(2, 0, 9.5)
	if klatki == 10:
		print("[przy bramie] podp='", podp.text, "' ", podp.visible)
		akcja("interakcja")
	if klatki == 12:
		print("[7:00] ", tresc.text.replace("\n", " / "))
		akcja("ui_cancel")
		Zegar.przewin_do_godziny(8); Zegar.przewin_minuty(20)
		akcja("interakcja")
	if klatki == 14:
		print("[8:20] ", tresc.text.replace("\n", " / "))
		var pien: int = Ekwipunek.pieniadze; var en: float = Potrzeby.energia
		przycisk(przyciski, "Pracuj uczciwie").pressed.emit()
		print("[po zmianie] ", Zegar.tekst_godziny(), " pieniadze ", pien, "->", Ekwipunek.pieniadze, " energia ", en, "->", Potrzeby.energia, " relacja=", Relacje.relacja(k))
		print("  tekst: ", tresc.text.replace("\n", " / "))
		akcja("ui_cancel")
		akcja("interakcja")
	if klatki == 16:
		print("[ponownie tego dnia] ", tresc.text)
		akcja("ui_cancel")
		Zegar.przewin_do_godziny(17)
		akcja("interakcja")
	if klatki == 18:
		print("[17:00 juz_bylo nadal] ", tresc.text)
		akcja("ui_cancel")
		# Wtorek, spóźnienie 2 h + załatwianie z ustalonym ziarnem (sukces i wpadka)
		Zegar.przewin_do_godziny(10)
		print("[wtorek 10:00] dzien=", Zegar.numer_dnia, " relacja po nocy (byl w pracy w pon)=", Relacje.relacja(k))
		var wyniki: Dictionary = {}
		for ziarno in 20:
			zaklad._rng.seed = ziarno
			var przed: int = Ekwipunek.pieniadze
			var r: int = Relacje.relacja(k)
			zaklad.dzien_ostatniej_zmiany = 0
			var w: Dictionary = zaklad.pracuj(true)
			var klucz: String = "wpadka" if w["wpadka"] else ("zalatwil:" + (w["zalatwiono"] as Przedmiot).nazwa)
			wyniki[klucz] = wyniki.get(klucz, 0) + 1
			if ziarno == 0: print("  [ziarno 0] ", klucz, " pieniadze ", przed, "->", Ekwipunek.pieniadze, " relacja ", r, "->", Relacje.relacja(k), " kara_relacji_spoznienie=", w["kara_relacji"], " spoznienie=", w["spoznienie"])
			# cofamy czas o dobe testowo: pracuj przewija do 16:00, wiec ustawiamy recznie
			Zegar._minuty_dnia = 10 * 60
		print("[20 prob zalatwiania] ", wyniki)
		# Nieobecność: środa bez pracy -> czwartek rano relacja spada o 15
		Zegar.przewin_do_godziny(7)  # sroda 7:00
		var r_sroda: int = Relacje.relacja(k)
		Zegar.przewin_do_godziny(7)  # czwartek 7:00, w srode nie pracowal
		print("[nieobecnosc w srode] dzien=", Zegar.numer_dnia, " relacja ", r_sroda, "->", Relacje.relacja(k), " (ma spasc o 15)")
		# Weekend
		Zegar.numer_dnia = 6
		akcja("interakcja")
	if klatki == 20:
		print("[sobota] ", tresc.text)
		akcja("ui_cancel")
		print("[zaklad za pozno?] stan przy 7:00 sobota=", zaklad.stan())
		get_tree().quit()
