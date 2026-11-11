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

func przycisk_w(kontener: Container, poczatek: String) -> Button:
	for d in kontener.get_children():
		if d is Button and (d as Button).text.begins_with(poczatek): return d
		if d is WierszPrzedmiotu:
			var w: WierszPrzedmiotu = d
			if w.etykieta_nazwy.text.begins_with(poczatek):
				return w.przyciski.get_child(0)
	return null

func lada_txt(s: Sklep) -> String:
	var a: Array[String] = []
	for p in s.lada.lista(): a.append("%s×%d" % [p.nazwa, s.lada.ile(p)])
	return ", ".join(a)

func _process(_delta: float) -> void:
	klatki += 1
	var gracz: CharacterBody3D = swiat.get_node("Gracz")
	var sklep: Sklep = swiat.get_node("Sklep")
	var okno: Okno = swiat.get_node("OknoSklepu")
	var tresc: Label = okno.get_node("%Tresc")
	var kom: Label = okno.get_node("%Komunikat")
	var lista: VBoxContainer = okno.get_node("%ListaTowaru")
	var przyciski: HBoxContainer = okno.get_node("%Przyciski")
	var podp: Label = swiat.get_node("HUD/EtykietaPodpowiedzi")
	var kartki: Przedmiot = load("res://ekwipunek/przedmioty/kartki_zywnosciowe.tres")
	var chleb: Przedmiot = load("res://ekwipunek/przedmioty/chleb.tres")
	var kielbasa: Przedmiot = load("res://ekwipunek/przedmioty/kielbasa.tres")
	if klatki == 2:
		print("[start] kartki=", Ekwipunek.plecak.ile(kartki), " otwarty=", sklep.czy_otwarty(), " dostawa=", sklep.czy_byla_dostawa())
		gracz.global_position = Vector3(10, 0, -1.5)
	if klatki == 10:
		print("[przy ladzie] podp='", podp.text, "' ", podp.visible)
		akcja("interakcja")
	if klatki == 12:
		print("[7:00] okno=", okno.visible, " tresc: ", tresc.text.replace("\n", " / "))
		akcja("plecak")
	if klatki == 14:
		print("[I przy otwartym sklepie] plecak widoczny=", (swiat.get_node("Plecak") as CanvasLayer).visible, " (ma byc false)")
		akcja("ui_cancel")
	if klatki == 16:
		print("[po Esc] okno=", okno.visible, " pauza=", get_tree().paused)
		sklep.dostawy = [load("res://sklep/dostawy/kielbasa_na_kartki.tres")]
		Zegar.przewin_do_godziny(10)
		print("[10:00] dostawa=", sklep.czy_byla_dostawa(), " o minucie ", sklep.minuta_dostawy, " lada: ", lada_txt(sklep), " kolejka=", sklep.szacowana_kolejka(), " min")
		akcja("interakcja")
	if klatki == 18:
		print("[decyzja] ", tresc.text.replace("\n", " / "))
		przycisk_w(przyciski, "Stań").pressed.emit()
		print("[po kolejce] ", Zegar.tekst_godziny(), " tresc: ", tresc.text, " lada: ", lada_txt(sklep), " lista widoczna=", lista.visible, " wierszy=", lista.get_child_count())
	if klatki == 20:
		var pien: int = Ekwipunek.pieniadze
		przycisk_w(lista, "Chleb").pressed.emit()
		print("[kup chleb] ", kom.text, " pieniadze ", pien, "->", Ekwipunek.pieniadze, " chleb w plecaku=", Ekwipunek.plecak.ile(chleb))
	if klatki == 22:
		var b: Button = przycisk_w(lista, "Kiełbasa")
		if b == null:
			print("[kielbasa] brak na ladzie po kolejce (ludzie wykupili), dokladam do testu")
			sklep.lada.dodaj(kielbasa, 1)
	if klatki == 24:
		przycisk_w(lista, "Kiełbasa").pressed.emit()
		print("[kup kielbasa z kartkami] ", kom.text, " kartki=", Ekwipunek.plecak.ile(kartki), " kielbasa=", Ekwipunek.plecak.ile(kielbasa))
		Ekwipunek.plecak.zabierz(kartki, Ekwipunek.plecak.ile(kartki))
		sklep.lada.dodaj(kielbasa, 1)
	if klatki == 26:
		przycisk_w(lista, "Kiełbasa").pressed.emit()
		print("[kup kielbasa bez kartek] ", kom.text, " kielbasa=", Ekwipunek.plecak.ile(kielbasa))
		Ekwipunek.zaplac(Ekwipunek.pieniadze)
		sklep.lada.dodaj(chleb, 1)
	if klatki == 28:
		przycisk_w(lista, "Chleb").pressed.emit()
		print("[kup bez pieniedzy] ", kom.text)
		akcja("ui_cancel")
	if klatki == 30:
		sklep.dostawy = [load("res://sklep/dostawy/brak.tres")]
		sklep._przyjmij_dostawe()
		akcja("interakcja")
	if klatki == 32:
		print("[brak dostawy] ", tresc.text, " | przyciskow=", przyciski.get_child_count())
		akcja("ui_cancel")
	if klatki == 34:
		Zegar.przewin_do_godziny(19)
		akcja("interakcja")
	if klatki == 36:
		print("[19:00] ", tresc.text)
		akcja("ui_cancel")
	if klatki == 38:
		print("[losowanie 2000x] ", _rozklad(sklep))
		get_tree().quit()

func _rozklad(sklep: Sklep) -> String:
	sklep.dostawy.assign([load("res://sklep/dostawy/chleb_i_papier.tres"), load("res://sklep/dostawy/kielbasa_na_kartki.tres"), load("res://sklep/dostawy/rarytasy.tres"), load("res://sklep/dostawy/sam_chleb.tres"), load("res://sklep/dostawy/wodka.tres"), load("res://sklep/dostawy/brak.tres")])
	var licznik: Dictionary = {}
	for i in 2000:
		var d: Dostawa = sklep._losuj_dostawe()
		licznik[d.nazwa] = licznik.get(d.nazwa, 0) + 1
	return str(licznik)
