extends Node3D
## Lodówka: schowek w mieszkaniu. Po użyciu prosi okno plecaka o otwarcie
## w trybie przekładania. Sama nie zna okna, tylko wysyła sygnał.

## Wysyłany po użyciu. Okno plecaka podpina się do niego w scenie świata.
signal otworzono(schowek: Schowek, nazwa: String)

## Nazwa pokazywana nad listą w oknie.
@export var nazwa: String = "Lodówka"

var schowek: Schowek = Schowek.new()


## Podłączone w scenie do sygnału `uzyto` komponentu Interakcja.
func _na_uzycie() -> void:
	otworzono.emit(schowek, nazwa)
