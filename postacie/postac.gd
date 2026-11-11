class_name Postac
extends Resource
## Opis postaci niezależnej (sprzedawczyni, kierownik, sąsiad, kombinator).
## To dane w pliku `.tres`, nie węzeł: kto to jest, czego chce i co ma do zaoferowania.

## Identyfikator bez polskich znaków, np. "kierownik".
@export var id: StringName
@export var imie: String
## Krótka rola widoczna w rozmowie, np. "kierownik zmiany".
@export var rola: String
@export_multiline var opis: String
## Kolor klocka zastępczego, dopóki nie ma modelu.
@export var kolor: Color = Color.GRAY
## Co ta osoba chętnie przyjmie (prezent, wymiana).
@export var czego_potrzebuje: Array[Przedmiot] = []
## Co ma do zaoferowania w wymianie.
@export var co_oferuje: Array[Przedmiot] = []
## Od jakiej relacji zaczynamy (0 obcy, 100 przyjaciel).
@export_range(0, 100) var relacja_startowa: int = 20
@export_multiline var powitanie: String
