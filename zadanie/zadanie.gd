extends Node
## Zadanie główne (autoload `Zadanie`): zdobyć pralkę w limicie dni.
## Pilnuje postępu na podstawie plecaka i pieniędzy, a o końcu gry
## informuje sygnałami. Nie wie nic o oknach ani o scenie.

signal postep_zmieniony
signal ukonczone
signal przegrane

## Co trzeba zdobyć, żeby wygrać.
@export var cel: Przedmiot
## Składniki łańcucha: do odebrania celu potrzebne są oba plus pieniądze (cena celu).
@export var czesc: Przedmiot
@export var talon: Przedmiot
@export_range(1, 30) var limit_dni: int = 7

var zakonczone: bool = false


func _ready() -> void:
	Ekwipunek.przedmioty_zmienione.connect(_sprawdz)
	Ekwipunek.pieniadze_zmienione.connect(func(_ile: int) -> void: _sprawdz())
	Zegar.dzien_minal.connect(_na_nowy_dzien)


func czy_ma_cel() -> bool:
	return Ekwipunek.plecak.ile(cel) > 0


## Lista kroków dla HUD-u i ekranu końca: [opis, czy zrobione].
func kroki() -> Array[Array]:
	var gotowe: bool = czy_ma_cel()
	return [
		["Część do pralki (od kombinatora)", gotowe or Ekwipunek.plecak.ile(czesc) > 0],
		["Talon na pralkę (od kierownika)", gotowe or Ekwipunek.plecak.ile(talon) > 0],
		["%d zł na pralkę" % cel.cena_urzedowa, gotowe or Ekwipunek.pieniadze >= cel.cena_urzedowa],
		["Odebrać pralkę w sklepie", gotowe],
	]


func dni_pozostale() -> int:
	return maxi(0, limit_dni - Zegar.numer_dnia + 1)


func resetuj() -> void:
	zakonczone = false
	postep_zmieniony.emit()


func _sprawdz() -> void:
	postep_zmieniony.emit()
	if not zakonczone and czy_ma_cel():
		zakonczone = true
		ukonczone.emit()


func _na_nowy_dzien(numer_dnia: int) -> void:
	postep_zmieniony.emit()
	if not zakonczone and numer_dnia > limit_dni:
		zakonczone = true
		przegrane.emit()
