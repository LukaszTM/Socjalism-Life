class_name Kolejka
extends RefCounted
## Zasady kolejki w jednym miejscu. Czysta logika bez węzłów, żeby łatwo ją stroić
## i testować. Sklep tylko pyta: ile stać i co się stanie z towarem.

## Tyle stoi się zawsze, nawet tuż po dostawie.
const MINUTY_BAZOWE: int = 15
## O ile rośnie kolejka za każdą minutę od dostawy. Wieść o towarze się rozchodzi,
## więc im później przyjdziesz, tym więcej ludzi stoi przed tobą.
const PRZYROST_NA_MINUTE: float = 0.5
const MAKS_MINUT: int = 180
## Co tyle minut kolejki jedna osoba przed tobą kupuje jedną rzecz.
const MINUT_NA_OSOBE: int = 30


static func szacuj_minuty(minuty_od_dostawy: int) -> int:
	var minuty: int = MINUTY_BAZOWE + int(minuty_od_dostawy * PRZYROST_NA_MINUTE)
	return clampi(minuty, MINUTY_BAZOWE, MAKS_MINUT)


static func ile_osob_przed(minuty_kolejki: int) -> int:
	return minuty_kolejki / MINUT_NA_OSOBE


## Ludzie przed graczem kupują losowe sztuki z lady. Zwraca, ile sztuk zniknęło.
## Dzięki temu towar może się skończyć, zanim gracz dojdzie do lady.
static func odstoj(lada: Schowek, minuty_kolejki: int, rng: RandomNumberGenerator) -> int:
	var zniknelo: int = 0
	for i: int in ile_osob_przed(minuty_kolejki):
		var dostepne: Array[Przedmiot] = lada.lista()
		if dostepne.is_empty():
			break
		var wybrany: Przedmiot = dostepne[rng.randi_range(0, dostepne.size() - 1)]
		if lada.zabierz(wybrany, 1):
			zniknelo += 1
	return zniknelo
