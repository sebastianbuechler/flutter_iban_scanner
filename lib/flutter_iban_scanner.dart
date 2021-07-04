library flutter_iban_scanner;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:iban/iban.dart';
import 'package:provider/provider.dart';

import 'camera_view.dart';

List<CameraDescription> cameras = [];

class IBANScannerView extends StatefulWidget {
  final ValueChanged<String> onScannerResult;

  IBANScannerView({required Key key, required this.onScannerResult})
      : super(key: key);
  @override
  _IBANScannerViewState createState() => _IBANScannerViewState();
}

class _IBANScannerViewState extends State<IBANScannerView> {
  TextDetector textDetector = GoogleMlKit.vision.textDetector();
  bool isBusy = false;
  CustomPaint? customPaint;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  void _initCameras() async {
    cameras = await availableCameras();
  }

  @override
  void dispose() async {
    super.dispose();
    await textDetector.close();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      CameraView(
        title: 'Text Detector',
        customPaint: customPaint,
        onImage: (inputImage) {
          processImage(inputImage, context);
        },
      ),
      getMaskCard(context),
    ]);
  }

  RegExp regExp = RegExp(
    r"^([A-Z]{2}[ \-]?[0-9]{2})(?=(?:[ \-]?[A-Z0-9]){9,30}$)((?:[ \-]?[A-Z0-9]{3,5}){2,7})([ \-]?[A-Z0-9]{1,3})?$",
    caseSensitive: false,
    multiLine: false,
  );

  Future<void> processImage(InputImage inputImage, BuildContext context) async {
    if (isBusy) return;
    isBusy = true;
    var ibanFound = false;
    var iban;

    final recognisedText = await textDetector.processImage(inputImage);
    print('Found ${recognisedText.blocks.length} textBlocks');

    for (final textBlock in recognisedText.blocks) {
      if (!regExp.hasMatch(textBlock.text)) {
        continue;
      }

      var possibleIBAN = regExp.stringMatch(textBlock.text).toString();
      possibleIBAN = possibleIBAN.replaceAll(" ", "");
      if (!isValid(possibleIBAN)) {
        continue;
      }

      iban = toPrintFormat(possibleIBAN);
      ibanFound = true;
    }

    if (ibanFound) {
      // await textDetector.close();
      Navigator.pop(context);
      // Navigator.pop(myGlobals.scaffoldKey.currentContext!);
      // _showMyDialog(context, iban);
      widget.onScannerResult(iban);
      isBusy = false;
      return;
    }

    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

// Future<void> _showMyDialog(context, possibleIBAN) async {
//   return showDialog<void>(
//     // context: myGlobals.scaffoldKey.currentContext!,
//     context: context,
//     barrierDismissible: false, // user must tap button!
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('IBAN found!'),
//         content: SingleChildScrollView(
//           child: ListBody(
//             children: <Widget>[
//               Text(possibleIBAN),
//             ],
//           ),
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('Correct'),
//             onPressed: () {
//               Provider.of<IBANModel>(context, listen: false)
//                   .setIBAN(possibleIBAN);
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }

Widget getMaskCard(BuildContext context) {
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
