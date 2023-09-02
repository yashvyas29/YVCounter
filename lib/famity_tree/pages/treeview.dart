import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:yv_counter/famity_tree/tools/string_extension.dart';

import '../../common/sqlite_db_provider.dart';
import '../models/treemember.dart';
import 'getnodetext.dart';

class LoadTree extends StatefulWidget {
  const LoadTree({super.key});

  @override
  State<LoadTree> createState() => _LoadTreeState();
}

class _LoadTreeState extends State<LoadTree> {
  late String _selected1 = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tree"),
      ),
      body: Container(
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
        alignment: const Alignment(0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Choose family: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder(
                      future: DBProvider.db.getFamilies(),
                      builder: (context, ss) {
                        if (ss.data == null) {
                          return const Text(
                            "No Data!",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          );
                        } else {
                          // debugPrint(ss.data.toString());
                          return Flexible(
                            child: DropdownButton(
                              hint: Text(_selected1.isEmpty
                                  ? "Select Family"
                                  : _selected1.capitalizeFirstofEach),
                              items:
                                  ss.data!.map<DropdownMenuItem<String>>((e) {
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
                        'Load Tree',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        setState(() {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => TreeViewPage(
                                    familyName: _selected1,
                                  )));
                        });
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TreeViewPage extends StatefulWidget {
  final String familyName;

  const TreeViewPage({super.key, required this.familyName});

  @override
  State<TreeViewPage> createState() => _GraphViewPageState();
}

class _GraphViewPageState extends State<TreeViewPage> {
  final Graph graph = Graph();
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  List<Map> family = [];

  List<Edge> findChild(List list) {
    List<Edge> edge = [];
    for (var map1 in list) {
      for (var map in list) {
        if (map.containsKey("c")) {
          if (map["c"] == map1["id"]) {
            edge.add(Edge(Node.Id(map1['id']), Node.Id(map['id'])));
          }
        }
      }
    }
    return edge;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tree"),
      ),
      body: Container(
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
        child: FutureBuilder(
          future: DBProvider.db.getMembers(widget.familyName),
          builder: (context, ss) {
            if (ss.data == null) {
              return Center(
                child: Container(
                  alignment: const Alignment(0, 0),
                  color: Colors.grey,
                  height: 200,
                  width: 200,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Loading...',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              );
            } else {
              family = ss.data!;
              // debugPrint(family.toString());

              final edge = findChild(family);
              graph.addEdges(edge);

              builder
                ..siblingSeparation = (50)
                ..levelSeparation = (100)
                ..subtreeSeparation = (100)
                ..orientation =
                    (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: InteractiveViewer(
                      constrained: false,
                      scaleEnabled: true,
                      boundaryMargin: const EdgeInsets.all(100),
                      minScale: 0.01,
                      maxScale: 5.6,
                      child: GraphView(
                        graph: graph,
                        algorithm: BuchheimWalkerAlgorithm(
                          builder,
                          TreeEdgeRenderer(builder),
                        ),
                        builder: (Node node) {
                          final nodeValue = family.firstWhere(
                            (element) => element['id'] == node.key!.value,
                          );
                          return GetNodeText(
                            txt1: "${nodeValue['name']}",
                            treeMember: TreeMember.fromJson(nodeValue),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
