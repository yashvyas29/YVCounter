import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yv_counter/famity_tree/tools/string_extension.dart';

import '../../common/sqlite_db_provider.dart';
import '../../data_model/treemember.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _name2 = TextEditingController();
  int _selected = 0;
  String _selected1 = "";
  bool safe = false, married = false, dialog = false, safeNode = false;
  Color color = Colors.red;
  String msg = '';

  checkName(String table, String name) async {
    final res = await DBProvider.db.checkIfValueExists(table, 'name', name);
    setState(() {
      dialog = res;
    });
  }

  safeNodeStatus(String table) async {
    var res = await DBProvider.db.getMembers(table);
    if (res.length > 1) {
      setState(() {
        safeNode = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Members"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Form(
            key: _formKey,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
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
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  height: 550,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (married == false)
                            TextFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                icon: Icon(Icons.person),
                                hintText: 'What is your name?',
                                labelText: 'Child',
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
                          if (married == true)
                            TextFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                icon: Icon(Icons.person),
                                hintText: 'What is your name?',
                                labelText: 'Husband',
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
                          married == true
                              ? TextFormField(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    icon: Icon(Icons.person),
                                    hintText: 'What is your name?',
                                    labelText: 'Wife',
                                  ),
                                  controller: _name2,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[a-zA-Z\u00C0-\u017F ]")),
                                    FilteringTextInputFormatter
                                        .singleLineFormatter,
                                  ],
                                )
                              : Container(),
                          const Padding(padding: EdgeInsets.all(10)),
                          Column(
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Married',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Checkbox(
                                      value: married,
                                      onChanged: (v) {
                                        setState(() {
                                          married = v!;
                                        });
                                      }),
                                ],
                              ),
                              const Padding(padding: EdgeInsets.all(10)),
                              Row(
                                children: [
                                  const Text(
                                    'Choose family: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  FutureBuilder(
                                      future: DBProvider.db.getFamilies(),
                                      builder: (context, ss) {
                                        if (ss.data == null) {
                                          return const Text(
                                            'No Data!',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          );
                                        } else {
                                          debugPrint(ss.data.toString());
                                          return Flexible(
                                            child: DropdownButton(
                                              hint: Text(_selected1.isEmpty
                                                  ? "Select Family"
                                                  : _selected1
                                                      .capitalizeFirstofEach),
                                              items: ss.data?.map<
                                                      DropdownMenuItem<String>>(
                                                  (e) {
                                                String response = e['name'];
                                                return DropdownMenuItem(
                                                  value: response,
                                                  child: Text(response
                                                      .capitalizeFirstofEach),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  _selected1 = value ?? "";
                                                  safe = true;
                                                  safeNodeStatus(value!);
                                                });
                                                debugPrint(_selected1);
                                              },
                                            ),
                                          );
                                        }
                                      }),
                                ],
                              ),
                              safeNode == true
                                  ? Row(
                                      children: [
                                        const Text(
                                          'Choose parent: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        FutureBuilder<Iterable>(
                                            future: safe == true
                                                ? DBProvider.db
                                                    .getMembers(_selected1)
                                                : null,
                                            builder: (context, ss) {
                                              if (ss.data == null) {
                                                return const Text(
                                                  'No Data!',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                );
                                              } else {
                                                var data = List.from(ss.data!)
                                                  ..removeAt(0);
                                                return Flexible(
                                                  child: DropdownButton(
                                                    hint: Text(_selected == 0
                                                        ? 'Selected Memeber'
                                                        : data
                                                            .firstWhere(
                                                                (element) =>
                                                                    element[
                                                                        'id'] ==
                                                                    _selected)[
                                                                'name']
                                                            .toString()
                                                            .capitalizeFirstofEach),
                                                    items: data.map<
                                                        DropdownMenuItem<
                                                            int>>((e) {
                                                      TreeMember treemember =
                                                          TreeMember.fromJson(
                                                              e);
                                                      return DropdownMenuItem(
                                                        value: treemember.id,
                                                        child: Text(treemember
                                                            .name
                                                            .capitalizeFirstofEach),
                                                      );
                                                    }).toList(),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _selected = value!;
                                                      });
                                                      debugPrint(
                                                          _selected.toString());
                                                    },
                                                  ),
                                                );
                                              }
                                            }),
                                      ],
                                    )
                                  : Container(),
                            ],
                          ),
                          const Padding(padding: EdgeInsets.all(10)),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (married == false) {
                                  checkName(_selected1, _name.text.trim());
                                  Future.delayed(const Duration(seconds: 3),
                                      () {
                                    dialog == true
                                        ? showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                "Alert",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              content: Text(
                                                "${_name.text.trim()} already exists!",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                    child: const Text(
                                                      "back",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    }),
                                                ElevatedButton(
                                                    child: const Text(
                                                      "Insert",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    onPressed: () {
                                                      DBProvider.db
                                                          .insertMember(
                                                              TreeMember(
                                                                  _name.text
                                                                      .trim(),
                                                                  _selected),
                                                              _selected1);
                                                      Navigator.pop(context);
                                                    })
                                              ],
                                            ),
                                          )
                                        : safeNode == false
                                            ? DBProvider.db.insertMember(
                                                TreeMember(
                                                    _name.text.trim(), 1),
                                                _selected1)
                                            : DBProvider.db.insertMember(
                                                TreeMember(_name.text.trim(),
                                                    _selected),
                                                _selected1);
                                  });
                                } else if (married == true) {
                                  var res =
                                      "${_name.text.trim()} * ${_name2.text.trim()}";
                                  checkName(_selected1, res);
                                  Future.delayed(const Duration(seconds: 3),
                                      () {
                                    dialog == true
                                        ? showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                "Alert",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              content: Text(
                                                "$res already exists!",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                    child: const Text(
                                                      "back",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    }),
                                                ElevatedButton(
                                                    child: const Text(
                                                      "Insert",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    onPressed: () {
                                                      DBProvider.db
                                                          .insertMember(
                                                              TreeMember(res,
                                                                  _selected),
                                                              _selected1);
                                                      Navigator.pop(context);
                                                    })
                                              ],
                                            ),
                                          )
                                        : safeNode == false
                                            ? DBProvider.db.insertMember(
                                                TreeMember(res, 1), _selected1)
                                            : DBProvider.db.insertMember(
                                                TreeMember(res, _selected),
                                                _selected1);
                                  });
                                }
                                setState(() {
                                  msg = 'Added!';
                                  color = Colors.red;
                                  Future.delayed(const Duration(seconds: 3),
                                      () {
                                    setState(() {
                                      msg = '';
                                      color = Colors.red;
                                    });
                                  });
                                });
                              } else {
                                setState(() {
                                  msg =
                                      'Attention fill in and check everything';
                                  color = Colors.red;
                                });
                              }
                            },
                            child: const Text(
                              'Submit',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            msg,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: color),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
