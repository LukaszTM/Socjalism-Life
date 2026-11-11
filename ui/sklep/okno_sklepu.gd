extends Okno
## Okno sklepu. Ma dwa widoki: decyzję „stać czy odejść" i zakupy po odstaniu kolejki.
## Całą wiedzę o towarze, kolejce i cenach bierze ze Sklepu; samo tylko wyświetla.

const SCENA_WIERSZA: PackedScene = preload("res://ui/wspolne/wiersz_przedmiotu.tscn")

@onready var etykieta_tresci: Label = %Tresc
@onready var etykieta_pieniedzy: Label = %EtykietaPieniedzy
@onready var etykieta_komunikatu: Label = %Komunikat
@onready var lista_towaru: VBoxContainer = %ListaTowaru
@onready var przyciski: HBoxContainer = %Przyciski

var _sklep: Sklep = null


func _ready() -> void:
	super()
	Ekwipunek.pieniadze_zmienione.connect(_odswiez_pieniadze)


## Podłączone w scenie świata do sygnału `otworzono` sklepu.
func otworz_sklep(sklep: Sklep) -> void:
	if not czy_mozna_otworzyc():
		return
	_sklep = sklep
	_sklep.lada.zmieniony.connect(_odswiez_towar)
	otworz()
	_odswiez_pieniadze(Ekwipunek.pieniadze)
	_pokaz_decyzje()


func zamknij() -> void:
	if _sklep != null:
		_sklep.lada.zmieniony.disconnect(_odswiez_towar)
		_sklep = null
	super()


## Widok 1: co widać na półkach i ile trzeba stać.
func _pokaz_decyzje() -> void:
	_wyczysc(lista_towaru)
	_wyczysc(przyciski)
	etykieta_komunikatu.text = ""
	lista_towaru.hide()

	if not _sklep.czy_otwarty():
		etykieta_tresci.text = "Zamknięte. Sklep otwarty %d:00–%d:00." % [_sklep.godzina_otwarcia, _sklep.godzina_zamkniecia]
	elif not _sklep.czy_byla_dostawa():
		etykieta_tresci.text = "Półki puste. Dostawa zwykle około %d:00, o ile w ogóle przyjedzie." % _sklep.godzina_dostawy
	elif _sklep.czy_dostawa_pusta():
		etykieta_tresci.text = "Dziś nic nie dowieźli. Sprzedawczyni rozkłada ręce."
	elif _sklep.lada.pusty():
		etykieta_tresci.text = "Wszystko już wykupili. Może jutro."
	else:
		var nazwy: Array[String] = []
		for p: Przedmiot in _sklep.lada.lista():
			nazwy.append(p.nazwa)
		var minuty: int = _sklep.szacowana_kolejka()
		etykieta_tresci.text = "Dostawa była o %02d:%02d. Na półkach widzisz: %s.\nKolejka: ok. %d min (%s przed tobą)." % [
			_sklep.minuta_dostawy / 60, _sklep.minuta_dostawy % 60, ", ".join(nazwy), minuty, _odmiana_osob(Kolejka.ile_osob_przed(minuty))]
		_dodaj_przycisk("Stań w kolejce (ok. %d min)" % minuty, _stan_w_kolejce)

	_dodaj_przycisk("Odejdź", zamknij)


func _stan_w_kolejce() -> void:
	var minuty: int = _sklep.odstoj_kolejke()
	_wyczysc(przyciski)
	if _sklep.lada.pusty():
		etykieta_tresci.text = "Stałeś %d min. Gdy doszedłeś do lady, towaru już nie było." % minuty
		_dodaj_przycisk("Odejdź", zamknij)
		return
	etykieta_tresci.text = "Stałeś %d min. Twoja kolej. Co podać?" % minuty
	lista_towaru.show()
	_odswiez_towar()
	_dodaj_przycisk("Dziękuję, to wszystko", zamknij)


## Widok 2: lista towaru z cenami i przyciskiem „Kup".
func _odswiez_towar() -> void:
	if not visible or not lista_towaru.visible or _sklep == null:
		return
	_wyczysc(lista_towaru)
	if _sklep.lada.pusty():
		etykieta_tresci.text = "Wykupiłeś ostatnie sztuki. Półki puste."
		return
	for przedmiot: Przedmiot in _sklep.lada.lista():
		var wiersz: WierszPrzedmiotu = SCENA_WIERSZA.instantiate()
		var ile: int = _sklep.lada.ile(przedmiot)
		wiersz.ready.connect(func() -> void:
			var info: String = "%d zł" % przedmiot.cena_urzedowa
			if przedmiot.wymaga_kartek:
				info += " + kartki"
			wiersz.ustaw(przedmiot, ile, info)
			wiersz.dodaj_przycisk("Kup", func() -> void: _kup(przedmiot))
		)
		lista_towaru.add_child(wiersz)


func _kup(przedmiot: Przedmiot) -> void:
	var odmowa: String = _sklep.kup(przedmiot)
	etykieta_komunikatu.text = odmowa if odmowa != "" else "Kupiono: %s." % przedmiot.nazwa


## „1 osoba", „2 osoby", „5 osób": polska odmiana zależy od ostatniej cyfry.
func _odmiana_osob(ile: int) -> String:
	if ile == 1:
		return "1 osoba"
	var ostatnia: int = ile % 10
	var dwie_ostatnie: int = ile % 100
	if ostatnia >= 2 and ostatnia <= 4 and (dwie_ostatnie < 12 or dwie_ostatnie > 14):
		return "%d osoby" % ile
	return "%d osób" % ile


func _odswiez_pieniadze(ile: int) -> void:
	etykieta_pieniedzy.text = "Pieniądze: %d zł" % ile


func _dodaj_przycisk(tekst: String, akcja: Callable) -> void:
	var przycisk: Button = Button.new()
	przycisk.text = tekst
	przycisk.pressed.connect(akcja)
	przyciski.add_child(przycisk)


func _wyczysc(kontener: Container) -> void:
	for dziecko: Node in kontener.get_children():
		kontener.remove_child(dziecko)
		dziecko.queue_free()
