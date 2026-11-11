extends Node
## Relacje z postaciami (autoload `Relacje`): liczba 0-100 dla każdej postaci.
## Osobny autoload, bo relacja to stan gry, który musi przeżyć zmianę sceny
## i jest potrzebny w kilku modułach (praca, sklep, rozmowa).

signal relacja_zmieniona(postac: Postac, wartosc: int)

const MIN: int = 0
const MAKS: int = 100

## Postacie, z którymi jeszcze nic się nie wydarzyło, mają relację startową z zasobu.
var _relacje: Dictionary[Postac, int] = {}


func relacja(postac: Postac) -> int:
	return _relacje.get(postac, postac.relacja_startowa)


## Zmienia relację o `roznica` (może być ujemna) i zwraca nową wartość.
func zmien(postac: Postac, roznica: int) -> int:
	var nowa: int = clampi(relacja(postac) + roznica, MIN, MAKS)
	if nowa != relacja(postac) or not _relacje.has(postac):
		_relacje[postac] = nowa
		relacja_zmieniona.emit(postac, nowa)
	return nowa


## Czytelny opis dla gracza zamiast gołej liczby.
func opis(postac: Postac) -> String:
	var r: int = relacja(postac)
	if r >= 80:
		return "przyjaciel"
	if r >= 60:
		return "dobry znajomy"
	if r >= 40:
		return "znajomy"
	if r >= 20:
		return "obcy"
	return "niechętny"


func resetuj() -> void:
	_relacje.clear()
