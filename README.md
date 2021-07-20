# Flutter IBAN Scanner

[![pub package](https://img.shields.io/pub/v/flutter_iban_scanner.svg)](https://pub.dev/packages/flutter_iban_scanner)
[![CodeFactor](https://www.codefactor.io/repository/github/sebastianbuechler/flutter_iban_scanner/badge)](https://www.codefactor.io/repository/github/sebastianbuechler/flutter_iban_scanner)

A package for scanning IBANs  (international bank account numbers) with the help of the smartphone camera and Google's ml kit.

## Inspired by

This package is heavily inspired by the package [google_ml_kit](https://pub.dev/packages/google_ml_kit) and their great examples.

## Usage

Add this package as dependency in your pubspec.yaml.

```dart
dependencies:
    flutter_iban_scanner:
```

Import the package.

```dart
import 'package:flutter_iban_scanner/flutter_iban_scanner.dart';
```

Call the `IBANScannerView` widget and provide an `onScannerResult` callback for handling the result of the scanner.

```dart
IBANScannerView(
    onScannerResult: (iban) => {
    // do stuff here with the scanned iban
    },
),
```

Check out the example app for a possible usecase.

## Demo

![Demo](https://github.com/sebastianbuechler/flutter_iban_scanner/blob/master/example/example.gif)

## Contributing

Any pull requests and extension ideas are welcome.

## Author

The Flutter IBAN Scanner package is written by [Sebastian Büchler](https://github.com/sebastianbuechler)

## Roadmap

* Modular Overlay: <https://stackoverflow.com/questions/56276522/square-camera-overlay-using-flutter>
