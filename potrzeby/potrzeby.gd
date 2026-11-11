extends Node
## Potrzeby gracza (autoload `Potrzeby`): głód i energia w skali 0-100.
## 100 oznacza „w pełni zaspokojona", 0 to stan krytyczny.
## Spadają z każdą godziną gry, bo zegar wysyła sygnał godzinowy zarówno
## przy zwykłym upływie czasu, jak i przy przewijaniu (sen). Dzięki temu
## przespane godziny też kosztują.

signal glod_zmieniony(wartosc: float)
signal energia_zmieniona(wartosc: float)

const MAKS: float = 100.0

## O ile spada głód co godzinę gry. 6 punktów = pełny brzuch starcza na ok. 16 godzin.
@export_range(0.0, 50.0, 0.5) var spadek_glodu_na_godzine: float = 6.0
## O ile spada energia co godzinę gry. 5 punktów = ok. 20 godzin na nogach.
@export_range(0.0, 50.0, 0.5) var spadek_energii_na_godzine: float = 5.0
## Ile energii daje godzina snu. 12,5 punktu = 8 godzin snu odnawia całość.
@export_range(0.0, 50.0, 0.5) var energia_za_godzine_snu: float = 12.5
## Mnożnik prędkości chodu, gdy głód albo energia spadną do zera.
@export_range(0.1, 1.0, 0.05) var mnoznik_predkosci_wyczerpania: float = 0.5

var glod: float = MAKS
var energia: float = MAKS


func _ready() -> void:
	Zegar.godzina_minela.connect(_na_godzine)


func _na_godzine(_godzina: int) -> void:
	ustaw_glod(glod - spadek_glodu_na_godzine)
	ustaw_energie(energia - spadek_energii_na_godzine)


## Jedzenie podnosi głód (czyli sytość) o podaną liczbę punktów.
func zjedz(ile_syci: float) -> void:
	ustaw_glod(glod + ile_syci)


## Sen odnawia energię proporcjonalnie do przespanych godzin.
func odpocznij(godziny_snu: float) -> void:
	ustaw_energie(energia + godziny_snu * energia_za_godzine_snu)


func czy_wyczerpany() -> bool:
	return glod <= 0.0 or energia <= 0.0


## Gracz mnoży przez to swoją prędkość. Wyczerpana postać wyraźnie zwalnia.
func mnoznik_predkosci() -> float:
	if czy_wyczerpany():
		return mnoznik_predkosci_wyczerpania
	return 1.0


## Wszystkie zmiany przechodzą przez te dwie funkcje, żeby wartość zawsze
## mieściła się w 0-100 i żeby HUD dostał sygnał tylko wtedy, gdy coś się zmieniło.
func ustaw_glod(nowa: float) -> void:
	nowa = clampf(nowa, 0.0, MAKS)
	if is_equal_approx(nowa, glod):
		return
	glod = nowa
	glod_zmieniony.emit(glod)


func ustaw_energie(nowa: float) -> void:
	nowa = clampf(nowa, 0.0, MAKS)
	if is_equal_approx(nowa, energia):
		return
	energia = nowa
	energia_zmieniona.emit(energia)
