import 'package:flutter/material.dart';
import 'package:yv_counter/common/sqlite_db_provider.dart';
import '../common/json_file_handler.dart';
import '../common/snackbar_dialog.dart';
import 'family_tree_page.dart';

class FamilyListPage extends StatefulWidget {
  const FamilyListPage({super.key, required this.title});

  final String title;
  final _jsonFileHandler = const JsonFileHandler();

  @override
  State<StatefulWidget> createState() => _FamilyListPageState();

  final families = const [
    'Vyas Family',
    'Kadvawat Family',
    'Dharmawat Family',
  ];

  final newFamilyName = "New Family";

  String getFamilyFileName(String name) {
    return _jsonFileHandler.getFamilyFileName(name);
  }
}

class _FamilyListPageState extends State<FamilyListPage> {
  final List<bool> _readOnlyList = [];
  final List<String> _families = [];
  final List<TextEditingController> _controllers = [];
  String _message = '';

  Future<List<String>> _getFamilies() async {
    final families = await DBProvider.db.getFamilies();
    debugPrint(families.toString());
    if (families.isEmpty) {
      for (final family in widget.families) {
        await _addFamily(family);
      }
    } else {
      setState(() {
        _families.addAll(families.map((e) => e['name'].toString()));
        _setReadOnlyList();
        _controllers.addAll(
            _families.map((family) => TextEditingController(text: family)));
      });
    }
    return _families;
  }

  void _setReadOnlyList() {
    _readOnlyList.clear();
    _readOnlyList.addAll(_families
        .map((family) => family == widget.newFamilyName ? false : true));
  }

  Future<void> _addFamily(String name) async {
    var isExist = await DBProvider.db.checkIfTableExists(name);
    if (!isExist) {
      await DBProvider.db.createNewTable(name);
      setState(() {
        name == widget.newFamilyName
            ? _readOnlyList.add(false)
            : _readOnlyList.add(true);
        _families.add(name);
        _controllers.add(TextEditingController(text: name));
        // _message = "Family Created!";
      });
    } else {
      setState(() {
        _message = "Family Already Exists!";
      });
    }
    await _resetMessage();
  }

  Future<void> _deleteFamily(String name, int index) async {
    showDeleteConfirmationDialog(context, 'Are you sure you want to delete ?',
        () async {
      await DBProvider.db.deleteTable(name);
      await widget._jsonFileHandler
          .deleteLocalFile(widget.getFamilyFileName(name));
      setState(() {
        _families.removeAt(index);
        _readOnlyList.removeAt(index);
        _controllers.removeAt(index);
        Navigator.pop(context);
        _message = "Family Deleted!";
      });
      await _resetMessage();
    });
  }

  Future<void> _updateFamily(String oldName, String newName, int index) async {
    if (newName.isEmpty) {
      _deleteFamily(oldName, index);
    } else {
      var isExist = await DBProvider.db.checkIfTableExists(newName);
      if (!isExist) {
        await DBProvider.db.renameTable(oldName, newName.trim());
        widget._jsonFileHandler.renameFile(widget.getFamilyFileName(oldName),
            widget.getFamilyFileName(newName));
        setState(() {
          _families[index] = newName;
          _message = "Family Updated!";
        });
      } else {
        setState(() {
          _message = "Family Already Exists!";
        });
      }
    }
    await _resetMessage();
  }

  Future<void> _resetMessage() async {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _message = "";
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () async {
                debugPrint("Add family pressed.");
                await _addFamily(widget.newFamilyName);
              },
              icon: const Icon(Icons.add_circle)),
        ],
      ),
      body: _futureBuilder(),
    );
  }

  Widget _futureBuilder() {
    return _families.isEmpty
        ? FutureBuilder(
            future: _getFamilies(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.red,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return _familyList();
                } else {
                  return const Center(
                    child: Text("No families available."),
                  );
                }
              } else {
                return const Center(
                  child: Text("Something went wrong, please try again later."),
                );
              }
            },
          )
        : _familyList();
  }

  Widget _familyList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _families.length,
            itemBuilder: (context, index) {
              final title = _families[index];
              final readOnly = _readOnlyList[index];
              InputDecoration inputDecoration = InputDecoration(
                border:
                    readOnly ? InputBorder.none : const OutlineInputBorder(),
                hintText: "Enter Family Name",
              );
              return ListTile(
                title: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: _controllers[index],
                  decoration: inputDecoration,
                  readOnly: readOnly,
                  enabled: !readOnly,
                  autofocus: !readOnly,
                ),
                tileColor: Colors.white,
                focusColor: Colors.white,
                trailing: readOnly
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () async {
                                debugPrint("Delete for $title pressed.");
                                await _deleteFamily(title, index);
                              },
                              icon: const Icon(Icons.delete)),
                          IconButton(
                              onPressed: () async {
                                debugPrint("Edit for $title pressed.");
                                _setReadOnlyList();
                                setState(() {
                                  _readOnlyList[index] = false;
                                });
                              },
                              icon: const Icon(Icons.edit))
                        ],
                      )
                    : IconButton(
                        onPressed: () async {
                          debugPrint("Done for $title pressed.");
                          final newTitle = _controllers[index].text.trim();
                          if (newTitle == widget.newFamilyName) {
                            setState(() {
                              _message = "Rename to your family name!";
                            });
                            _resetMessage();
                          } else {
                            await _updateFamily(title, newTitle, index);
                            setState(() {
                              _setReadOnlyList();
                            });
                          }
                        },
                        icon: const Icon(Icons.done_outline)),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => FamilyTreePage(
                            title: title,
                          )));
                },
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(_message.isEmpty ? 0 : 20),
          child: Text(
            _message,
            style: TextStyle(fontSize: _message.isEmpty ? 0 : 20),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
  }
}
