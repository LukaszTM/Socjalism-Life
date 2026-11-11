class_name Sklep
extends Node3D
## Sklep spożywczy: przyjmuje dzienną dostawę na ladę, zna godziny otwarcia,
## liczy kolejkę i sprzedaje. Okno sklepu tylko pokazuje to, co sklep powie.

## Wysyłany po użyciu lady. Okno sklepu podpina się do niego w scenie świata.
signal otworzono(sklep: Sklep)
signal zakupiono(przedmiot: Przedmiot)
signal kolejka_odstana(minuty: int)
## Gracz odstał kolejkę, ale towaru już nie było.
signal odeszli_z_niczym

## Możliwe zestawy dostaw. Losujemy jeden dziennie według wag.
@export var dostawy: Array[Dostawa] = []
## Przedmiot, który liczy się jako kartki żywnościowe przy zakupie mięsa.
@export var kartki: Przedmiot
## Dział AGD: pralka na talon, potrzebna też własna część.
@export var pralka: Przedmiot
@export var talon: Przedmiot
@export var czesc_do_pralki: Przedmiot
## Kto stoi za ladą. Dobra relacja z nią daje towar spod lady, bez kolejki.
@export var sprzedawczynia: Postac
@export_range(0, 100) var prog_pod_lada: int = 50
@export_range(0, 23) var godzina_otwarcia: int = 7
@export_range(0, 23) var godzina_zamkniecia: int = 18
@export_range(0, 23) var godzina_dostawy: int = 8

## Towar na ladzie. Ten sam Schowek, co w plecaku i lodówce.
var lada: Schowek = Schowek.new()
var dzisiejsza_dostawa: Dostawa = null
## Minuta dnia, o której przyszła dostawa; -1 oznacza, że dziś jeszcze nie było.
var minuta_dostawy: int = -1

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	Zegar.godzina_minela.connect(_na_godzine)
	Zegar.dzien_minal.connect(_na_nowy_dzien)


func _na_godzine(godzina: int) -> void:
	if godzina == godzina_dostawy:
		_przyjmij_dostawe()


func _na_nowy_dzien(_numer_dnia: int) -> void:
	# Niesprzedany towar „znika" do rana: ktoś go odłożył pod ladę dla znajomych.
	lada.wyczysc()
	dzisiejsza_dostawa = null
	minuta_dostawy = -1


func czy_otwarty() -> bool:
	var g: int = Zegar.godzina()
	return g >= godzina_otwarcia and g < godzina_zamkniecia


func czy_byla_dostawa() -> bool:
	return minuta_dostawy >= 0


func czy_dostawa_pusta() -> bool:
	return dzisiejsza_dostawa != null and dzisiejsza_dostawa.czy_pusta()


func minuty_od_dostawy() -> int:
	if not czy_byla_dostawa():
		return 0
	return Zegar.godzina() * Zegar.MINUT_W_GODZINIE + Zegar.minuta() - minuta_dostawy


func szacowana_kolejka() -> int:
	return Kolejka.szacuj_minuty(minuty_od_dostawy())


## Znajomej sprzedawczyni nie trzeba stać w kolejce: odkłada towar pod ladę.
func czy_pod_lada() -> bool:
	return sprzedawczynia != null and Relacje.relacja(sprzedawczynia) >= prog_pod_lada


## Gracz staje w kolejce: czas gry leci, ludzie przed nim wykupują towar.
## Zwraca liczbę odstanych minut.
func odstoj_kolejke() -> int:
	var minuty: int = szacowana_kolejka()
	Kolejka.odstoj(lada, minuty, _rng)
	Zegar.przewin_minuty(minuty)
	Statystyki.minuty_w_kolejkach += minuty
	kolejka_odstana.emit(minuty)
	if lada.pusty():
		Statystyki.odejscia_z_niczym += 1
		odeszli_z_niczym.emit()
	return minuty


## Próba zakupu jednej sztuki. Zwraca pusty tekst przy sukcesie albo powód odmowy.
func kup(przedmiot: Przedmiot) -> String:
	if lada.ile(przedmiot) <= 0:
		return "Już nie ma, przed chwilą się skończyło."
	if przedmiot.wymaga_kartek and Ekwipunek.plecak.ile(kartki) <= 0:
		return "Bez kartek nie sprzedam. Takie przepisy."
	if not Ekwipunek.zaplac(przedmiot.cena_urzedowa):
		return "Nie starcza pieniędzy."
	lada.zabierz(przedmiot, 1)
	if przedmiot.wymaga_kartek:
		Ekwipunek.plecak.zabierz(kartki, 1)
	Ekwipunek.plecak.dodaj(przedmiot, 1)
	Statystyki.zakupy += 1
	zakupiono.emit(przedmiot)
	return ""


## Odbiór pralki na talon: dział AGD nie ma kolejki, ale wymaga talonu, własnej części
## (sklep sprzedaje pralki bez programatora) i pełnej ceny. Zwraca powód odmowy albo pusty tekst.
func kup_pralke() -> String:
	if not czy_otwarty():
		return "Zamknięte."
	if Ekwipunek.plecak.ile(talon) <= 0:
		return "Bez talonu nie ma mowy. Pralki idą tylko na przydział."
	if Ekwipunek.plecak.ile(czesc_do_pralki) <= 0:
		return "Pralka jest bez programatora, brakuje części. Bez własnej części to tylko biały bęben."
	if Ekwipunek.pieniadze < pralka.cena_urzedowa:
		return "Pralka kosztuje %d zł. Nie starcza." % pralka.cena_urzedowa
	Ekwipunek.zaplac(pralka.cena_urzedowa)
	Ekwipunek.plecak.zabierz(talon, 1)
	Ekwipunek.plecak.zabierz(czesc_do_pralki, 1)
	Ekwipunek.plecak.dodaj(pralka, 1)
	Statystyki.zakupy += 1
	zakupiono.emit(pralka)
	return ""


func _przyjmij_dostawe() -> void:
	dzisiejsza_dostawa = _losuj_dostawe()
	lada.wyczysc()
	if dzisiejsza_dostawa != null:
		for pozycja: PozycjaDostawy in dzisiejsza_dostawa.pozycje:
			lada.dodaj(pozycja.przedmiot, pozycja.ilosc)
	minuta_dostawy = Zegar.godzina() * Zegar.MINUT_W_GODZINIE + Zegar.minuta()


## Losowanie z wagami: rysujemy liczbę z zakresu 0..suma wag i sprawdzamy,
## w czyj „przedział" trafiła. Zestaw o większej wadze ma szerszy przedział.
func _losuj_dostawe() -> Dostawa:
	if dostawy.is_empty():
		return null
	var suma: float = 0.0
	for d: Dostawa in dostawy:
		suma += d.waga
	var los: float = _rng.randf_range(0.0, suma)
	for d: Dostawa in dostawy:
		los -= d.waga
		if los <= 0.0:
			return d
	return dostawy[dostawy.size() - 1]


## Podłączone w scenie do sygnału `uzyto` komponentu Interakcja przy ladzie.
func _na_uzycie() -> void:
	otworzono.emit(self)
