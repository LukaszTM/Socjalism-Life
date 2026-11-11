extends Node3D
## Łóżko: po użyciu przewija zegar do rana.

## O której wstajemy po śnie.
@export_range(0, 23) var godzina_pobudki: int = 7


## Podłączone w scenie do sygnału `uzyto` komponentu Interakcja.
func _na_uzycie() -> void:
	Zegar.przewin_do_godziny(godzina_pobudki)
