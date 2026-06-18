# Aplikacja mobilna do zarządzania budżetem domowym i osobistym

Niniejsze repozytorium zawiera kod źródłowy aplikacji mobilnej służącej do zarządzania budżetem osobistym i domowym[cite: 1]. Głównym celem zrealizowanego systemu jest udostępnienie narzędzia umożliwiającego agregację danych finansowych z różnych źródeł w jednym miejscu oraz ich dokładne monitorowanie[cite: 1]. Projekt stanowi w pełni funkcjonalne, samodzielne narzędzie wspierające świadomość finansową użytkownika, przygotowane w ramach pracy inżynierskiej[cite: 1].

## Główne funkcjonalności

* **Skanowanie paragonów (OCR):** System realizuje automatyczną ekstrakcję danych z dostarczonego obrazu paragonu[cite: 1]. Autorski moduł wykorzystuje bibliotekę Google ML Kit Text Recognition, co pozwala na błyskawiczną digitalizację wydatków bez konieczności ręcznego ich wprowadzania[cite: 1].
* **Zaawansowana kategoryzacja:** Aplikacja pozwala na precyzyjną kategoryzację i rozdzielanie konkretnych produktów z dokumentów zakupu, na których znajduje się wiele artykułów[cite: 1]. Każdej wyodrębnionej pozycji można przypisać odrębną kategorię budżetową[cite: 1].
* **Zarządzanie transakcjami:** System umożliwia ręczne wprowadzanie nowych transakcji (przychodów, wydatków, a także transakcji cyklicznych) oraz edycję i usuwanie wpisów z bazy danych[cite: 1].
* **Budżety i powiadomienia:** Użytkownik ma możliwość ustalenia limitów kwotowych dla wybranych kategorii w zadanym cyklu rozliczeniowym[cite: 1]. W momencie przekroczenia ustalonego progu ostrzegawczego, system generuje powiadomienie typu Push[cite: 1].
* **Cele oszczędnościowe:** System umożliwia definiowanie własnych celów finansowych (kwota docelowa oraz data realizacji) i automatycznie monitoruje postęp w ich osiąganiu[cite: 1].
* **Analiza i eksport danych:** Aplikacja generuje interaktywne wykresy (kołowe oraz słupkowe) analizujące strukturę finansów[cite: 1]. Użytkownik może również wygenerować raport w formacie .csv lub .xlsx zawierający zestawienie transakcji[cite: 1].

## Architektura i technologie

Aplikacja opiera się na architekturze warstwowej (Warstwa Danych, Warstwa Stanu i Logiki, Warstwa Prezentacji), oddzielając interfejs od logiki biznesowej[cite: 1]. 

* **Framework i środowisko:** Aplikacja została zrealizowana w technologii Flutter, wykorzystującej natywnie kompilowany język Dart[cite: 1].
* **Model przechowywania danych:** System działa w modelu Offline-first[cite: 1]. Wszystkie wrażliwe dane finansowe są przechowywane wyłącznie w pamięci lokalnej urządzenia, co gwarantuje pełną prywatność użytkownika[cite: 1].
* **Baza danych:** Wykorzystano relacyjną bazę danych opartą na silniku SQLite, wspieraną przez bibliotekę Drift[cite: 1]. Baza została znormalizowana do Trzeciej Postaci Normalnej (3NF) w celu zapewnienia integralności danych[cite: 1].
* **Wzorce projektowe:** Warstwa danych komunikuje się z logiką za pomocą strukturalnego wzorca DAO (Data Access Object)[cite: 1]. Do zarządzania stanem aplikacji wykorzystano wzorzec Provider, rekomendowany w ekosystemie Flutter[cite: 1].
* **Interfejs użytkownika:** Warstwa prezentacyjna opiera się na wytycznych Material Design 3 i zawiera automatyczne dostosowywanie się do systemowego trybu kolorów (jasny/ciemny)[cite: 1].

## Uruchomienie lokalne

1. Upewnij się, że w Twoim środowisku poprawnie zainstalowano i skonfigurowano Flutter SDK.
2. Sklonuj repozytorium:
```bash
   git clone [https://github.com/PioStaworko/Inzynierka.git](https://github.com/PioStaworko/Inzynierka.git)
```
3. Przejdź do głównego katalogu projektu
4. Pobierz wymagane zależności biblioteczne:
```bash
   flutter pub get
```
5. Uruchom projekt:
```bash
   flutter run
```
