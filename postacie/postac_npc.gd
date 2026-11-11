class_name PostacNPC
extends Node3D
## Postać na mapie: klocek w kolorze z zasobu Postac i interakcja „Pogadaj".
## Pamięta, co dziś już się z nią wydarzyło (rozmowa, wymiana). Co można zrobić
## i co to daje, rozstrzyga `Rozmowa`; okno rozmowy tylko pokazuje.

## Wysyłany po użyciu. Okno rozmowy podpina się do niego w scenie świata.
signal rozmowa_rozpoczeta(npc: PostacNPC)
signal wymieniono(daje: Przedmiot, bierze: Przedmiot)

@export var dane: Postac

var dzien_ostatniej_rozmowy: int = 0
var dzien_ostatniej_wymiany: int = 0
var wymian_dzis: int = 0

@onready var wyglad: CSGBox3D = $Wyglad
@onready var interakcja: Interakcja = $Interakcja


func _ready() -> void:
	if dane == null:
		push_warning("PostacNPC bez zasobu Postac: %s" % name)
		return
	# Kolor klocka bierzemy z danych postaci, żeby każda była rozpoznawalna bez modelu.
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = dane.kolor
	wyglad.material = material
	interakcja.nazwa_akcji = "Pogadaj: %s" % dane.imie


## Podłączone w scenie do sygnału `uzyto` komponentu Interakcja.
func _na_uzycie() -> void:
	rozmowa_rozpoczeta.emit(self)
