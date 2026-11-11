class_name WierszPrzedmiotu
extends HBoxContainer
## Jeden wiersz listy przedmiotów: ikona, nazwa z ilością, dodatkowa informacja
## (np. cena) i dowolne przyciski. Używają go plecak i sklep, żeby wyglądały tak samo
## i żeby zmiana wyglądu wiersza była w jednym miejscu.

@onready var ikona: TextureRect = %Ikona
@onready var etykieta_nazwy: Label = %Nazwa
@onready var etykieta_info: Label = %Info
@onready var przyciski: HBoxContainer = %Przyciski


func ustaw(przedmiot: Przedmiot, ile: int, info: String = "") -> void:
	ikona.texture = przedmiot.ikona
	etykieta_nazwy.text = "%s × %d" % [przedmiot.nazwa, ile]
	etykieta_nazwy.tooltip_text = przedmiot.opis
	etykieta_info.text = info
	etykieta_info.visible = info != ""


## Dodaje przycisk i podpina do niego funkcję bez argumentów.
func dodaj_przycisk(tekst: String, akcja: Callable) -> Button:
	var przycisk: Button = Button.new()
	przycisk.text = tekst
	przycisk.pressed.connect(akcja)
	przyciski.add_child(przycisk)
	return przycisk
