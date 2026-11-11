extends Node
## Zegar gry (autoload `Zegar`): liczy czas, dni i wysyła sygnały o jego upływie.
## Jest autoloadem, żeby przetrwał zmianę sceny i był dostępny z każdego skryptu.

## Wysyłany po każdej pełnej minucie gry (HUD odświeża po nim napis).
signal minuta_minela(godzina: int, minuta: int)
## Wysyłany po każdej pełnej godzinie gry (przyda się potrzebom i dostawom).
signal godzina_minela(godzina: int)
## Wysyłany o północy, gdy zaczyna się nowy dzień.
signal dzien_minal(numer_dnia: int)

const MINUT_W_GODZINIE: int = 60
const MINUT_W_DNIU: int = 24 * MINUT_W_GODZINIE
const NAZWY_DNI: Array[String] = [
	"Poniedziałek", "Wtorek", "Środa", "Czwartek", "Piątek", "Sobota", "Niedziela",
]

## Ile prawdziwych sekund trwa jeden dzień gry. Na start 5 minut.
@export_range(10.0, 3600.0, 1.0, "suffix:s") var dlugosc_dnia_sekundy: float = 300.0
## O której zaczyna się gra pierwszego dnia.
@export_range(0, 23) var godzina_startowa: int = 7

## Numer dnia od początku gry (1 = pierwszy dzień). Tydzień to dni 1-7.
var numer_dnia: int = 1
## Można zatrzymać czas, np. gdy otwarte jest okno rozmowy albo plecaka.
var plynie: bool = true

## Ile minut gry minęło od północy, z ułamkiem. Jedna liczba zamiast osobnych
## godzin i minut upraszcza liczenie: godzinę i minutę wyliczamy z niej na żądanie.
var _minuty_dnia: float = 0.0


func _ready() -> void:
	resetuj()


## Stan początkowy: używany na starcie i przy „zagraj ponownie".
func resetuj() -> void:
	numer_dnia = 1
	plynie = true
	_minuty_dnia = godzina_startowa * MINUT_W_GODZINIE
	minuta_minela.emit(godzina(), minuta())


func _process(delta: float) -> void:
	if not plynie:
		return
	# Proporcja: cały dzień (1440 minut) ma minąć w `dlugosc_dnia_sekundy` sekund.
	_dodaj_minuty(delta * MINUT_W_DNIU / dlugosc_dnia_sekundy)


func godzina() -> int:
	return int(_minuty_dnia) / MINUT_W_GODZINIE


func minuta() -> int:
	return int(_minuty_dnia) % MINUT_W_GODZINIE


func nazwa_dnia() -> String:
	return NAZWY_DNI[(numer_dnia - 1) % NAZWY_DNI.size()]


func tekst_godziny() -> String:
	return "%02d:%02d" % [godzina(), minuta()]


## Przewija czas do najbliższej podanej godziny (zawsze do przodu).
## Jeśli ta godzina dziś już minęła, trafiamy na jutro. Zwraca liczbę przewiniętych minut.
func przewin_do_godziny(godzina_docelowa: int) -> int:
	var teraz: int = int(_minuty_dnia)
	var cel: int = godzina_docelowa * MINUT_W_GODZINIE
	var ile: int = cel - teraz
	if ile <= 0:
		ile += MINUT_W_DNIU
	# Odejmujemy ułamek bieżącej minuty, żeby wylądować dokładnie na pełnej godzinie.
	_dodaj_minuty(float(ile) - (_minuty_dnia - teraz))
	return ile


## Przewija czas o podaną liczbę minut (np. stanie w kolejce, zmiana w pracy).
func przewin_minuty(ile: int) -> void:
	if ile > 0:
		_dodaj_minuty(float(ile))


## Przesuwa czas o podaną liczbę minut, wysyłając po drodze sygnały za każdą
## pełną godzinę i każdą północ. Dzięki temu sen o 10 godzin „przeżywa" te godziny
## tak samo jak zwykły upływ czasu, a inne systemy (głód, dostawy) o tym wiedzą.
func _dodaj_minuty(ile: float) -> void:
	var minuta_przed: int = int(_minuty_dnia)
	var dzien_przed: int = numer_dnia
	var pozostalo: float = ile
	while pozostalo > 0.0:
		var nastepna_pelna_godzina: int = (godzina() + 1) * MINUT_W_GODZINIE
		var do_pelnej_godziny: float = nastepna_pelna_godzina - _minuty_dnia
		if pozostalo < do_pelnej_godziny:
			_minuty_dnia += pozostalo
			break
		# Wskakujemy dokładnie na pełną godzinę (bez błędów zaokrągleń liczb zmiennoprzecinkowych).
		pozostalo -= do_pelnej_godziny
		_minuty_dnia = nastepna_pelna_godzina
		if _minuty_dnia >= MINUT_W_DNIU:
			_minuty_dnia -= MINUT_W_DNIU
			numer_dnia += 1
			dzien_minal.emit(numer_dnia)
		godzina_minela.emit(godzina())
	if int(_minuty_dnia) != minuta_przed or numer_dnia != dzien_przed:
		minuta_minela.emit(godzina(), minuta())
