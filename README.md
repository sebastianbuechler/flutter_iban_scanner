# Flutter IBAN Scanner

A package for scanning international bank account numbers.

## Inspired by

This package is heavily inspired by the package [google_ml_kit](https://pub.dev/packages/google_ml_kit) and their great examples.

## Usage

Add this plugin as dependency in your pubspec.yaml.

Call the `IBANScannerView` and proviced an `onScannerResult` callback for handling the result.
```dart
IBANScannerView(
onScannerResult: (iban) => {
    // do stuff here
    }),
```

## Demo
![Demo](https://github.com/sebastianbuechler/flutter_iban_scanner/blob/master/exampleexample.gif)