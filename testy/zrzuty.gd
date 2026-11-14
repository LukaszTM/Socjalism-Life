extends Node
## Przechodzi przez miejsca i okna gry i zapisuje zrzuty ekranu do user://zrzuty/.
## Wymaga okna (nie działa z --headless), bo bez renderowania nie ma czego zapisać.

const KATALOG: String = "user://zrzuty/"
var swiat: Node3D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	DirAccess.make_dir_recursive_absolute(KATALOG)
	swiat = load("res://gra/swiat.tscn").instantiate()
	add_child(swiat)
	_sesja()


func akcja(nazwa: String) -> void:
	var e: InputEventAction = InputEventAction.new()
	e.action = nazwa
	e.pressed = true
	Input.parse_input_event(e)


func klatki(n: int) -> void:
	for i: int in n:
		await get_tree().process_frame


func zrzut(nazwa: String) -> void:
	await klatki(3)
	await RenderingServer.frame_post_draw
	var obraz: Image = get_viewport().get_texture().get_image()
	var blad: int = obraz.save_png(KATALOG + nazwa + ".png")
	print("[zrzut] ", nazwa, " -> ", "ok" if blad == OK else str(blad), " (", ProjectSettings.globalize_path(KATALOG), ")")


func przycisk(kontener: Container, poczatek: String) -> Button:
	for d: Node in kontener.get_children():
		if d is Button and (d as Button).text.begins_with(poczatek):
			return d
	return null


func przenies(gracz: CharacterBody3D, kamera: Camera3D, gdzie: Vector3) -> void:
	gracz.global_position = gdzie
	kamera.global_position = kamera._pozycja_docelowa()
	await klatki(8)


func _sesja() -> void:
	var gracz: CharacterBody3D = swiat.get_node("Gracz")
	var kamera: Camera3D = swiat.get_node("Kamera")
	await klatki(10)
	await zrzut("01_start_mieszkanie")
	Ekwipunek.plecak.dodaj(load("res://ekwipunek/przedmioty/papierosy.tres"), 2)
	akcja("plecak"); await zrzut("02_plecak"); akcja("plecak"); await klatki(2)
	await przenies(gracz, kamera, Vector3(-7, 0, -3))
	akcja("interakcja"); await zrzut("03_lodowka"); akcja("ui_cancel"); await klatki(2)
	var sklep: Sklep = swiat.get_node("Sklep")
	sklep.dostawy = [load("res://sklep/dostawy/rarytasy.tres")]
	Zegar.przewin_do_godziny(9); Zegar.przewin_minuty(40)
	await przenies(gracz, kamera, Vector3(10, 0, -1.5))
	await zrzut("04_przed_sklepem")
	akcja("interakcja"); await zrzut("05_sklep_decyzja")
	var okno_sklepu: Okno = swiat.get_node("OknoSklepu")
	przycisk(okno_sklepu.get_node("%Przyciski"), "Stań").pressed.emit()
	await zrzut("06_sklep_zakupy"); akcja("ui_cancel"); await klatki(2)
	await przenies(gracz, kamera, Vector3(-4.5, 0, -7.5))
	akcja("interakcja"); await zrzut("07_rozmowa_sasiad")
	var okno_rozmowy: Okno = swiat.get_node("OknoRozmowy")
	przycisk(okno_rozmowy.get_node("%Przyciski"), "Daj prezent").pressed.emit()
	await zrzut("08_rozmowa_prezent"); akcja("ui_cancel"); await klatki(2)
	Zegar.przewin_do_godziny(8); Zegar.przewin_minuty(30)
	await przenies(gracz, kamera, Vector3(2, 0, 9.5))
	await zrzut("09_przed_zakladem")
	akcja("interakcja"); await zrzut("10_praca_wybor")
	var okno_pracy: Okno = swiat.get_node("OknoPracy")
	przycisk(okno_pracy.get_node("%Przyciski"), "Pracuj i").pressed.emit()
	await zrzut("11_praca_wynik"); akcja("ui_cancel"); await klatki(2)
	Ekwipunek.plecak.dodaj(load("res://ekwipunek/przedmioty/pralka_frania.tres"), 1)
	await zrzut("12_ekran_konca")
	get_tree().quit()
