library flutter_iban_scanner;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:iban/iban.dart';

import 'view/camera_view.dart';

class IBANScannerView extends StatefulWidget {
  final ValueChanged<String> onScannerResult;
  List<CameraDescription> cameras;

  IBANScannerView({
    required this.onScannerResult,
    this.cameras = const <CameraDescription>[],
  });

  @override
  _IBANScannerViewState createState() => _IBANScannerViewState();
}

class _IBANScannerViewState extends State<IBANScannerView> {
  TextDetector textDetector = GoogleMlKit.vision.textDetector();
  bool isBusy = false;
  bool ibanFound = false;
  String iban = "";
  CustomPaint? customPaint;

  @override
  void initState() {
    super.initState();
    if (widget.cameras.length == 0) {
      _initCameras();
    }
  }

  void _initCameras() async {
    widget.cameras = await availableCameras();
  }

  @override
  void dispose() async {
    super.dispose();
    await textDetector.close();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'IBAN Scanner',
      customPaint: customPaint,
      cameras: widget.cameras,
      onImage: (inputImage) {
        processImage(inputImage, context);
      },
    );
  }

  RegExp regExp = RegExp(
    r"^(.*)(([A-Z]{2}[ \-]?[0-9]{2})(?=(?:[ \-]?[A-Z0-9]){9,30}$)((?:[ \-]?[A-Z0-9]{3,5}){2,7})([ \-]?[A-Z0-9]{1,3})?)$",
    caseSensitive: false,
    multiLine: false,
  );

  Future<void> processImage(InputImage inputImage, BuildContext context) async {
    if (isBusy) return;
    isBusy = true;

    final recognisedText = await textDetector.processImage(inputImage);

    for (final textBlock in recognisedText.blocks) {
      if (!regExp.hasMatch(textBlock.text)) {
        continue;
      }

      var possibleIBAN = regExp.firstMatch(textBlock.text)!.group(2).toString();
      if (!isValid(possibleIBAN)) {
        continue;
      }

      iban = toPrintFormat(possibleIBAN);
      ibanFound = true;
      break;
    }

    if (ibanFound) {
      Navigator.of(context).pop(context);
      widget.onScannerResult(iban);
    }

    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
