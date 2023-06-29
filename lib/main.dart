import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'dart:async';

import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=712b3ffd";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map<String, dynamic>> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body) as Map<String, dynamic>;
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  late double dolar;
  late double euro;

  void _realChanged(String text) {
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_rounded,
                  color: Colors.black,
                  size: 30.0,
                ),
                Text("Conversor",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25.0,
                  ),
                ),
                Icon(
                  Icons.account_balance_rounded,
                  color: Colors.black,
                  size: 30.0,
                ),
              ],
            ),
          ),
          backgroundColor: Colors.amber,
          centerTitle: true,
        ),

        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Center(
                      child: Text(
                    "Carregando Dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                default:
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text(
                      "Erro ao Carregar :(",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ));
                  } else {
                    final currencies = snapshot.data?["results"]["currencies"];
                    if (currencies != null) {
                      dolar = currencies["USD"]["buy"];
                      euro = currencies["EUR"]["buy"];
                    }

                    //dolar = snapshot.data["results"]["currencies"]["USD"];
                    //euro = snapshot.data["results"]["currencies"]["EUR"];

                    return FractionallySizedBox(
                      widthFactor: 1.0,
                      heightFactor: 1.0,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/image.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ) ,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                const Icon(
                                  Icons.monetization_on,
                                  size: 150.0,
                                  color: Colors.amber,
                                ),
                                const Divider(),
                                buildTextField(
                                    "Reais", "\$", realController, _realChanged),
                                const Divider(),
                                buildTextField("Dólares", "US\$", dolarController,
                                    _dolarChanged),
                                const Divider(),
                                buildTextField(
                                    "Euros", "\€", euroController, _euroChanged),
                              ],
                            ),
                        ),
                      ),
                    );
                  }
              }
            }));
  }
}

Widget buildTextField(
  String label,
  String prefix,
  TextEditingController c,
  void Function(String) f,
) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: f,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}

