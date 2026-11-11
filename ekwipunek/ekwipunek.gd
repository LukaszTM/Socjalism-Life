extends Node
## Ekwipunek gracza (autoload `Ekwipunek`): pieniądze i plecak.
## Autoload, bo stan ma przetrwać zmianę sceny (np. wejście do sklepu).

signal pieniadze_zmienione(ile: int)
signal przedmioty_zmienione

## Z czym zaczynamy grę. Ustawiane w scenie `ekwipunek.tscn`, nie w kodzie.
@export_range(0, 100000, 10, "suffix:zł") var pieniadze_startowe: int = 1500
## Ten sam przedmiot wpisany kilka razy daje kilka sztuk.
@export var przedmioty_startowe: Array[Przedmiot] = []

var pieniadze: int = 0
var plecak: Schowek = Schowek.new()


func _ready() -> void:
	# Przekazujemy sygnał plecaka dalej, żeby UI słuchało jednego miejsca: Ekwipunku.
	plecak.zmieniony.connect(przedmioty_zmienione.emit)
	dodaj_pieniadze(pieniadze_startowe)
	for przedmiot: Przedmiot in przedmioty_startowe:
		plecak.dodaj(przedmiot, 1)


func dodaj_pieniadze(kwota: int) -> void:
	pieniadze += kwota
	pieniadze_zmienione.emit(pieniadze)


## Zwraca false, gdy brakuje pieniędzy. Wtedy nic nie pobiera.
func zaplac(kwota: int) -> bool:
	if kwota > pieniadze:
		return false
	pieniadze -= kwota
	pieniadze_zmienione.emit(pieniadze)
	return true


## Zjada jedną sztukę z plecaka. Zwraca false, gdy rzecz nie jest jadalna albo jej nie mamy.
func zjedz(przedmiot: Przedmiot) -> bool:
	if not przedmiot.jadalny:
		return false
	if not plecak.zabierz(przedmiot, 1):
		return false
	Potrzeby.zjedz(przedmiot.ile_syci)
	return true
