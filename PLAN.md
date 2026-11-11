# Plan prac: prototyp

Cel całości: grywalny tydzień (7 dni gry), w którym gracz ma zdobyć pralkę „Franię".
Każdy etap kończy się działającą grą. Odhaczaj `[x]` po mojej akceptacji.

Zakres prototypu:
- Miejsca: mieszkanie, sklep spożywczy, zakład pracy, jedna ulica.
- Postacie: sprzedawczyni, kierownik, sąsiad, kolega-kombinator.
- Przedmioty: chleb, kiełbasa, kawa, papierosy, wódka, papier toaletowy, kartki żywnościowe, część do pralki.
- Potrzeby: głód, energia.

---

## Etap 0: Szkielet projektu
- [x] Projekt Godot 4 ze strukturą folderów z `CLAUDE.md`.
- [x] Repozytorium git z plikiem `.gitignore` dla Godota.
- [x] Puste pliki `LICENCJE.md` i `POMYSLY.md`.

**Gotowe, gdy:** projekt otwiera się w edytorze bez błędów i jest pierwszy commit.

## Etap 1: Świat i ruch
- [x] Scena `swiat.tscn`: podłoga z kolizją, światło kierunkowe z cieniami.
- [x] Scena `gracz.tscn` (CharacterBody3D) ze sterowaniem strzałkami i WASD.
- [x] Kamera izometryczna śledząca gracza.
- [x] Kilka klocków jako „budynki" z kolizją.

**Gotowe, gdy:** chodzę postacią we wszystkie strony, „w górę" prowadzi w górę ekranu, nie przechodzę przez klocki, kamera płynnie podąża.

## Etap 2: Zegar i dzień
- [x] Autoload `Zegar`: godzina, dzień tygodnia, numer dnia, sygnały `godzina_minela` i `dzien_minal`.
- [x] Długość dnia jako ustawienie (na start: 1 dzień gry = 5 minut).
- [x] Wyświetlanie dnia i godziny na ekranie.
- [x] Łóżko jako obiekt interakcji: sen przewija czas do rana.
- [x] Wspólny system interakcji (klawisz E przy obiekcie, podpowiedź na ekranie). Będzie używany we wszystkich kolejnych etapach.

**Gotowe, gdy:** czas płynie, widzę go na ekranie, po podejściu do łóżka i wciśnięciu E budzę się następnego dnia.

## Etap 3: Potrzeby
- [x] Autoload `Potrzeby`: głód i energia (0–100), spadają z upływem czasu.
- [x] Dwa paski na ekranie.
- [x] Sen uzupełnia energię.
- [x] Skutek zaniedbania: przy zerowej energii lub głodzie postać chodzi wolniej.

**Gotowe, gdy:** paski spadają w czasie gry, sen przywraca energię, wyczerpana postać wyraźnie zwalnia.

## Etap 4: Przedmioty i ekwipunek
- [x] Zasób `Przedmiot` (nazwa, opis, ikona, cena urzędowa, czy jadalny, ile syci).
- [x] 8 przedmiotów z zakresu jako pliki `.tres`.
- [x] Autoload `Ekwipunek` z pieniędzmi i listą przedmiotów.
- [x] Okno plecaka (klawisz I): lista przedmiotów, ilości, przycisk „zjedz" dla jadalnych.
- [x] Lodówka w mieszkaniu jako schowek.

**Gotowe, gdy:** otwieram plecak, zjadam chleb i pasek głodu rośnie, przekładam rzeczy między plecakiem a lodówką.

## Etap 5: Sklep, dostawy i kolejka
- [x] Miejsce „sklep" na mapie ze sprzedawczynią.
- [x] Dostawy: każdego dnia losowy, mały zestaw towarów. Część dni bez dostawy.
- [x] Kolejka: stanie zabiera czas gry (im później po dostawie, tym dłuższa). Gracz widzi szacowany czas i decyduje, czy stać.
- [x] Towar może się skończyć, zanim dojdę do lady.
- [x] Kartki żywnościowe wymagane do zakupu kiełbasy.

**Gotowe, gdy:** jednego dnia kupuję chleb po kolejce, innego odchodzę z niczym, bo zabrakło towaru. To pierwszy moment na ocenę, czy niedobór daje frajdę.

## Etap 6: Praca
- [x] Miejsce „zakład pracy" z kierownikiem.
- [x] Zmiana trwa określone godziny, zabiera czas i energię, daje wypłatę.
- [x] Spóźnienie lub nieobecność obniża relację z kierownikiem.
- [x] Opcja „załatw coś": szansa na zdobycie przedmiotu, ryzyko wpadki (kara pieniężna, spadek relacji).

**Gotowe, gdy:** po zmianie mam więcej pieniędzy i mniej energii, a „załatwianie" czasem się udaje, a czasem kończy wpadką.

## Etap 7: Postacie, relacje i wymiana
- [ ] Zasób `Postac` (imię, czego potrzebuje, co oferuje, relacja 0–100).
- [ ] 4 postacie z zakresu rozmieszczone na mapie.
- [ ] Okno rozmowy z opcjami: pogadaj, daj prezent, zaproponuj wymianę.
- [ ] Wymiana towar za towar zależna od relacji.
- [ ] Przywileje ze znajomości: sprzedawczyni z wysoką relacją odkłada towar pod ladę (zakup bez kolejki).

**Gotowe, gdy:** wymieniam papierosy na kawę u sąsiada, a po podniesieniu relacji ze sprzedawczynią kupuję bez stania w kolejce.

## Etap 8: Cel i podsumowanie
- [ ] Zadanie główne: zdobyć pralkę „Franię" w 7 dni. Wymaga łańcucha: część do pralki od kombinatora + przysługa kierownika + pieniądze.
- [ ] Podgląd zadania na ekranie.
- [ ] Ekran końca tygodnia: sukces lub porażka, statystyki (godziny w kolejkach, wymiany, wpadki).
- [ ] Przycisk „zagraj ponownie".

**Gotowe, gdy:** da się przejść cały tydzień od początku do ekranu końcowego, zarówno wygrywając, jak i przegrywając.

## Etap 9: Test i strojenie
- [ ] Podmiana klocków na modele z `assets/` tam, gdzie już je mam.
- [ ] Strojenie liczb: długość dnia, tempo potrzeb, częstość dostaw, ceny.
- [ ] Lista błędów z moich testów i ich naprawa.
- [ ] Notatka `WNIOSKI.md`: co bawi, co nudzi, co dalej.

**Gotowe, gdy:** mam 15 minut gry bez błędów blokujących i spisane wnioski, czy rozwijać projekt.
