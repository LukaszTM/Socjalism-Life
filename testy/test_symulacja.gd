extends Node
## Bot: rozgrywa tydzien prosta strategia na logice gry. Mierzy odsetek wygranych.
const TYGODNI: int = 300
var swiat: Node3D
var P: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	swiat = load("res://gra/swiat.tscn").instantiate()
	add_child(swiat)
	for n in ["chleb", "kielbasa", "kawa", "papierosy", "wodka", "czesc_do_pralki", "talon_na_pralke", "pralka_frania", "kartki_zywnosciowe"]:
		P[n] = load("res://ekwipunek/przedmioty/%s.tres" % n)
	call_deferred("_symuluj")

func _reset() -> void:
	Zegar.resetuj(); Potrzeby.resetuj(); Ekwipunek.resetuj(); Relacje.resetuj(); Statystyki.resetuj(); Zadanie.resetuj()
	var sklep: Sklep = swiat.get_node("Sklep"); sklep.lada.wyczysc(); sklep.dzisiejsza_dostawa = null; sklep.minuta_dostawy = -1
	var zaklad: Zaklad = swiat.get_node("Zaklad"); zaklad.dzien_ostatniej_zmiany = 0
	for npc in [swiat.get_node("Sasiad"), swiat.get_node("Kombinator"), swiat.get_node("Zaklad/Kierownik"), swiat.get_node("Sklep/Sprzedawczyni")]:
		npc.dzien_ostatniej_rozmowy = 0; npc.dzien_ostatniej_wymiany = 0; npc.wymian_dzis = 0

func ile(n: String) -> int: return Ekwipunek.plecak.ile(P[n])

func _zakupy(sklep: Sklep) -> void:
	if not sklep.czy_otwarty() or not sklep.czy_byla_dostawa() or sklep.lada.pusty(): return
	# oplaca sie stac tylko po cos cennego albo gdy glodny
	var warto: bool = false
	for n in ["kawa", "wodka", "papierosy"]:
		if sklep.lada.ile(P[n]) > 0: warto = true
	if Potrzeby.glod < 50 and (sklep.lada.ile(P["chleb"]) > 0 or sklep.lada.ile(P["kielbasa"]) > 0): warto = true
	if not warto: return
	if not sklep.czy_pod_lada(): sklep.odstoj_kolejke()
	var rezerwa: int = 2500 if Zadanie.kroki()[0][1] and Zadanie.kroki()[1][1] else 0
	for n in ["papierosy", "kawa", "wodka", "chleb", "kielbasa"]:
		while sklep.lada.ile(P[n]) > 0 and Ekwipunek.pieniadze - P[n].cena_urzedowa >= rezerwa:
			if n in ["chleb", "kielbasa"] and ile("chleb") + ile("kielbasa") >= 2: break
			if n == "wodka" and Ekwipunek.pieniadze < 1200: break
			if sklep.kup(P[n]) != "": break

func _spoleczne() -> void:
	var sasiad: PostacNPC = swiat.get_node("Sasiad")
	var komb: PostacNPC = swiat.get_node("Kombinator")
	var kier: PostacNPC = swiat.get_node("Zaklad/Kierownik")
	for npc in [sasiad, komb, kier]: Rozmowa.pogadaj(npc)
	# sasiad: papierosy -> kawa
	if Relacje.relacja(sasiad.dane) < sasiad.dane.prog_wymiany and ile("papierosy") >= 2: Rozmowa.daj_prezent(sasiad, P["papierosy"])
	if ile("papierosy") > 0 and Rozmowa.czy_wymiana_mozliwa(sasiad): Rozmowa.wymien(sasiad, P["papierosy"], P["kawa"])
	# kombinator: czesc
	if ile("czesc_do_pralki") == 0 and ile("pralka_frania") == 0:
		if Relacje.relacja(komb.dane) < komb.dane.prog_wymiany and (ile("kawa") + ile("wodka")) >= 2:
			Rozmowa.daj_prezent(komb, P["kawa"] if ile("kawa") > 0 else P["wodka"])
		if Rozmowa.czy_wymiana_mozliwa(komb):
			if ile("wodka") > 0: Rozmowa.wymien(komb, P["wodka"], P["czesc_do_pralki"])
			elif ile("kawa") > 0: Rozmowa.wymien(komb, P["kawa"], P["czesc_do_pralki"])
	# kierownik: talon
	if ile("talon_na_pralke") == 0 and ile("pralka_frania") == 0:
		if Relacje.relacja(kier.dane) < kier.dane.prog_wymiany and (ile("kawa") + ile("wodka")) >= 1 and ile("czesc_do_pralki") > 0:
			Rozmowa.daj_prezent(kier, P["kawa"] if ile("kawa") > 0 else P["wodka"])
		elif Relacje.relacja(kier.dane) < kier.dane.prog_wymiany and (ile("kawa") + ile("wodka")) >= 2:
			Rozmowa.daj_prezent(kier, P["kawa"] if ile("kawa") > 0 else P["wodka"])
		if Rozmowa.czy_wymiana_mozliwa(kier):
			if ile("wodka") > 0: Rozmowa.wymien(kier, P["wodka"], P["talon_na_pralke"])
			elif ile("kawa") > 0: Rozmowa.wymien(kier, P["kawa"], P["talon_na_pralke"])

func _jedz() -> void:
	if Potrzeby.glod < 45:
		if ile("chleb") > 0: Ekwipunek.zjedz(P["chleb"])
		elif ile("kielbasa") > 0: Ekwipunek.zjedz(P["kielbasa"])

func _dzien(sklep: Sklep, zaklad: Zaklad, ryzyko: bool) -> void:
	# 7:00 start dnia
	_jedz()
	if zaklad.czy_dzien_roboczy():
		Zegar.przewin_do_godziny(8)
		_zakupy(sklep) if false else null  # w dzien roboczy nie stoimy rano, bo spoznienie
		zaklad.pracuj(ryzyko and ile("papierosy") == 0 and Relacje.relacja(zaklad.kierownik) >= 50)
		_jedz()
		_zakupy(sklep)  # 16:00+, kolejka dluga
	else:
		Zegar.przewin_do_godziny(8); Zegar.przewin_minuty(5)
		_zakupy(sklep)
	_spoleczne()
	_jedz()
	if Zadanie.czy_ma_cel(): return
	if ile("talon_na_pralke") > 0 and ile("czesc_do_pralki") > 0 and Ekwipunek.pieniadze >= 2500 and sklep.czy_otwarty():
		sklep.kup_pralke()
	if Zadanie.czy_ma_cel(): return
	Zegar.przewin_do_godziny(7)
	Potrzeby.odpocznij(10)

func _symuluj() -> void:
	var sklep: Sklep = swiat.get_node("Sklep")
	var zaklad: Zaklad = swiat.get_node("Zaklad")
	for ryzyko in [false, true]:
		var wygrane: int = 0; var czesci: int = 0; var talony: int = 0; var kasa: int = 0; var dni_suma: int = 0
		for t in TYGODNI:
			_reset()
			while Zegar.numer_dnia <= 7 and not Zadanie.czy_ma_cel():
				_dzien(sklep, zaklad, ryzyko)
			if Zadanie.czy_ma_cel(): wygrane += 1; dni_suma += Zegar.numer_dnia
			if ile("czesc_do_pralki") > 0 or Zadanie.czy_ma_cel(): czesci += 1
			if ile("talon_na_pralke") > 0 or Zadanie.czy_ma_cel(): talony += 1
			if Ekwipunek.pieniadze >= 2500 or Zadanie.czy_ma_cel(): kasa += 1
		print("[strategia %s] wygrane: %d/%d (%.0f%%)  mial czesc: %d  mial talon: %d  mial 2500 zl: %d  sredni dzien wygranej: %.1f" % [
			"z zalatwianiem" if ryzyko else "uczciwa", wygrane, TYGODNI, 100.0 * wygrane / TYGODNI, czesci, talony, kasa, (float(dni_suma) / wygrane) if wygrane > 0 else 0.0])
	get_tree().quit()
