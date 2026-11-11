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
		if d is WierszPrzedmiotu:
			var w: WierszPrzedmiotu = d
			if w.etykieta_nazwy.text.begins_with(poczatek) or w.etykieta_info.text.begins_with(poczatek):
				return w.przyciski.get_child(0)
	return null

func _process(_delta: float) -> void:
	klatki += 1
	var gracz: CharacterBody3D = swiat.get_node("Gracz")
	var sasiad: PostacNPC = swiat.get_node("Sasiad")
	var okno: Okno = swiat.get_node("OknoRozmowy")
	var tresc: Label = okno.get_node("%Tresc")
	var rel: Label = okno.get_node("%Relacja")
	var lista: VBoxContainer = okno.get_node("%Lista")
	var przyciski: HBoxContainer = okno.get_node("%Przyciski")
	var podp: Label = swiat.get_node("HUD/EtykietaPodpowiedzi")
	var papierosy: Przedmiot = load("res://ekwipunek/przedmioty/papierosy.tres")
	var kawa: Przedmiot = load("res://ekwipunek/przedmioty/kawa.tres")
	if klatki == 2:
		var npcs: Array[String] = []
		for n in [swiat.get_node("Sklep/Sprzedawczyni"), swiat.get_node("Zaklad/Kierownik"), sasiad, swiat.get_node("Kombinator")]:
			var npc: PostacNPC = n
			npcs.append("%s(%s, rel %d, kolor %s)" % [npc.dane.imie, npc.interakcja.nazwa_akcji, Relacje.relacja(npc.dane), npc.wyglad.material.albedo_color.to_html(false)])
		print("[postacie] ", "\n  ".join(npcs))
		gracz.global_position = Vector3(-4.5, 0, -7.5)
		Ekwipunek.plecak.dodaj(papierosy, 3)
	if klatki == 10:
		print("[przy sasiedzie] podp='", podp.text, "' ", podp.visible)
		akcja("interakcja")
	if klatki == 12:
		print("[okno] ", okno.visible, " ", rel.text, " przyciski: ", przyciski.get_children().map(func(b): return (b as Button).text))
		przycisk(przyciski, "Pogadaj").pressed.emit()
		print("[pogadaj] ", tresc.text.replace("\n", " / "), " | ", rel.text, " | ponownie wylaczony=", przycisk(przyciski, "Pogadaj") == null)
		_pokaz_menu_ponownie(okno)
	if klatki == 14:
		print("[pogadaj 2x] przycisk Pogadaj disabled=", przycisk(przyciski, "Pogadaj").disabled)
		przycisk(przyciski, "Zaproponuj").pressed.emit()
		print("[wymiana przy rel 28] ", tresc.text.replace("\n", " / "), " wierszy=", lista.get_child_count())
		przycisk(przyciski, "Wróć").pressed.emit()
		przycisk(przyciski, "Daj prezent").pressed.emit()
		print("[prezenty] ", tresc.text, " wierszy=", lista.get_child_count())
		przycisk(lista, "Papierosy").pressed.emit()
		print("[po prezencie] ", tresc.text.replace("\n", " / "), " | ", rel.text, " papierosy=", Ekwipunek.plecak.ile(papierosy))
	if klatki == 16:
		przycisk(przyciski, "Zaproponuj").pressed.emit()
		print("[wymiana przy rel 43] ", tresc.text.replace("\n", " / "), " wierszy=", lista.get_child_count())
		for w in lista.get_children(): print("   wiersz: ", (w as WierszPrzedmiotu).etykieta_nazwy.text, " ", (w as WierszPrzedmiotu).etykieta_info.text)
		przycisk(lista, "Kawa").pressed.emit()
		print("[po wymianie] ", tresc.text, " papierosy=", Ekwipunek.plecak.ile(papierosy), " kawa=", Ekwipunek.plecak.ile(kawa))
		przycisk(przyciski, "Wróć").pressed.emit()
		przycisk(przyciski, "Zaproponuj").pressed.emit()
		print("[druga wymiana tego dnia] ", tresc.text)
		akcja("ui_cancel")
	if klatki == 18:
		print("[po Esc] okno=", okno.visible, " pauza=", get_tree().paused)
		# przywilej spod lady
		var sklep: Sklep = swiat.get_node("Sklep")
		print("[pod lada przy rel ", Relacje.relacja(sklep.sprzedawczynia), "] ", sklep.czy_pod_lada())
		Relacje.zmien(sklep.sprzedawczynia, 50)
		print("[pod lada przy rel ", Relacje.relacja(sklep.sprzedawczynia), "] ", sklep.czy_pod_lada())
		sklep.dostawy = [load("res://sklep/dostawy/sam_chleb.tres")]
		Zegar.przewin_do_godziny(9)
		gracz.global_position = Vector3(10, 0, -1.5)
	if klatki == 26:
		print("[przy ladzie] podp='", podp.text, "'")
		akcja("interakcja")
	if klatki == 28:
		var os: Okno = swiat.get_node("OknoSklepu")
		var ptr: HBoxContainer = os.get_node("%Przyciski")
		print("[sklep przyciski] ", ptr.get_children().map(func(b): return (b as Button).text))
		var g: String = Zegar.tekst_godziny()
		przycisk(ptr, "Poproś").pressed.emit()
		print("[spod lady] czas ", g, "->", Zegar.tekst_godziny(), " (bez kolejki) tresc: ", (os.get_node("%Tresc") as Label).text, " wierszy=", (os.get_node("%ListaTowaru") as VBoxContainer).get_child_count())
		akcja("ui_cancel")
		gracz.global_position = Vector3(12.4, 0, -2.4)
	if klatki == 36:
		print("[przy sprzedawczyni] podp='", podp.text, "'")
		get_tree().quit()

func _pokaz_menu_ponownie(okno: Okno) -> void:
	okno.call("_pokaz_menu")
