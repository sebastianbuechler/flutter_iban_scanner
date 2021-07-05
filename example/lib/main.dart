import 'package:flutter/material.dart';
import 'package:flutter_iban_scanner/flutter_iban_scanner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Color(0xff009ACE),
          accentColor: Color(0xffFCC442),
        ),
        home: Home(),
      ),
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
    super.initState();
    _ibanController = TextEditingController();
  }

  @override
  void dispose() {
    _ibanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusNode focusNode = FocusNode();
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
              child: TextField(
                controller: _ibanController,
                // onChanged: (iban) => _ibanController.text = iban,
                onChanged: (iban) => _ibanController.value.copyWith(
                  text: iban,
                  selection: TextSelection(
                    baseOffset: iban.length,
                    extentOffset: iban.length,
                  ),
                ),
                // inputFormatters: [
                //   MaskTextInputFormatter(
                //     mask: '## #### #### #### #### #### #### ####',
                //   ),
                // ],
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: "IBAN",
                  labelStyle: TextStyle(color: Theme.of(context).primaryColor),
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
                    onPressed: () => {
                      focusNode.unfocus(),
                      focusNode.canRequestFocus = false,
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IBANScannerView(
                              key: GlobalKey(),
                              onScannerResult: (iban) => {
                                    _showMyDialog(context, iban),
                                    _ibanController.text = iban,
                                  }),
                        ),
                      ),
                      Future.delayed(Duration(milliseconds: 100), () {
                        focusNode.canRequestFocus = true;
                      }),
                    },
                  ),
                ),
              ),
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
            child: const Text('Retry'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IBANScannerView(
                      key: GlobalKey(),
                      onScannerResult: (iban) => {
                            _showMyDialog(context, iban),
                          }),
                ),
              );
            },
          ),
          TextButton(
            child: const Text('Correct'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// The DismissKeybaord widget (it's reusable)
class DismissKeyboard extends StatelessWidget {
  final Widget child;
  DismissKeyboard({required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
      },
      child: child,
    );
  }
}
