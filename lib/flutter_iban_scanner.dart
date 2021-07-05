library flutter_iban_scanner;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:iban/iban.dart';

import 'view/camera_view.dart';

// List<CameraDescription> cameras = [];

class IBANScannerView extends StatefulWidget {
  final ValueChanged<String> onScannerResult;
  List<CameraDescription> cameras;

  IBANScannerView({
    required Key key,
    required this.onScannerResult,
    this.cameras = const <CameraDescription>[],
  }) : super(key: key);
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
        print(textBlock.text);
        continue;
      }

      // var possibleIBAN = regExp.stringMatch(textBlock.text).toString();
      var possibleIBAN = regExp.firstMatch(textBlock.text)!.group(2).toString();
      print(possibleIBAN);
      if (!isValid(possibleIBAN)) {
        continue;
      }

      iban = toPrintFormat(possibleIBAN);
      ibanFound = true;
    }

    if (ibanFound) {
      isBusy = false;
      Navigator.pop(
        context,
      );
      widget.onScannerResult(iban);
      return;
    }

    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

Widget getMask(BuildContext context) {
  Color _background = Colors.grey.withOpacity(0.7);

  return Column(
    children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: 1,
              color: _background,
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: _background,
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.width * 0.1,
                  width: MediaQuery.of(context).size.width * 0.8,
                  color: Colors.transparent,
                ),
                Expanded(
                  child: Container(
                    color: _background,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: 1,
              color: _background,
            ),
          ),
        ],
      )
    ],
  );
}
