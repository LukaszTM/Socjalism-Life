class_name Schowek
extends RefCounted
## Pojemnik na przedmioty: „jaki przedmiot, ile sztuk". Używa go plecak gracza
## i lodówka, a później lada w sklepie. Jedna klasa zamiast trzech osobnych list,
## bo zasady (dodaj, zabierz, policz) są wszędzie takie same.

## Wysyłany po każdej zmianie zawartości, żeby okno plecaka wiedziało, kiedy się odświeżyć.
signal zmieniony

## Klucz: zasób Przedmiot, wartość: liczba sztuk. Przedmiotów z zerem tu nie trzymamy.
var _ilosci: Dictionary[Przedmiot, int] = {}


func dodaj(przedmiot: Przedmiot, ile: int = 1) -> void:
	if ile <= 0:
		return
	_ilosci[przedmiot] = _ilosci.get(przedmiot, 0) + ile
	zmieniony.emit()


## Zwraca false, gdy nie ma wystarczająco sztuk. Wtedy nic nie zabiera.
func zabierz(przedmiot: Przedmiot, ile: int = 1) -> bool:
	if ile <= 0 or self.ile(przedmiot) < ile:
		return false
	_ilosci[przedmiot] -= ile
	if _ilosci[przedmiot] == 0:
		_ilosci.erase(przedmiot)
	zmieniony.emit()
	return true


func wyczysc() -> void:
	if _ilosci.is_empty():
		return
	_ilosci.clear()
	zmieniony.emit()


func ile(przedmiot: Przedmiot) -> int:
	return _ilosci.get(przedmiot, 0)


func pusty() -> bool:
	return _ilosci.is_empty()


## Lista przedmiotów posortowana po nazwie, żeby okno zawsze wyglądało tak samo.
func lista() -> Array[Przedmiot]:
	var wynik: Array[Przedmiot] = []
	wynik.assign(_ilosci.keys())
	wynik.sort_custom(func(a: Przedmiot, b: Przedmiot) -> bool: return a.nazwa < b.nazwa)
	return wynik
