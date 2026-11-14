# Projekt: symulator życia w państwie socjalistycznym (prototyp)

## O projekcie
- Gra 3D z kamerą izometryczną (ortogonalną), w duchu Graveyard Keeper.
- Realia: codzienne życie w państwie socjalistycznym. Główna mechanika to gospodarka niedoboru: pieniądze są, towaru nie ma, walutą są znajomości i przysługi.
- Silnik: **Godot 4.7** (GDScript). Tylko darmowe assety na licencji CC0 lub CC-BY.
- Cel prototypu: sprawdzić, czy pętla „praca – kolejka – wymiana" bawi przez 15 minut. Etapy 0–8 są gotowe, trwa Etap 9 (testy i strojenie). Potem Etapy 10–12 (kariera, partia, związki).
- Opis tego, co już istnieje (moduły, autoloady, sygnały, przepływ gry): `ARCHITEKTURA.md`. Przeczytaj go na początku sesji, zanim coś zmienisz.

## Zasady pracy
1. Pracuj etapami z pliku `PLAN.md`. Jeden etap naraz, nigdy nie zaczynaj kolejnego bez mojej zgody.
2. Nie dodawaj niczego spoza bieżącego etapu. Pomysły na później dopisuj do `POMYSLY.md`.
3. Przed pisaniem kodu przedstaw krótki plan etapu (jakie pliki powstaną i po co) i poczekaj na akceptację.
4. Po każdym etapie:
   - uruchom projekt bez okna i sprawdź, czy nie ma błędów (sekcja „Jak sprawdzać" niżej),
   - uruchom testy z `testy/` i dopisz nowy test dla nowej mechaniki,
   - wypisz mi listę kroków do ręcznego przetestowania w edytorze,
   - odhacz etap w `PLAN.md` i zrób commit w git z opisem po polsku.
5. Uczę się programowania. Wyjaśniaj krok po kroku, co robi nowy kod i dlaczego, prostym językiem.
6. Podawaj kompletne pliki, nie fragmenty z „reszta bez zmian".
7. Błędy znalezione w trakcie etapu naprawiaj od razu i opisz je w podsumowaniu: co było nie tak i czego to uczy.

## Standardy kodu
- GDScript ze statycznym typowaniem (`var x: int`, `func f() -> void`).
- Nazwy zmiennych, funkcji i plików po polsku bez znaków diakrytycznych (`predkosc`, `kolejka.gd`). Teksty dla gracza z polskimi znakami.
- Komentarze po polsku, wyjaśniające „dlaczego", a nie „co". Każdy skrypt zaczyna się od komentarza `##`, co robi i czego nie robi.
- Dane gry (przedmioty, postacie, dostawy, stanowiska) w zasobach `.tres`, nie na sztywno w kodzie.
- Jedna scena = jedna odpowiedzialność. Komunikacja między węzłami przez sygnały. Połączenia sygnałów między scenami w pliku `gra/swiat.tscn` (sekcja `[connection]`), nie przez `get_node` w kodzie.
- Czysta logika mechaniki (zasady, wzory, progi) w osobnym pliku `RefCounted` z funkcjami `static` (wzór: `sklep/kolejka.gd`, `postacie/rozmowa.gd`). Węzły tylko ją wołają.
- Wartości do strojenia (prędkość, długość dnia, ceny, progi) jako `@export` z zakresem albo stałe na górze pliku.
- Autoload = stan gry, który ma przeżyć zmianę sceny. Każdy autoload ma `resetuj()` używane przez „zagraj ponownie".
- Okna interfejsu dziedziczą po `ui/wspolne/okno.gd` (klasa `Okno`): pauza, Esc, jedno okno naraz. Listy przedmiotów budują wiersze z `ui/wspolne/wiersz_przedmiotu.tscn`.

## Pułapki, na które już wpadliśmy (nie powtarzać)
- Węzły z listy usuwaj przez `remove_child()` + `queue_free()`, nigdy `free()`: kliknięty przycisk nie może zniknąć w trakcie wysyłania własnego sygnału `pressed` (silnik się wywala).
- Najpierw `show()`, potem odświeżanie treści okna, jeśli odświeżanie sprawdza `visible`.
- W tekstach GDScript polski cudzysłów zamykający to `”` (U+201D), nie `"`. Zwykły `"` kończy string i daje błąd składni.
- `godot -s skrypt.gd` NIE ładuje autoloadów. Testy uruchamiamy jako normalną grę ze sceną testową: `godot --headless --path . res://testy/nazwa.tscn`.
- Wiersz z `wiersz_przedmiotu.tscn` wypełniaj po `add_child` (w `ready`), bo jego `@onready` nie są gotowe wcześniej.
- Przewijanie czasu (`Zegar.przewin_*`) wysyła sygnał `godzina_minela` za każdą pominiętą godzinę. Mechaniki czasowe mają słuchać tego sygnału, nie `minuta_minela`, żeby sen i kolejka też „kosztowały".

## Struktura folderów
Folder = moduł (jedna mechanika gry). Scena, skrypt i dane tej mechaniki leżą razem,
żeby zmiana jednej mechaniki dotykała jednego folderu. Moduły rozmawiają sygnałami,
nie sięgają sobie do środka.
```
res://
  gra/            # szkielet: swiat.tscn (scena główna), gracz, kamera
  czas/           # autoload Zegar
  interakcja/     # komponent Interakcja i wykrywacz na graczu
  potrzeby/       # autoload Potrzeby (głód, energia)
  ekwipunek/      # autoload Ekwipunek, Przedmiot, Schowek; przedmioty/*.tres
  mieszkanie/     # łóżko, lodówka
  sklep/          # sklep, dostawy/*.tres, logika kolejki
  praca/          # zakład pracy
  postacie/       # Postac, PostacNPC, autoload Relacje, logika rozmowy; postacie/*.tres
  zadanie/        # autoload Zadanie (cel gry)
  statystyki/     # autoload Statystyki
  ui/             # interfejs: wspolne/, hud/, plecak/, sklep/, praca/, rozmowa/, koniec/
  testy/          # testy bez okna (sceny + uruchom.sh), zrzuty ekranu
  assets/         # modele GLB, tekstury (pobieram je sam)
```
Nowe etapy dostają własne moduły: `kariera/`, `partia/`, `zwiazki/`.
Jedna mechanika = jeden plik: skrypt, który robi dwie rzeczy, dzielimy.

## Jak sprawdzać (praca lokalna)
- Godot 4.7 musi być w `PATH` jako `godot` albo wskazany zmienną `GODOT=/sciezka/do/godota`.
- Import i edytor bez okna: `godot --headless --path . --import`, potem `godot --headless --path . --editor --quit`. Oba muszą zakończyć się kodem 0 bez `ERROR` w wyjściu.
- Scena główna bez okna: `godot --headless --path . --quit-after 60`.
- Testy: `testy/uruchom.sh test_regresja` (i pozostałe, lista w `testy/README.md`). Testy wypisują wartości i oczekiwania w nawiasach; czytaj je oczami.
- Symulacja trudności: `testy/uruchom.sh test_symulacja` (bot gra 300 tygodni). Po każdym strojeniu liczb uruchom ją i podaj mi odsetek wygranych.
- Zrzuty ekranu bez edytora: `godot --path . res://testy/zrzuty.tscn` zapisuje PNG do `user://zrzuty/` (na Linuksie `~/.local/share/godot/app_userdata/Socjalism Life/zrzuty/`). W edytorze wystarczy F5.

## Assety
- Nie pobieraj assetów z internetu. Modele wrzucam sam do `assets/`.
- Dopóki modelu nie ma, używaj klocków zastępczych (CSGBox3D, CapsuleMesh) w wyraźnych kolorach. Kolor postaci bierz z zasobu `Postac`.
- Każdą paczkę dopisuj do `LICENCJE.md`: nazwa, autor, adres, licencja.
- Planowana baza: Kenney Furniture Kit, City Kit (Industrial, Commercial), Retro Urban Kit, Panelka Pack (wszystkie CC0).
- Skala: postać ma 1,8 m, wszystko inne skalujemy do niej.

## Ustalenia techniczne
- Kamera: Camera3D, projekcja ortogonalna, obrót (-30, 45, 0), śledzi gracza, nie jest jego dzieckiem.
- Ruch gracza: CharacterBody3D, kierunek wejścia obrócony o 45° wokół osi Y, żeby „w górę" znaczyło „w górę ekranu".
- Stan gry (czas, pieniądze, ekwipunek, relacje, zadanie, statystyki) w autoloadach, żeby przetrwał zmianę sceny.
- Akcje wejścia: `ruch_gora/dol/lewo/prawo` (WASD i strzałki), `interakcja` (E), `plecak` (I), `ui_cancel` (Esc).
- Warstwy fizyki: 1 `swiat` (podłoga, budynki, gracz), 2 `interakcje` (obszary Area3D obiektów interakcji).

## Git
- Gałąź robocza: `main` (po przejściu na pracę lokalną). Jeden commit na etap, opis po polsku, pierwsza linia „Etap N: ...".
- Nie commituj folderu `.godot/` ani plików tymczasowych (jest w `.gitignore`). Pliki `*.uid` commitujemy, bo Godot nimi identyfikuje skrypty.

## Poza zakresem (na razie)
Zapis gry, kolejne dzielnice, rozbudowany crafting, milicja, pory roku, dźwięk i muzyka, menu główne, tłumaczenia.
