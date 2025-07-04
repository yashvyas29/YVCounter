import 'package:flutter/material.dart';

import '../../data_model/treemember.dart';
import 'infopage.dart';

class GetNodeText extends StatefulWidget {
  final String txt1;
  final TreeMember treeMember;

  const GetNodeText({super.key, required this.txt1, required this.treeMember});

  @override
  State<GetNodeText> createState() => _GetNodeTextState();
}

class _GetNodeTextState extends State<GetNodeText> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                InfoPage(txt1: widget.txt1, treeMember: widget.treeMember),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [BoxShadow(color: Colors.blue[100]!, spreadRadius: 1)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.txt1.split("\n").length == 2
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(widget.txt1.split("\n")[0]),
                          const Icon(Icons.man, size: 40),
                        ],
                      ),
                    ),
                  )
                : Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(widget.txt1),
                          const Icon(Icons.people, size: 40),
                        ],
                      ),
                    ),
                  ),
            widget.txt1.split("\n").length == 2
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(widget.txt1.split("\n")[1]),
                          const Icon(Icons.woman, size: 40),
                        ],
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
