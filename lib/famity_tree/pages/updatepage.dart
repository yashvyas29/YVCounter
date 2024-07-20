import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yv_counter/famity_tree/tools/string_extension.dart';

import '../../common/sqlite_db_provider.dart';
import '../../data_model/treemember.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  String _selected1 = "";
  bool show = false;

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<void> getdata() async {
    setState(() {});
    refreshKey.currentState?.show();
    Future.delayed(const Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Update Members'),
        ),
        body: Container(
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
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Choose family: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    FutureBuilder<Iterable>(
                        future: DBProvider.db.getFamilies(),
                        builder: (context, ss) {
                          if (ss.data == null) {
                            return const Text(
                              'No data!',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            );
                          } else {
                            return Flexible(
                              child: DropdownButton(
                                hint: Text(_selected1.isEmpty
                                    ? "Select Family"
                                    : _selected1.capitalizeFirstofEach),
                                items:
                                    ss.data?.map<DropdownMenuItem<String>>((e) {
                                  String response = e['name'];
                                  return DropdownMenuItem(
                                    value: response,
                                    child: Text(response.capitalizeFirstofEach),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selected1 = value!;
                                  });
                                },
                              ),
                            );
                          }
                        }),
                    ElevatedButton(
                        child: const Text(
                          'Show Results',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          setState(() {
                            show = true;
                          });
                        }),
                  ],
                ),
              ),
              const Padding(padding: EdgeInsets.all(10)),
              RefreshIndicator(
                key: refreshKey,
                onRefresh: () => getdata(),
                child: show == true
                    ? FutureBuilder<Iterable>(
                        future: DBProvider.db.getMembers(_selected1),
                        builder: (context, ss) {
                          if (ss.connectionState == ConnectionState.waiting &&
                              !ss.hasData) {
                            return const Text(
                              'No data!',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            );
                          } else {
                            var data = List.from(ss.data!)..removeAt(0);
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: data.length,
                                itemBuilder: (context, item) {
                                  TreeMember treemember =
                                      TreeMember.fromJson(data[item]);
                                  return Card(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.people),
                                        Text(
                                          treemember.name.capitalizeFirstofEach,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              child: const Text(
                                                "Update",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Update(
                                                              table: _selected1,
                                                              treeMember:
                                                                  treemember,
                                                            )));
                                              },
                                            ),
                                            const Spacer(),
                                            ElevatedButton(
                                              child: const Text(
                                                "Delete",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red),
                                              ),
                                              onPressed: () {
                                                DBProvider.db.removeMember(
                                                    treemember, _selected1);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          }
                        })
                    : Container(),
              ),
            ],
          ),
        ));
  }
}

class Update extends StatefulWidget {
  final TreeMember treeMember;
  final String table;

  const Update({super.key, required this.treeMember, required this.table});

  @override
  State<Update> createState() => _UpdateState();
}

class _UpdateState extends State<Update> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name1 = TextEditingController();
  final TextEditingController _name2 = TextEditingController();
  late int _child;
  late String table, msg = '';
  Color color = Colors.green;
  late TreeMember treeMember;

  @override
  void initState() {
    super.initState();
    table = widget.table;
    treeMember = widget.treeMember;
    _child = widget.treeMember.c!;

    if (treeMember.name.split("\n").length == 2) {
      _name1.text = treeMember.name.split("\n")[0].capitalizeFirstofEach;
      _name2.text = treeMember.name.split("\n")[1].capitalizeFirstofEach;
    } else {
      _name1.text = treeMember.name.capitalizeFirstofEach;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            alignment: const Alignment(0, 0),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
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
            child: Container(
              color: Colors.white,
              height: 300,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      treeMember.name.split("\n").length == 2
                          ? TextFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                icon: Icon(Icons.person),
                                hintText: 'What is your name?',
                                labelText: 'Husband',
                              ),
                              controller: _name1,
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
                            )
                          : Container(),
                      treeMember.name.split("\n").length == 2
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
                                FilteringTextInputFormatter.singleLineFormatter,
                              ],
                            )
                          : Container(),
                      treeMember.name.split("\n").length != 2
                          ? TextFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                icon: Icon(Icons.person),
                                hintText: 'What is your name?',
                                labelText: 'Name',
                              ),
                              controller: _name1,
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
                            )
                          : Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Choose parent: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          FutureBuilder<Iterable>(
                              future: DBProvider.db.getMembers(table),
                              builder: (context, ss) {
                                if (ss.data == null) {
                                  return const Text(
                                    'No data!',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  );
                                } else {
                                  return Flexible(
                                    child: DropdownButton(
                                      hint: Text(_child == 0
                                          ? 'Selected Memeber'
                                          : ss.data!
                                              .firstWhere((element) =>
                                                  element['id'] ==
                                                  _child)['name']
                                              .toString()
                                              .capitalizeFirstofEach),
                                      items: ss.data!
                                          .map<DropdownMenuItem<int>>((e) {
                                        TreeMember treemember =
                                            TreeMember.fromJson(e);
                                        return DropdownMenuItem(
                                          value: treemember.id,
                                          child: Text(treemember
                                              .name.capitalizeFirstofEach),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _child = value!;
                                        });
                                      },
                                    ),
                                  );
                                }
                              }),
                        ],
                      ),
                      ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (widget.treeMember.name.split('\n').length ==
                                  2) {
                                var res =
                                    "${_name1.text.trim()} * ${_name2.text.trim()}";
                                treeMember.name = res.capitalizeFirstofEach;
                                treeMember.c = _child;
                                DBProvider.db.updateMember(table, treeMember);
                              } else {
                                treeMember.name =
                                    _name1.text.capitalizeFirstofEach;
                                treeMember.c = _child;
                                DBProvider.db.updateMember(table, treeMember);
                              }
                              setState(() {
                                msg = "Updated!";
                              });
                              Future.delayed(const Duration(seconds: 3), () {
                                setState(() {
                                  msg = "";
                                });
                              });
                            }
                          },
                          child: const Text('Update')),
                      Text(
                        msg,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: color),
                      ),
                    ],
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

class UpdateFamilies extends StatefulWidget {
  const UpdateFamilies({super.key});

  @override
  State<UpdateFamilies> createState() => _UpdateFamiliesState();
}

class _UpdateFamiliesState extends State<UpdateFamilies> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<void> getdata() async {
    //refreshKey.currentState.show();
    // setState(() {});
    // Future.delayed(
    //   const Duration(seconds: 3),
    // );
  }

  @override
  void initState() {
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Families'),
      ),
      body: Container(
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
        child: RefreshIndicator(
          key: refreshKey,
          onRefresh: () => getdata(),
          child: Container(
              alignment: const Alignment(0, -1),
              child: FutureBuilder<Iterable>(
                future: DBProvider.db.getFamilies(),
                builder: (context, ss) {
                  if (ss.data == null) {
                    return Container();
                  } else {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: ss.data!.length,
                        itemBuilder: (context, item) {
                          var data = ss.data!.toList()[item]['name'].toString();
                          return Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.people),
                                Text(
                                  data.capitalizeFirstofEach,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      child: const Text(
                                        "Update",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    NewDataFamily(
                                                      table: data,
                                                    )));
                                      },
                                    ),
                                    const Spacer(),
                                    ElevatedButton(
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red),
                                      ),
                                      onPressed: () {
                                        DBProvider.db.deleteTable(data);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        });
                  }
                },
              )),
        ),
      ),
    );
  }
}

class NewDataFamily extends StatefulWidget {
  final String table;

  const NewDataFamily({super.key, required this.table});

  @override
  State<NewDataFamily> createState() => _NewDataFamilyState();
}

class _NewDataFamilyState extends State<NewDataFamily> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name1 = TextEditingController();

  late String table, msg = '';
  Color color = Colors.green;

  @override
  void initState() {
    super.initState();
    table = widget.table;
    _name1.text = table.capitalizeFirstofEach;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            alignment: const Alignment(0, 0),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
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
            child: Container(
              color: Colors.white,
              height: 300,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                          hintText: 'What is your family name?',
                          labelText: 'Family Name',
                        ),
                        controller: _name1,
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
                      ElevatedButton(
                          onPressed: () {
                            DBProvider.db
                                .renameTable(widget.table, _name1.text.trim());
                            setState(() {
                              msg = "Updated!";
                            });
                            Future.delayed(const Duration(seconds: 3), () {
                              setState(() {
                                msg = "";
                              });
                            });
                          },
                          child: const Text('Update')),
                      Text(
                        msg,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: color),
                      ),
                    ],
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
