class_name Zaklad
extends Node3D
## Zakład pracy: zmiana w stałych godzinach daje wypłatę, kosztuje czas i energię.
## Spóźnienie i nieobecność psują relację z kierownikiem. W trakcie zmiany można
## „coś załatwić" na boku: szansa na towar, ryzyko wpadki.

## Stany zakładu, o które pyta okno pracy.
enum Stan { WOLNE, ZA_WCZESNIE, MOZNA, ZA_POZNO, JUZ_BYLO }

## Wysyłany po użyciu bramy. Okno pracy podpina się do niego w scenie świata.
signal otworzono(zaklad: Zaklad)
signal zmiana_odbyta(wyplata: int)
signal wpadka(kara: int)
signal zalatwiono(przedmiot: Przedmiot)
signal nieobecnosc(numer_dnia: int)

@export var kierownik: Postac
@export_range(0, 23) var godzina_startu: int = 8
@export_range(0, 23) var godzina_konca: int = 16
## Dni tygodnia z pracą: 1 = poniedziałek, 7 = niedziela.
@export var dni_robocze: Array[int] = [1, 2, 3, 4, 5]
@export_range(0, 10000, 10, "suffix:zł") var wyplata: int = 400
@export_range(0.0, 100.0, 1.0) var koszt_energii: float = 30.0
## Do tylu minut spóźnienia kierownik przymyka oko.
@export_range(0, 240, 5, "suffix:min") var tolerancja_spoznienia: int = 30
@export_range(0, 50) var kara_relacji_spoznienie: int = 5
@export_range(0, 50) var kara_relacji_nieobecnosc: int = 15

## Co da się wynieść z zakładu, gdy „załatwianie" się uda.
@export var do_zalatwienia: Array[Przedmiot] = []
@export_range(0.0, 1.0, 0.05) var szansa_zalatwienia: float = 0.5
@export_range(0, 10000, 10, "suffix:zł") var kara_pieniezna: int = 300
@export_range(0, 50) var kara_relacji_wpadka: int = 20

## Numer dnia ostatniej odbytej zmiany; 0 oznacza, że gracz jeszcze nie pracował.
var dzien_ostatniej_zmiany: int = 0

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	Zegar.dzien_minal.connect(_na_nowy_dzien)


func czy_dzien_roboczy(numer_dnia: int = Zegar.numer_dnia) -> bool:
	var dzien_tygodnia: int = (numer_dnia - 1) % 7 + 1
	return dzien_tygodnia in dni_robocze


func stan() -> Stan:
	if not czy_dzien_roboczy():
		return Stan.WOLNE
	if dzien_ostatniej_zmiany == Zegar.numer_dnia:
		return Stan.JUZ_BYLO
	var minuta: int = _minuta_dnia()
	if minuta < godzina_startu * Zegar.MINUT_W_GODZINIE:
		return Stan.ZA_WCZESNIE
	if minuta >= godzina_konca * Zegar.MINUT_W_GODZINIE:
		return Stan.ZA_POZNO
	return Stan.MOZNA


## Ile minut po początku zmiany jesteśmy (0, gdy przed czasem).
func spoznienie_minuty() -> int:
	return maxi(0, _minuta_dnia() - godzina_startu * Zegar.MINUT_W_GODZINIE)


## Odbywa zmianę do godziny końca. Zwraca słownik z wynikiem dla okna pracy:
## wyplata, spoznienie, kara_relacji, zalatwiono (Przedmiot albo null), wpadka, kara_pieniezna.
func pracuj(czy_zalatwiac: bool) -> Dictionary:
	var wynik: Dictionary = {
		"wyplata": wyplata,
		"spoznienie": spoznienie_minuty(),
		"kara_relacji": 0,
		"zalatwiono": null,
		"wpadka": false,
		"kara_pieniezna": 0,
	}
	# Czas leci do końca zmiany; po drodze zegar wysyła godziny, więc głód i energia
	# spadają jak zwykle. Koszt energii dochodzi ponad to.
	Zegar.przewin_minuty(godzina_konca * Zegar.MINUT_W_GODZINIE - _minuta_dnia())
	Potrzeby.ustaw_energie(Potrzeby.energia - koszt_energii)
	Ekwipunek.dodaj_pieniadze(wyplata)
	dzien_ostatniej_zmiany = Zegar.numer_dnia

	if wynik["spoznienie"] > tolerancja_spoznienia:
		wynik["kara_relacji"] = kara_relacji_spoznienie
		Relacje.zmien(kierownik, -kara_relacji_spoznienie)

	if czy_zalatwiac and not do_zalatwienia.is_empty():
		if _rng.randf() < szansa_zalatwienia:
			var przedmiot: Przedmiot = do_zalatwienia[_rng.randi_range(0, do_zalatwienia.size() - 1)]
			Ekwipunek.plecak.dodaj(przedmiot, 1)
			wynik["zalatwiono"] = przedmiot
			Statystyki.zalatwione += 1
			zalatwiono.emit(przedmiot)
		else:
			# Kara nie może zabrać więcej, niż gracz ma: zaplac() odmówiłoby, więc bierzemy mniejsze z dwóch.
			var kara: int = mini(kara_pieniezna, Ekwipunek.pieniadze)
			Ekwipunek.zaplac(kara)
			Relacje.zmien(kierownik, -kara_relacji_wpadka)
			wynik["wpadka"] = true
			wynik["kara_pieniezna"] = kara
			Statystyki.wpadki += 1
			wpadka.emit(kara)

	Statystyki.zmiany_w_pracy += 1
	zmiana_odbyta.emit(wyplata)
	return wynik


## O północy sprawdzamy, czy miniony dzień był roboczy i czy gracz się pojawił.
func _na_nowy_dzien(numer_dnia: int) -> void:
	var wczoraj: int = numer_dnia - 1
	if czy_dzien_roboczy(wczoraj) and dzien_ostatniej_zmiany != wczoraj:
		Relacje.zmien(kierownik, -kara_relacji_nieobecnosc)
		nieobecnosc.emit(wczoraj)


func _minuta_dnia() -> int:
	return Zegar.godzina() * Zegar.MINUT_W_GODZINIE + Zegar.minuta()


## Podłączone w scenie do sygnału `uzyto` komponentu Interakcja przy bramie.
func _na_uzycie() -> void:
	otworzono.emit(self)
