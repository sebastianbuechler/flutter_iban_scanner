import 'package:flutter/material.dart';
import 'package:flutter_iban_scanner/flutter_iban_scanner.dart';
import 'package:flutter_iban_scanner_example/model/iban_model.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
                            onScannerResult: (iban) =>
                                _showMyDialog(context, iban),
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

Future<void> _showMyDialog(context, iban) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('IBAN found!'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(iban),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Correct'),
            onPressed: () {
              Provider.of<IBANModel>(context, listen: false).setIBAN(iban);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
