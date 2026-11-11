class_name Rozmowa
extends RefCounted
## Zasady rozmów w jednym miejscu: ile daje pogawędka, prezent, kiedy możliwa wymiana.
## Czysta logika bez węzłów, jak Kolejka. Okno rozmowy tylko ją woła i pokazuje wynik.

## Zwykła pogawędka: mały plus, raz dziennie na osobę.
const RELACJA_ZA_ROZMOWE: int = 3
## Prezent z listy „czego potrzebuje" cieszy bardziej niż byle co.
const RELACJA_ZA_PREZENT_TRAFIONY: int = 15
const RELACJA_ZA_PREZENT_ZWYKLY: int = 4
## Jedna wymiana dziennie na osobę: ludzie nie mają nieskończonych zapasów.
const WYMIAN_DZIENNIE: int = 1


static func czy_mozna_pogadac(npc: PostacNPC) -> bool:
	return npc.dzien_ostatniej_rozmowy != Zegar.numer_dnia


static func pogadaj(npc: PostacNPC) -> String:
	if not czy_mozna_pogadac(npc):
		return "%s: Już dziś gadaliśmy. Nie mam całego dnia." % npc.dane.imie
	npc.dzien_ostatniej_rozmowy = Zegar.numer_dnia
	Relacje.zmien(npc.dane, RELACJA_ZA_ROZMOWE)
	return "%s: %s\n(Relacja +%d)" % [npc.dane.imie, npc.dane.powitanie, RELACJA_ZA_ROZMOWE]


## Oddaje jedną sztukę z plecaka. Zwraca opis reakcji.
static func daj_prezent(npc: PostacNPC, przedmiot: Przedmiot) -> String:
	if not Ekwipunek.plecak.zabierz(przedmiot, 1):
		return "Nie masz tego przy sobie."
	var trafiony: bool = przedmiot in npc.dane.czego_potrzebuje
	var ile: int = RELACJA_ZA_PREZENT_TRAFIONY if trafiony else RELACJA_ZA_PREZENT_ZWYKLY
	Relacje.zmien(npc.dane, ile)
	if trafiony:
		return "%s: O! %s! Tego mi właśnie brakowało. Pamiętam takie rzeczy.\n(Relacja +%d)" % [npc.dane.imie, przedmiot.nazwa, ile]
	return "%s: %s? No... dziękuję. Zawsze się przyda.\n(Relacja +%d)" % [npc.dane.imie, przedmiot.nazwa, ile]


static func czy_wymiana_mozliwa(npc: PostacNPC) -> bool:
	return Relacje.relacja(npc.dane) >= npc.dane.prog_wymiany


static func czy_wymiana_dzis_wykorzystana(npc: PostacNPC) -> bool:
	return npc.dzien_ostatniej_wymiany == Zegar.numer_dnia and npc.wymian_dzis >= WYMIAN_DZIENNIE


## Pary (co daję, co biorę), na które gracza teraz stać: ma przedmiot, a postać go chce i ma coś w zamian.
static func mozliwe_wymiany(npc: PostacNPC) -> Array[Array]:
	var pary: Array[Array] = []
	for daje: Przedmiot in npc.dane.czego_potrzebuje:
		if Ekwipunek.plecak.ile(daje) <= 0:
			continue
		for bierze: Przedmiot in npc.dane.co_oferuje:
			pary.append([daje, bierze])
	return pary


## Wymiana jeden za jeden. Zwraca opis wyniku.
static func wymien(npc: PostacNPC, daje: Przedmiot, bierze: Przedmiot) -> String:
	if not czy_wymiana_mozliwa(npc):
		return "%s: Z obcymi nie handluję. Najpierw się poznajmy." % npc.dane.imie
	if czy_wymiana_dzis_wykorzystana(npc):
		return "%s: Na dziś koniec interesów. Przyjdź jutro." % npc.dane.imie
	if not (daje in npc.dane.czego_potrzebuje) or not (bierze in npc.dane.co_oferuje):
		return "%s: Takiej wymiany nie robię." % npc.dane.imie
	if not Ekwipunek.plecak.zabierz(daje, 1):
		return "Nie masz tego przy sobie."
	Ekwipunek.plecak.dodaj(bierze, 1)
	if npc.dzien_ostatniej_wymiany != Zegar.numer_dnia:
		npc.wymian_dzis = 0
	npc.dzien_ostatniej_wymiany = Zegar.numer_dnia
	npc.wymian_dzis += 1
	npc.wymieniono.emit(daje, bierze)
	return "%s: Umowa stoi. %s za %s. Tylko nikomu ani słowa." % [npc.dane.imie, bierze.nazwa, daje.nazwa]
