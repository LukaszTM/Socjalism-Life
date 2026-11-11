extends VBoxContainer
## Paski głodu i energii. Słuchają potrzeb i tylko ustawiają wartość paska.

@onready var pasek_glodu: ProgressBar = %PasekGlodu
@onready var pasek_energii: ProgressBar = %PasekEnergii


func _ready() -> void:
	Potrzeby.glod_zmieniony.connect(_odswiez_glod)
	Potrzeby.energia_zmieniona.connect(_odswiez_energie)
	# Na starcie sygnały jeszcze nie przyszły, więc wartości bierzemy wprost.
	_odswiez_glod(Potrzeby.glod)
	_odswiez_energie(Potrzeby.energia)


func _odswiez_glod(wartosc: float) -> void:
	pasek_glodu.value = wartosc


func _odswiez_energie(wartosc: float) -> void:
	pasek_energii.value = wartosc
