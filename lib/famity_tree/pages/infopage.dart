import 'package:flutter/material.dart';
import 'package:yv_counter/famity_tree/tools/string_extension.dart';

import '../../data_model/treemember.dart';

class InfoPage extends StatefulWidget {
  final TreeMember treeMember;
  final String txt1;

  const InfoPage({super.key, required this.treeMember, required this.txt1});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Info')),
      body: Container(
        alignment: const Alignment(0, 0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3366FF), Color(0xFF00CCFF)],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                widget.txt1.split("\n").length == 2
                    ? Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Husband: ${widget.txt1.split("\n")[0].capitalizeFirstofEach}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Name: ${widget.txt1.capitalizeFirstofEach}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                widget.txt1.split("\n").length == 2
                    ? Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Wife: ${widget.txt1.split("\n")[1].capitalizeFirstofEach}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyEditableText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;

  const MyEditableText({
    super.key,
    required this.text,
    required this.textStyle,
  });

  @override
  State<MyEditableText> createState() => _MyEditableTextState();
}

class _MyEditableTextState extends State<MyEditableText> {
  final TextEditingController _textEditingController = TextEditingController();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: isEditing == false
          ? InkWell(
              onTap: () {
                setState(() {
                  isEditing = !isEditing;
                });
              },
              child: Card(
                child: Text(
                  _textEditingController.text,
                  textAlign: TextAlign.center,
                  style: widget.textStyle,
                ),
              ),
            )
          : TextField(
              controller: _textEditingController,
              style: widget.textStyle,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onEditingComplete: () {
                setState(() {
                  isEditing = !isEditing;
                });
              },
            ),
    );
  }
}
