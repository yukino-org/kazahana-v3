# Scripts

### Running the app (development)

```bash
flutter run
```

### Building the app

```bash
flutter build
```

## Hive generate

```bash
flutter packages pub run build_runner build
```

## Testing extractors

```bash
flutter test -r expanded ./test/extractors/anime/<extractor_name>/<search|info|sources>.dart
flutter test -r expanded ./test/extractors/manga/<extractor_name>/<search|info|chapter>.dart
```