import 'package:flutter/material.dart';
import 'package:yv_counter/common/sqlite_db_provider.dart';
import 'family_tree_page.dart';

class FamilyListPage extends StatefulWidget {
  const FamilyListPage({super.key});

  @override
  State<StatefulWidget> createState() => _FamilyListPageState();

  final families = const [
    'Vyas Family',
    'Kadvawat Family',
    'Dharmawat Family',
  ];

  final newFamilyName = "New Family";
}

class _FamilyListPageState extends State<FamilyListPage> {
  final List<bool> _readOnlyList = [];
  final List<String> _families = [];
  String _message = '';

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
        // _message = "Family Created!";
      });
    } else {
      setState(() {
        _message = "Family Already Exists!";
      });
    }
    await _resetMessage();
  }

  Future<void> _updateFamily(String oldName, String newName, int index) async {
    if (newName.isEmpty) {
      await DBProvider.db.deleteTable(oldName);
      setState(() {
        _families.removeAt(index);
        _message = "Family Deleted!";
      });
    } else {
      var isExist = await DBProvider.db.checkIfTableExists(newName);
      if (!isExist) {
        await DBProvider.db.renameTable(oldName, newName.trim());
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
    DBProvider.db.getFamilies().then((families) async {
      debugPrint(families.toString());
      if (families.isEmpty) {
        for (var family in widget.families) {
          await _addFamily(family);
        }
      } else {
        setState(() {
          _families.addAll(families.map((e) => e['name'].toString()));
          _setReadOnlyList();
        });
        debugPrint(_families.toString());
        debugPrint(_readOnlyList.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family List'),
        actions: [
          IconButton(
              onPressed: () async {
                debugPrint("Add family pressed.");
                await _addFamily(widget.newFamilyName);
              },
              icon: const Icon(Icons.add_circle)),
        ],
      ),
      body: _families.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _families.length,
                    itemBuilder: (context, index) {
                      final title = _families[index];
                      final readOnly = _readOnlyList[index];
                      InputDecoration inputDecoration = InputDecoration(
                        border: readOnly
                            ? InputBorder.none
                            : const OutlineInputBorder(),
                        hintText: "Enter Family Name",
                      );
                      final TextEditingController textController =
                          TextEditingController();
                      textController.text = title;
                      return ListTile(
                        title: TextField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          controller: textController,
                          decoration: inputDecoration,
                          readOnly: readOnly,
                          enabled: !readOnly,
                        ),
                        trailing: readOnly
                            ? IconButton(
                                onPressed: () {
                                  debugPrint("Edit for $title pressed.");
                                  setState(() {
                                    _setReadOnlyList();
                                    _readOnlyList[index] = false;
                                  });
                                },
                                icon: const Icon(Icons.edit))
                            : IconButton(
                                onPressed: () async {
                                  debugPrint("Done for $title pressed.");
                                  final newTitle = textController.text.trim();
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
            ),
    );
  }
}
