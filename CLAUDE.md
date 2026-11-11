# Projekt: symulator życia w państwie socjalistycznym (prototyp)

## O projekcie
- Gra 3D z kamerą izometryczną (ortogonalną), w duchu Graveyard Keeper.
- Realia: codzienne życie w państwie socjalistycznym. Główna mechanika to gospodarka niedoboru: pieniądze są, towaru nie ma, walutą są znajomości i przysługi.
- Silnik: Godot 4 (GDScript). Tylko darmowe assety na licencji CC0 lub CC-BY.
- Cel prototypu: sprawdzić, czy pętla „praca – kolejka – wymiana" bawi przez 15 minut.

## Zasady pracy
1. Pracuj etapami z pliku `PLAN.md`. Jeden etap naraz, nigdy nie zaczynaj kolejnego bez mojej zgody.
2. Nie dodawaj niczego spoza bieżącego etapu. Pomysły na później dopisuj do `POMYSLY.md`.
3. Przed pisaniem kodu przedstaw krótki plan etapu (jakie pliki powstaną i po co) i poczekaj na akceptację.
4. Po każdym etapie:
   - uruchom projekt w trybie bez okna i sprawdź, czy nie ma błędów (np. `godot --headless --import`, potem `godot --headless --quit`; sprawdź dokładne flagi dla zainstalowanej wersji),
   - wypisz mi listę kroków do ręcznego przetestowania w edytorze,
   - zrób commit w git z opisem po polsku.
5. Uczę się programowania. Wyjaśniaj krok po kroku, co robi nowy kod i dlaczego, prostym językiem.
6. Podawaj kompletne pliki, nie fragmenty z „reszta bez zmian".

## Standardy kodu
- GDScript ze statycznym typowaniem (`var x: int`, `func f() -> void`).
- Nazwy zmiennych, funkcji i plików po polsku bez znaków diakrytycznych (`predkosc`, `kolejka.gd`).
- Komentarze po polsku, wyjaśniające „dlaczego", a nie „co".
- Dane gry (przedmioty, postacie, dostawy) trzymaj w zasobach `.tres`, nie na sztywno w kodzie.
- Jedna scena = jedna odpowiedzialność. Komunikacja między węzłami przez sygnały.
- Wartości do strojenia (prędkość, długość dnia, ceny) jako `@export` albo stałe na górze pliku.

## Struktura folderów
```
res://
  sceny/        # pliki .tscn (swiat, gracz, ui, miejsca)
  skrypty/      # pliki .gd
  dane/         # zasoby .tres (przedmioty, postacie)
  assets/       # modele GLB, tekstury (pobieram je sam)
  ui/           # sceny i motywy interfejsu
```

## Assety
- Nie pobieraj assetów z internetu. Modele wrzucam sam do `assets/`.
- Dopóki modelu nie ma, używaj klocków zastępczych (CSGBox3D, CapsuleMesh) w wyraźnych kolorach.
- Każdą paczkę dopisuj do `LICENCJE.md`: nazwa, autor, adres, licencja.
- Planowana baza: Kenney Furniture Kit, City Kit (Industrial, Commercial), Retro Urban Kit, Panelka Pack (wszystkie CC0).
- Skala: postać ma 1,8 m, wszystko inne skalujemy do niej.

## Ustalenia techniczne
- Kamera: Camera3D, projekcja ortogonalna, obrót (-30, 45, 0), śledzi gracza, nie jest jego dzieckiem.
- Ruch gracza: CharacterBody3D, kierunek wejścia obrócony o 45° wokół osi Y, żeby „w górę" znaczyło „w górę ekranu".
- Stan gry (czas, pieniądze, ekwipunek, relacje) w autoloadach, żeby przetrwał zmianę sceny.

## Poza zakresem prototypu
Zapis gry, kolejne dzielnice, rozbudowany crafting, milicja, pory roku, dźwięk i muzyka, menu główne, tłumaczenia.
