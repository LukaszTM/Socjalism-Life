# Testy bez okna

Każdy test to scena z jednym węzłem, która ładuje `gra/swiat.tscn`, symuluje klawisze
(`InputEventAction`) i wypisuje wyniki do konsoli. Uruchamiamy je normalnym startem gry,
żeby działały autoloady.

```
testy/uruchom.sh test_regresja     # zegar, potrzeby, łóżko, lodówka, plecak
testy/uruchom.sh test_etap5        # sklep: dostawa, kolejka, kartki, pieniądze
testy/uruchom.sh test_etap6        # praca: zmiana, spóźnienie, załatwianie, weekend
testy/uruchom.sh test_nieobecnosc  # kara za nieobecność w pracy
testy/uruchom.sh test_etap7        # rozmowa, prezent, wymiana, towar spod lady
testy/uruchom.sh test_etap8        # łańcuch do pralki, sukces, restart, porażka
testy/uruchom.sh test_symulacja    # bot gra 300 tygodni, mierzy odsetek wygranych
```

Jeśli `godot` nie jest w PATH: `GODOT=/sciezka/do/godota testy/uruchom.sh test_regresja`.
Test czytamy oczami: nie ma asercji, tylko wypisane wartości i oczekiwania w nawiasach.

## Zrzuty ekranu bez edytora

`godot --path . res://testy/zrzuty.tscn` uruchamia grę z oknem, przechodzi przez kilka
miejsc i okien, zapisuje PNG do `user://zrzuty/` i kończy. Na Linuksie bez monitora:
`xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --rendering-method gl_compatibility --rendering-driver opengl3 res://testy/zrzuty.tscn`.
