# MTG Artwork Picker

A Flutter desktop/mobile app for building MTG proxy card sets. Search card artwork from Scryfall and MagicVille, curate print data (oracle text, flavor text, type line, etc.), and export everything as a ZIP or folder ready for proxy rendering tools.

## Features

- **Card search** — import a deck list and auto-fetch all printings from Scryfall
- **Artwork browser** — browse and select artwork per card across all sets and languages
- **Print Data tab** — view and edit per-card print data (name, type line, oracle text, flavor text, mana cost, P/T, loyalty, colors, artist, collector number, rarity) with per-language deduplication
- **Version picker** — choose a specific set/language printing; print data auto-fills from Scryfall
- **Multi-format export** — export checked cards as a ZIP, folder, or in-memory bundle, with a `print_data.json` file in Scryfall API format alongside the artwork
- **Frame & layout mapping** — assign proxy templates (Proxyshop, MagicVille, etc.) per layout or card type at project level

## Tech stack

- Flutter + Dart
- [Drift](https://drift.simonbinder.eu/) (SQLite ORM) with schema migrations
- [Riverpod](https://riverpod.dev/) for state management
- [GoRouter](https://pub.dev/packages/go_router) for navigation
- Scryfall API + MagicVille scraper for artwork and print data

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d windows   # or macos / linux / android / ios
```

## Export format

Each export includes a `print_data.json` file structured as a Scryfall-like search response:

```json
{
  "object": "list",
  "total_cards": 2,
  "data": [
    {
      "object": "card",
      "name": "Lightning Bolt",
      "lang": "en",
      "set": "m11",
      "collector_number": "149",
      "type_line": "Instant",
      "oracle_text": "Lightning Bolt deals 3 damage to any target.",
      "colors": ["R"],
      "artist": "Christopher Moeller",
      "exported_file_name": "other/normal/Lightning Bolt (Christopher Moeller) [M11] {149}.jpg"
    }
  ]
}
```
