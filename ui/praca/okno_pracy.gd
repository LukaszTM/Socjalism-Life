extends Okno
## Okno pracy: mówi, czy można iść na zmianę, pozwala wybrać uczciwą pracę
## albo „załatwianie" i pokazuje wynik. Całą logikę liczy Zaklad.

@onready var etykieta_tresci: Label = %Tresc
@onready var etykieta_wyniku: Label = %Wynik
@onready var przyciski: HBoxContainer = %Przyciski

var _zaklad: Zaklad = null


## Podłączone w scenie świata do sygnału `otworzono` zakładu.
func otworz_zaklad(zaklad: Zaklad) -> void:
	if not czy_mozna_otworzyc():
		return
	_zaklad = zaklad
	otworz()
	_pokaz_stan()


func zamknij() -> void:
	_zaklad = null
	super()


func _pokaz_stan() -> void:
	_wyczysc(przyciski)
	etykieta_wyniku.text = ""
	match _zaklad.stan():
		Zaklad.Stan.WOLNE:
			etykieta_tresci.text = "Dziś %s. Zakład stoi, brama zamknięta." % Zegar.nazwa_dnia().to_lower()
		Zaklad.Stan.ZA_WCZESNIE:
			etykieta_tresci.text = "Zmiana zaczyna się o %d:00. Jest %s. Portier nie wpuści wcześniej." % [_zaklad.godzina_startu, Zegar.tekst_godziny()]
		Zaklad.Stan.ZA_POZNO:
			etykieta_tresci.text = "Zmiana skończyła się o %d:00. Dziś już nie ma po co wchodzić. Kierownik zapisze nieobecność." % _zaklad.godzina_konca
		Zaklad.Stan.JUZ_BYLO:
			etykieta_tresci.text = "Swoje dziś odbębniłeś. Wracaj jutro na %d:00." % _zaklad.godzina_startu
		Zaklad.Stan.MOZNA:
			var tekst: String = "Zmiana %d:00–%d:00. Wypłata %d zł, kosztuje %d energii." % [
				_zaklad.godzina_startu, _zaklad.godzina_konca, _zaklad.wyplata, int(_zaklad.koszt_energii)]
			var spoznienie: int = _zaklad.spoznienie_minuty()
			if spoznienie > _zaklad.tolerancja_spoznienia:
				tekst += "\nJesteś spóźniony o %d min. Kierownik to zapamięta." % spoznienie
			elif spoznienie > 0:
				tekst += "\nSpóźnienie %d min, jeszcze w granicach tolerancji." % spoznienie
			tekst += "\nRelacja z kierownikiem: %s (%d)." % [Relacje.opis(_zaklad.kierownik), Relacje.relacja(_zaklad.kierownik)]
			etykieta_tresci.text = tekst
			_dodaj_przycisk("Pracuj uczciwie", func() -> void: _pracuj(false))
			_dodaj_przycisk("Pracuj i załatw coś na boku (%d%% szans)" % int(_zaklad.szansa_zalatwienia * 100), func() -> void: _pracuj(true))
	_dodaj_przycisk("Odejdź", zamknij)


func _pracuj(czy_zalatwiac: bool) -> void:
	var wynik: Dictionary = _zaklad.pracuj(czy_zalatwiac)
	_wyczysc(przyciski)
	var linie: Array[String] = ["Zmiana skończona o %s. Wypłata %d zł, energia spadła o %d." % [
		Zegar.tekst_godziny(), wynik["wyplata"], int(_zaklad.koszt_energii)]]
	if wynik["kara_relacji"] > 0:
		linie.append("Spóźnienie %d min: kierownik niezadowolony (relacja -%d)." % [wynik["spoznienie"], wynik["kara_relacji"]])
	if wynik["zalatwiono"] != null:
		linie.append("Załatwiłeś na boku: %s. Nikt nie widział." % (wynik["zalatwiono"] as Przedmiot).nazwa)
	if wynik["wpadka"]:
		linie.append("Wpadka! Kierownik przyłapał cię przy magazynie. Kara %d zł, relacja -%d." % [wynik["kara_pieniezna"], _zaklad.kara_relacji_wpadka])
	etykieta_tresci.text = "\n".join(linie)
	etykieta_wyniku.text = "Pieniądze: %d zł" % Ekwipunek.pieniadze
	_dodaj_przycisk("Do domu", zamknij)


func _dodaj_przycisk(tekst: String, akcja: Callable) -> void:
	var przycisk: Button = Button.new()
	przycisk.text = tekst
	przycisk.pressed.connect(akcja)
	przyciski.add_child(przycisk)


func _wyczysc(kontener: Container) -> void:
	for dziecko: Node in kontener.get_children():
		kontener.remove_child(dziecko)
		dziecko.queue_free()
