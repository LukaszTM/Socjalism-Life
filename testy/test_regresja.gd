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

func przycisk(lista: VBoxContainer, nazwa_przedmiotu: String, tekst: String) -> Button:
	for w in lista.get_children():
		if not (w is WierszPrzedmiotu): continue
		var wp: WierszPrzedmiotu = w
		if not wp.etykieta_nazwy.text.begins_with(nazwa_przedmiotu): continue
		for d in wp.przyciski.get_children():
			if d is Button and (d as Button).text == tekst: return d
	return null

func opis_listy(lista: VBoxContainer) -> String:
	var czesci: Array[String] = []
	for w in lista.get_children():
		if w is Label: czesci.append((w as Label).text)
		elif w is WierszPrzedmiotu: czesci.append((w as WierszPrzedmiotu).etykieta_nazwy.text)
	return " | ".join(czesci)

func _process(_delta: float) -> void:
	klatki += 1
	var gracz: CharacterBody3D = swiat.get_node("Gracz")
	var hud: CanvasLayer = swiat.get_node("HUD")
	var czas: Label = hud.get_node("EtykietaCzasu")
	var podp: Label = hud.get_node("EtykietaPodpowiedzi")
	var pg: ProgressBar = hud.get_node("%PasekGlodu")
	var pe: ProgressBar = hud.get_node("%PasekEnergii")
	var plecak: CanvasLayer = swiat.get_node("Plecak")
	var lp: VBoxContainer = plecak.get_node("%ListaPlecaka")
	var ls: VBoxContainer = plecak.get_node("%ListaSchowka")
	if klatki == 2:
		print("[start] HUD '", czas.text, "' paski ", pg.value, "/", pe.value, " podp=", podp.visible, " pieniadze=", Ekwipunek.pieniadze)
		Zegar.przewin_do_godziny(12)
		print("[po 5 h] HUD '", czas.text, "' paski ", pg.value, "/", pe.value, " (ma byc 70/75)")
		gracz.global_position = Vector3(-10, 0, -3)
	if klatki == 10:
		print("[przy lozku] podp='", podp.text, "' widoczna=", podp.visible)
		akcja("interakcja")
	if klatki == 12:
		print("[po snie] HUD '", czas.text, "' energia=", pe.value, " (Wtorek 07:00, 100)")
		gracz.global_position = Vector3(-7, 0, -3)
		Ekwipunek.plecak.dodaj(load("res://ekwipunek/przedmioty/kawa.tres"), 1)
	if klatki == 20:
		print("[przy lodowce] podp='", podp.text, "' widoczna=", podp.visible)
		akcja("interakcja")
	if klatki == 22:
		print("[lodowka otwarta] okno=", plecak.visible, " pauza=", get_tree().paused, " plecak: ", opis_listy(lp), " || lodowka: ", opis_listy(ls))
		przycisk(lp, "Kawa", "Odłóż →").pressed.emit()
		przycisk(lp, "Chleb", "Zjedz").pressed.emit()
		print("[po odlozeniu kawy i zjedzeniu chleba] plecak: ", opis_listy(lp), " || lodowka: ", opis_listy(ls), " glod=", pg.value)
		akcja("ui_cancel")
	if klatki == 24:
		print("[po Esc] okno=", plecak.visible, " pauza=", get_tree().paused, " podp widoczna=", podp.visible)
		akcja("plecak")
	if klatki == 26:
		print("[I] okno=", plecak.visible, " plecak: ", opis_listy(lp))
		akcja("plecak")
	if klatki == 28:
		print("[I ponownie] okno=", plecak.visible, " pauza=", get_tree().paused)
		get_tree().quit()
