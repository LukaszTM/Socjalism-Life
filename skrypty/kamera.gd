class_name KameraIzometryczna
extends Camera3D
## Kamera ortogonalna, która płynnie podąża za celem.
## Nie jest dzieckiem gracza, żeby jego obroty i drgania nie przenosiły się na obraz.

## Węzeł, za którym jedziemy (zwykle gracz). Ustawiany w scenie świata.
@export var cel: Node3D

## Jak daleko od celu stoi kamera. Przy projekcji ortogonalnej odległość
## nie zmienia wielkości obrazu, ale musi być większa niż wysokość budynków,
## żeby kamera nie „wjeżdżała" w nie.
@export var odleglosc: float = 30.0

## Im większa wartość, tym szybciej kamera dogania cel (mniej „gumy").
@export var plynnosc: float = 6.0


func _ready() -> void:
	# Ustawiamy się od razu na celu, żeby na starcie nie było przejazdu z zera.
	if cel:
		global_position = _pozycja_docelowa()


func _physics_process(delta: float) -> void:
	if not cel:
		return
	# lerp() przesuwa nas tylko o część drogi w każdej klatce,
	# co daje płynne dojeżdżanie zamiast skokowego przyklejenia do celu.
	global_position = global_position.lerp(_pozycja_docelowa(), plynnosc * delta)


func _pozycja_docelowa() -> Vector3:
	# Kamera patrzy wzdłuż ujemnej osi Z własnego układu (basis.z wskazuje „do tyłu"),
	# więc cofamy się od celu o zadaną odległość w tę stronę. Obrót kamery jest stały,
	# ustawiony w scenie, dlatego ten kierunek nie zmienia się w trakcie gry.
	return cel.global_position + global_transform.basis.z * odleglosc
