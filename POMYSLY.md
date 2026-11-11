# Pomysły na później

Tu trafiają pomysły spoza bieżącego etapu. Nie wdrażamy ich bez decyzji.

## Lista

- Testy w `testy/` mają tylko wypisy; dodać asercje i zbiorczy wynik OK/BŁĄD, żeby dało się je puszczać automatycznie.
- Bot z `test_symulacja.gd` gra prostą strategią; można go rozbudować (np. kolejka rano w weekend, oszczędzanie na wódkę), żeby lepiej mierzyć trudność po każdym strojeniu.

## Po prototypie: kariera, partia, związki (zgłoszone 2026-11-11)
- **Tryb kariery.** Dłuższa rozgrywka niż tydzień: awanse w zakładzie (robotnik → brygadzista → kierownik),
  wyższa wypłata i dostęp do talonów. Wymaga: licznika stażu, drzewka stanowisk w `.tres`, nowego celu gry.
- **Partia.** Wstąpienie do partii jako osobna ścieżka: zebrania zabierają czas, dają znajomości i przywileje
  (sklep za żółtymi firankami, talony), ale psują relacje z niektórymi postaciami (sąsiad, kombinator).
  Kariera polityczna: szczeble (kandydat → członek → sekretarz) z własnymi zadaniami i ryzykiem.
- **Romans i związek.** Nowa postać lub rozbudowa istniejących: randki jako interakcje zabierające czas i prezenty,
  relacja „uczucie" osobna od zwykłej relacji, zamieszkanie razem (wspólna lodówka i pieniądze, drugi głód do karmienia).
  Wymaga: pola `romans_mozliwy` w zasobie Postac, nowych opcji w oknie rozmowy, wydarzeń (ślub) i wpływu na cel kariery.
- Kolejność sugerowana: najpierw tryb kariery (podstawa dla reszty), potem partia, na końcu związki.
