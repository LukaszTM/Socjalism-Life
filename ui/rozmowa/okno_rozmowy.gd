extends Okno
## Okno rozmowy z postacią: pogadaj, daj prezent, zaproponuj wymianę.
## Co wolno i co to daje, liczy `Rozmowa`; tu tylko przyciski i teksty.

const SCENA_WIERSZA: PackedScene = preload("res://ui/wspolne/wiersz_przedmiotu.tscn")

@onready var etykieta_imienia: Label = %Imie
@onready var etykieta_relacji: Label = %Relacja
@onready var etykieta_tresci: Label = %Tresc
@onready var lista: VBoxContainer = %Lista
@onready var przyciski: HBoxContainer = %Przyciski

var _npc: PostacNPC = null


func _ready() -> void:
	super()
	Relacje.relacja_zmieniona.connect(func(_p: Postac, _w: int) -> void: _odswiez_relacje())


## Podłączone w scenie świata do sygnału `rozmowa_rozpoczeta` każdej postaci.
func otworz_rozmowe(npc: PostacNPC) -> void:
	if not czy_mozna_otworzyc():
		return
	_npc = npc
	etykieta_imienia.text = "%s, %s" % [npc.dane.imie, npc.dane.rola]
	otworz()
	_odswiez_relacje()
	etykieta_tresci.text = npc.dane.opis
	_pokaz_menu()


func zamknij() -> void:
	_npc = null
	super()


func _odswiez_relacje() -> void:
	if _npc == null or not visible:
		return
	etykieta_relacji.text = "Relacja: %s (%d/100)" % [Relacje.opis(_npc.dane), Relacje.relacja(_npc.dane)]


## Główne menu rozmowy.
func _pokaz_menu() -> void:
	_wyczysc(lista)
	_wyczysc(przyciski)
	var pogadaj: Button = _dodaj_przycisk("Pogadaj", func() -> void:
		etykieta_tresci.text = Rozmowa.pogadaj(_npc))
	pogadaj.disabled = not Rozmowa.czy_mozna_pogadac(_npc)
	var prezent: Button = _dodaj_przycisk("Daj prezent", _pokaz_prezenty)
	prezent.disabled = Ekwipunek.plecak.pusty()
	if not _npc.dane.co_oferuje.is_empty():
		_dodaj_przycisk("Zaproponuj wymianę", _pokaz_wymiany)
	_dodaj_przycisk("Odejdź", zamknij)


## Lista rzeczy z plecaka do podarowania.
func _pokaz_prezenty() -> void:
	_wyczysc(lista)
	_wyczysc(przyciski)
	etykieta_tresci.text = "Co chcesz dać? Lubi: %s." % _nazwy(_npc.dane.czego_potrzebuje)
	for przedmiot: Przedmiot in Ekwipunek.plecak.lista():
		var wiersz: WierszPrzedmiotu = SCENA_WIERSZA.instantiate()
		var ile: int = Ekwipunek.plecak.ile(przedmiot)
		var trafiony: bool = przedmiot in _npc.dane.czego_potrzebuje
		wiersz.ready.connect(func() -> void:
			wiersz.ustaw(przedmiot, ile, "ucieszy się!" if trafiony else "")
			wiersz.dodaj_przycisk("Daj", func() -> void:
				etykieta_tresci.text = Rozmowa.daj_prezent(_npc, przedmiot)
				_pokaz_menu())
		)
		lista.add_child(wiersz)
	_dodaj_przycisk("Wróć", _pokaz_menu)


## Lista możliwych wymian „daję X, biorę Y".
func _pokaz_wymiany() -> void:
	_wyczysc(lista)
	_wyczysc(przyciski)
	if not Rozmowa.czy_wymiana_mozliwa(_npc):
		etykieta_tresci.text = "%s: Z obcymi nie handluję. Najpierw się poznajmy.\n(Potrzebna relacja: %d, masz %d.)" % [
			_npc.dane.imie, _npc.dane.prog_wymiany, Relacje.relacja(_npc.dane)]
	elif Rozmowa.czy_wymiana_dzis_wykorzystana(_npc):
		etykieta_tresci.text = "%s: Na dziś koniec interesów. Przyjdź jutro." % _npc.dane.imie
	else:
		var pary: Array[Array] = Rozmowa.mozliwe_wymiany(_npc)
		if pary.is_empty():
			etykieta_tresci.text = "%s: Chętnie bym się wymienił, ale nie masz nic, co mnie interesuje.\nSzuka: %s. Oferuje: %s." % [
				_npc.dane.imie, _nazwy(_npc.dane.czego_potrzebuje), _nazwy(_npc.dane.co_oferuje)]
		else:
			etykieta_tresci.text = "%s: Co proponujesz? Jeden za jeden." % _npc.dane.imie
			for para: Array in pary:
				var daje: Przedmiot = para[0]
				var bierze: Przedmiot = para[1]
				var wiersz: WierszPrzedmiotu = SCENA_WIERSZA.instantiate()
				wiersz.ready.connect(func() -> void:
					wiersz.ustaw(bierze, 1, "za: %s" % daje.nazwa)
					wiersz.dodaj_przycisk("Wymień", func() -> void:
						etykieta_tresci.text = Rozmowa.wymien(_npc, daje, bierze)
						_wyczysc(lista)
						_wyczysc(przyciski)
						_dodaj_przycisk("Wróć", _pokaz_menu))
				)
				lista.add_child(wiersz)
	_dodaj_przycisk("Wróć", _pokaz_menu)


func _nazwy(przedmioty: Array[Przedmiot]) -> String:
	var n: Array[String] = []
	for p: Przedmiot in przedmioty:
		n.append(p.nazwa.to_lower())
	return ", ".join(n) if not n.is_empty() else "nic szczególnego"


func _dodaj_przycisk(tekst: String, akcja: Callable) -> Button:
	var przycisk: Button = Button.new()
	przycisk.text = tekst
	przycisk.pressed.connect(akcja)
	przyciski.add_child(przycisk)
	return przycisk


func _wyczysc(kontener: Container) -> void:
	for dziecko: Node in kontener.get_children():
		kontener.remove_child(dziecko)
		dziecko.queue_free()
