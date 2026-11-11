extends Node3D
## Łóżko: po użyciu przewija zegar do rana i odnawia energię za przespane godziny.

## O której wstajemy po śnie.
@export_range(0, 23) var godzina_pobudki: int = 7


## Podłączone w scenie do sygnału `uzyto` komponentu Interakcja.
func _na_uzycie() -> void:
	var przespane_minuty: int = Zegar.przewin_do_godziny(godzina_pobudki)
	# Zegar zwraca minuty, a potrzeby liczą energię w godzinach snu.
	Potrzeby.odpocznij(przespane_minuty / 60.0)
