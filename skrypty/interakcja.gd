class_name Interakcja
extends Area3D
## Komponent „można tego użyć". Doczepiany jako dziecko do łóżka, drzwi, lady itd.
## Sam nic nie robi: tylko zgłasza sygnałem, że gracz go użył. Co się wtedy dzieje,
## decyduje właściciel (np. łóżko przewija czas). Dzięki temu jeden skrypt obsłuży
## wszystkie obiekty interakcji w grze.

## Wysyłany, gdy gracz wciśnie klawisz interakcji przy tym obiekcie.
signal uzyto

## Tekst podpowiedzi na ekranie, np. „Śpij", „Kup", „Pogadaj".
@export var nazwa_akcji: String = "Użyj"


func uzyj() -> void:
	uzyto.emit()
