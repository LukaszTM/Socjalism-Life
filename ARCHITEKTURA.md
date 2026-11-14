# Architektura prototypu (stan po Etapie 8)

Ten plik opisuje, co istnieje i jak to ze sobą rozmawia. Czytaj go na początku sesji.
Gdy zmieniasz architekturę (nowy autoload, nowy sygnał między modułami, nowe okno), zaktualizuj go.

## Przepływ gry w skrócie
1. Scena główna `gra/swiat.tscn` zawiera podłogę, budynki-klocki, gracza, kamerę, miejsca (łóżko, lodówka, sklep, zakład), postacie i wszystkie okna interfejsu.
2. Gracz chodzi (WASD), a `Wykrywacz` na nim wybiera najbliższy obiekt z komponentem `Interakcja` i pokazuje podpowiedź „E: ...".
3. Klawisz E woła `Interakcja.uzyj()`, która wysyła sygnał `uzyto`. Właściciel obiektu reaguje: łóżko przewija czas, lodówka/sklep/zakład/postać wysyłają sygnał `otworzono`/`rozmowa_rozpoczeta`, a scena świata łączy go z właściwym oknem.
4. Okno (dziedziczy po `Okno`) pauzuje grę, pokazuje treść i woła logikę modułu. Po zamknięciu gra rusza.
5. `Zadanie` sprawdza plecak i pieniądze; gdy gracz ma pralkę, wysyła `ukonczone`, a o północy po 7. dniu `przegrane`. `EkranKonca` to pokazuje i resetuje autoloady przy „zagraj ponownie".

## Autoloady (kolejność z `project.godot`)
| Nazwa | Plik | Trzyma | Sygnały |
|---|---|---|---|
| `Zegar` | `czas/zegar.gd` | numer dnia, minuty dnia, długość dnia (5 min) | `minuta_minela(g, m)`, `godzina_minela(g)`, `dzien_minal(dzien)` |
| `Potrzeby` | `potrzeby/potrzeby.gd` | głód, energia 0–100, spadają co godzinę | `glod_zmieniony(w)`, `energia_zmieniona(w)` |
| `Ekwipunek` | `ekwipunek/ekwipunek.gd` | pieniądze, `plecak: Schowek` | `pieniadze_zmienione(ile)`, `przedmioty_zmienione` |
| `Relacje` | `postacie/relacje.gd` | relacja 0–100 na postać | `relacja_zmieniona(postac, w)` |
| `Statystyki` | `statystyki/statystyki.gd` | liczniki tygodnia | brak |
| `Zadanie` | `zadanie/zadanie.gd` | cel, kroki, limit dni | `postep_zmieniony`, `ukonczone`, `przegrane` |

Każdy ma `resetuj()`. Moduły wołają autoloady bezpośrednio (np. `Zegar.przewin_minuty(45)`), ale nigdy odwrotnie: autoload nie zna sceny.

## Klasy pomocnicze (bez węzłów)
- `Przedmiot` (Resource): id, nazwa, opis, ikona, cena_urzedowa, wymaga_kartek, jadalny, ile_syci. Pliki w `ekwipunek/przedmioty/`.
- `Schowek` (RefCounted): słownik przedmiot → ilość, `dodaj`, `zabierz` (zwraca false, gdy brak), `ile`, `lista`, `wyczysc`, sygnał `zmieniony`. Używany przez plecak, lodówkę i ladę.
- `Postac` (Resource): imie, rola, opis, kolor, czego_potrzebuje, co_oferuje, relacja_startowa, prog_wymiany, powitanie. Pliki w `postacie/postacie/`.
- `Dostawa` i `PozycjaDostawy` (Resource): zestaw towaru z wagą losowania. Pliki w `sklep/dostawy/`.
- `Kolejka` (RefCounted, static): szacowany czas stania i wykupywanie towaru przez ludzi przed graczem.
- `Rozmowa` (RefCounted, static): pogawędka, prezent, wymiana; progi i limity dzienne.

## Moduły i ich sygnały
- `interakcja/`: `Interakcja` (Area3D, warstwa 2) z `nazwa_akcji` i sygnałem `uzyto`; `WykrywaczInterakcji` na graczu z sygnałem `cel_zmieniony(Interakcja)`.
- `mieszkanie/`: `Lozko` (sen do 7:00, odnawia energię), `Lodowka` (własny `Schowek`, sygnał `otworzono(schowek, nazwa)`).
- `sklep/`: `Sklep` (lada: Schowek, dostawa o 8:00, godziny 7–18, `kup()`, `kup_pralke()`, `czy_pod_lada()`), sygnały `otworzono(sklep)`, `zakupiono`, `kolejka_odstana`, `odeszli_z_niczym`.
- `praca/`: `Zaklad` (stany WOLNE/ZA_WCZESNIE/MOZNA/ZA_POZNO/JUZ_BYLO, `pracuj(czy_zalatwiac)` zwraca słownik wyniku), sygnały `otworzono`, `zmiana_odbyta`, `wpadka`, `zalatwiono`, `nieobecnosc`.
- `postacie/`: `PostacNPC` (klocek + Interakcja „Pogadaj", pamięta dzień ostatniej rozmowy i wymiany), sygnały `rozmowa_rozpoczeta(npc)`, `wymieniono`.
- `ui/`: `Okno` (baza), `WierszPrzedmiotu`, HUD (`hud_czas`, `hud_zadanie`, `hud_potrzeby`, `hud_podpowiedz`), okna: plecak, sklep, praca, rozmowa, ekran końca.

## Połączenia sygnałów w `gra/swiat.tscn`
```
Gracz/Wykrywacz.cel_zmieniony      -> HUD/EtykietaPodpowiedzi.pokaz_podpowiedz
Lodowka.otworzono                  -> Plecak.otworz_ze_schowkiem
Sklep.otworzono                    -> OknoSklepu.otworz_sklep
Zaklad.otworzono                   -> OknoPracy.otworz_zaklad
Sklep/Sprzedawczyni.rozmowa_rozpoczeta -> OknoRozmowy.otworz_rozmowe
Zaklad/Kierownik.rozmowa_rozpoczeta    -> OknoRozmowy.otworz_rozmowe
Sasiad.rozmowa_rozpoczeta          -> OknoRozmowy.otworz_rozmowe
Kombinator.rozmowa_rozpoczeta      -> OknoRozmowy.otworz_rozmowe
```
Nowe miejsce lub postać = nowa instancja w świecie + jedna linia `[connection]`.

## Liczby po pierwszym strojeniu (symulacja bota: ok. 35% wygranych)
- Dzień gry = 300 s. Start poniedziałek 7:00. Limit 7 dni.
- Głód −6/h, energia −5/h, sen +12,5/h. Chleb syci 30, kiełbasa 55.
- Sklep: dostawa 8:00, otwarty 7–18. Kolejka 15 min + 0,5 min za każdą minutę od dostawy, max 180; co 30 min kolejki ktoś kupuje 1 sztukę.
- Praca: pon–pt 8–16, wypłata 450 zł, −30 energii, spóźnienie >30 min −5 relacji, nieobecność −15, załatwianie 50% (papier/papierosy) albo kara 300 zł i −20 relacji.
- Relacje: rozmowa +5/dzień, prezent trafiony +15, zwykły +4. Progi wymiany: sąsiad 40, kombinator 45, kierownik 50, spod lady 50.
- Ceny: chleb 20, kiełbasa 180 (+kartki), kawa 400, papierosy 60, wódka 700, papier 30, pralka 2500 na talon. Start: 1500 zł, chleb, 3 kartki.

## Łańcuch do celu
papierosy (sklep lub praca) → prezent/wymiana u sąsiada → kawa → prezenty i wymiany u kombinatora (część) i kierownika (talon) → 2500 zł z wypłat → odbiór pralki w sklepie (dział AGD, bez kolejki).

## Testy (`testy/`)
Sceny testowe ładują `gra/swiat.tscn`, symulują klawisze przez `InputEventAction` i klikają przyciski przez `pressed.emit()`. Test musi mieć `process_mode = PROCESS_MODE_ALWAYS`, bo okna pauzują drzewo. Opis uruchamiania w `testy/README.md`.
