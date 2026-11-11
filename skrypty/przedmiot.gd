class_name Przedmiot
extends Resource
## Opis jednego rodzaju przedmiotu (chleb, kawa...). To zasób `.tres`, nie węzeł:
## dane trzymamy w plikach w `dane/przedmioty/`, a kod tylko je czyta.
## Dzięki temu nową rzecz dodasz w edytorze bez dotykania skryptów.

## Krótki identyfikator bez polskich znaków, np. "chleb". Przyda się dostawom i zadaniom.
@export var id: StringName
## Nazwa pokazywana graczowi.
@export var nazwa: String
@export_multiline var opis: String
## Ikona w oknie plecaka. Na razie kolorowe kwadraty, później podmienimy na grafiki.
@export var ikona: Texture2D
## Cena w sklepie w złotych. 0 oznacza, że rzeczy nie da się kupić, tylko załatwić.
@export_range(0, 100000, 1, "suffix:zł") var cena_urzedowa: int = 0
## Czy można to zjeść z plecaka.
@export var jadalny: bool = false
## O ile punktów rośnie pasek głodu po zjedzeniu.
@export_range(0.0, 100.0, 1.0) var ile_syci: float = 0.0
