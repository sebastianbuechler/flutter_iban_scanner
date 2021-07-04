import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:flutter_iban_scanner/flutter_iban_scanner.dart';
import 'package:flutter_iban_scanner_example/VisionDetectorViews/text_detector_view.dart';
import 'package:flutter_iban_scanner_example/globals.dart';
import 'package:flutter_iban_scanner_example/iban_model.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(
    ChangeNotifierProvider(
      create: (context) => IBANModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff009ACE),
        accentColor: Color(0xffFCC442),
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late TextEditingController _ibanController;

  @override
  void initState() {
    final IBANModel ibanModel = Provider.of<IBANModel>(context, listen: false);

    super.initState();
    _ibanController = TextEditingController(text: ibanModel.iban);
  }

  @override
  void dispose() {
    _ibanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final IBANModel ibanModel = Provider.of<IBANModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('IBAN Scanner Demo App'),
        centerTitle: true,
        elevation: 0,
      ),
      key: myGlobals.scaffoldKey,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Consumer<IBANModel>(builder: (context, appState, child) {
                if (_ibanController.text != appState.iban) {
                  _ibanController.text = appState.iban;
                }
                return TextField(
                  controller: _ibanController,
                  onChanged: ibanModel.setIBAN,
                  inputFormatters: [
                    MaskTextInputFormatter(
                      mask: '## #### #### #### #### #### #### ####',
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: "IBAN",
                    labelStyle:
                        TextStyle(color: Theme.of(context).primaryColor),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    hintText: 'CH ....',
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IBANScannerView(
                            key: GlobalKey(),
                            onScannerResult: _showMyDialog,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showMyDialog(possibleIBAN) async {
  return showDialog<void>(
    context: myGlobals.scaffoldKey.currentContext!,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('IBAN found!'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(possibleIBAN),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Correct'),
            onPressed: () {
              Provider.of<IBANModel>(context, listen: false)
                  .setIBAN(possibleIBAN);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
