extends Node
func _ready() -> void:
	var swiat: Node3D = load("res://gra/swiat.tscn").instantiate()
	add_child(swiat)
	var zaklad: Zaklad = swiat.get_node("Zaklad")
	var k: Postac = zaklad.kierownik
	var r0: int = Relacje.relacja(k)
	Zegar.przewin_do_godziny(7)  # wtorek, w poniedzialek nie pracowal
	var r1: int = Relacje.relacja(k)
	zaklad.dzien_ostatniej_zmiany = 2  # udajemy, ze we wtorek pracowal
	Zegar.przewin_do_godziny(7)  # sroda
	var r2: int = Relacje.relacja(k)
	Zegar.numer_dnia = 6  # sobota
	Zegar.przewin_do_godziny(7)  # niedziela, sobota wolna -> bez kary
	var r3: int = Relacje.relacja(k)
	print("[nieobecnosc] start=", r0, " po pon bez pracy=", r1, " (ma byc -15); po wt z praca=", r2, " (bez zmian); po wolnej sobocie=", r3, " (bez zmian)")
	get_tree().quit()
