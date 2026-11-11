class_name WykrywaczInterakcji
extends Area3D
## Siedzi na graczu i pilnuje, które obiekty interakcji są w zasięgu.
## Wybiera najbliższy i zgłasza go sygnałem (HUD pokazuje podpowiedź),
## a po wciśnięciu klawisza interakcji każe mu się „użyć".

## Wysyłany, gdy zmienia się najbliższy obiekt. `null` oznacza, że nic nie ma w zasięgu.
signal cel_zmieniony(cel: Interakcja)

var _w_zasiegu: Array[Interakcja] = []
var _cel: Interakcja = null


func _ready() -> void:
	area_entered.connect(_na_wejscie)
	area_exited.connect(_na_wyjscie)


func _physics_process(_delta: float) -> void:
	var najblizszy: Interakcja = _znajdz_najblizszy()
	if najblizszy != _cel:
		_cel = najblizszy
		cel_zmieniony.emit(_cel)


func _unhandled_input(zdarzenie: InputEvent) -> void:
	if _cel != null and zdarzenie.is_action_pressed("interakcja"):
		_cel.uzyj()
		# Oznaczamy zdarzenie jako obsłużone, żeby nikt inny nie zareagował na to samo E.
		get_viewport().set_input_as_handled()


func _na_wejscie(obszar: Area3D) -> void:
	# Do zasięgu mogą wejść różne Area3D; interesują nas tylko te z komponentem Interakcja.
	if obszar is Interakcja:
		_w_zasiegu.append(obszar)


func _na_wyjscie(obszar: Area3D) -> void:
	if obszar is Interakcja:
		_w_zasiegu.erase(obszar)


func _znajdz_najblizszy() -> Interakcja:
	var najblizszy: Interakcja = null
	var najmniejsza_odleglosc: float = INF
	for interakcja: Interakcja in _w_zasiegu:
		# Obiekt mógł zostać usunięty ze sceny, zanim fizyka zgłosiła jego wyjście.
		if not is_instance_valid(interakcja):
			continue
		var odleglosc: float = global_position.distance_squared_to(interakcja.global_position)
		if odleglosc < najmniejsza_odleglosc:
			najmniejsza_odleglosc = odleglosc
			najblizszy = interakcja
	return najblizszy
