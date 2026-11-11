class_name Gracz
extends CharacterBody3D
## Postać gracza: odbiera klawisze i porusza ciałem fizycznym.
## Nie wie nic o kamerze ani o świecie, tylko o własnym ruchu.

## Prędkość chodu w metrach na sekundę (postać ma 1,8 m wzrostu).
@export var predkosc: float = 4.0

## Kąt, o jaki obracamy kierunek z klawiszy. Kamera patrzy pod kątem 45°,
## więc bez tej poprawki „w górę" prowadziłoby po skosie ekranu.
@export var obrot_wejscia_stopnie: float = 45.0


func _physics_process(delta: float) -> void:
	# Wektor z klawiszy: x to lewo/prawo (-1..1), y to góra/dół (-1 to góra).
	var wejscie: Vector2 = Input.get_vector("ruch_lewo", "ruch_prawo", "ruch_gora", "ruch_dol")

	# Przenosimy płaski wektor 2D na płaszczyznę podłogi (oś Z zamiast Y),
	# a potem obracamy wokół osi pionowej, żeby pasował do obrotu kamery.
	var kierunek: Vector3 = Vector3(wejscie.x, 0.0, wejscie.y)
	kierunek = kierunek.rotated(Vector3.UP, deg_to_rad(obrot_wejscia_stopnie))

	velocity.x = kierunek.x * predkosc
	velocity.z = kierunek.z * predkosc

	# Grawitacja trzyma postać na podłodze, gdyby np. zeszła z krawędzi.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0

	# move_and_slide() sam rozwiązuje kolizje: ślizga się po ścianach,
	# zamiast w nie wchodzić. Dlatego nie przechodzimy przez klocki.
	move_and_slide()
