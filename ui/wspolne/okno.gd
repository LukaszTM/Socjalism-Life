class_name Okno
extends CanvasLayer
## Wspólna podstawa okien (plecak, sklep, praca, rozmowa). Otwarte okno pauzuje grę,
## zamyka się klawiszem Esc i pilnuje, żeby naraz było otwarte tylko jedno okno.
## Dzięki temu każde okno zajmuje się tylko swoją treścią.

signal otwarto
signal zamknieto

## Okno, które jest teraz otwarte. Wspólne dla wszystkich okien (static), bo chodzi
## o jedną informację w całej grze: „czy coś już jest otwarte".
static var aktywne: Okno = null


func _ready() -> void:
	hide()


func _unhandled_input(zdarzenie: InputEvent) -> void:
	if visible and zdarzenie.is_action_pressed("ui_cancel"):
		zamknij()
		get_viewport().set_input_as_handled()


func czy_mozna_otworzyc() -> bool:
	return aktywne == null or aktywne == self


func otworz() -> void:
	if not czy_mozna_otworzyc():
		return
	aktywne = self
	show()
	get_tree().paused = true
	otwarto.emit()


func zamknij() -> void:
	if not visible:
		return
	hide()
	get_tree().paused = false
	if aktywne == self:
		aktywne = null
	zamknieto.emit()
