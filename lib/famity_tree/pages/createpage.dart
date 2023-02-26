import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/sqlite_db_provider.dart';
// import '../models/treemember.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  String _msg = '';
  Color color = Colors.red;

  _start() async {
    String name = _name.text;
    var table = await DBProvider.db.checkIfTableExists(name);
    if (table == false) {
      DBProvider.db.createNewTable(
        name,
        // TreeMember(name, null, 1),
      );
      setState(() {
        _msg = "Family Created!";
        color = Colors.black;
      });
    } else {
      debugPrint('Exists');
      setState(() {
        _msg = "Family Already Exists!";
        color = Colors.red;
      });
    }
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _msg = "";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Family"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          alignment: const Alignment(0, 0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Color(0xFF3366FF),
                  Color(0xFF00CCFF),
                ],
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
          child: Padding(
            padding: const EdgeInsets.all(50),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.person),
                        hintText: 'What is your family name?',
                        labelText: 'Name',
                      ),
                      controller: _name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp("[a-zA-Z\u00C0-\u017F ]")),
                        FilteringTextInputFormatter.singleLineFormatter,
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.all(10),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        //print(_name.text.replaceAll(RegExp(r"\s+"), ""));
                        if (_formKey.currentState!.validate()) {
                          _start();
                        }
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      _msg,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, color: color),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
