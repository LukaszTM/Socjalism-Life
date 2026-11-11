class_name Dostawa
extends Resource
## Zestaw towaru, jaki może przyjechać do sklepu jednego dnia.
## Pusty zestaw oznacza dzień bez dostawy: taka jest gospodarka niedoboru.

@export var nazwa: String
@export var pozycje: Array[PozycjaDostawy] = []
## Waga losowania: zestaw z wagą 2 wypada dwa razy częściej niż z wagą 1.
@export_range(0.1, 10.0, 0.1) var waga: float = 1.0


func czy_pusta() -> bool:
	return pozycje.is_empty()
