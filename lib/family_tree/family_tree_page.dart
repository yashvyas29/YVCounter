import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphview/GraphView.dart';
import 'package:yv_counter/family_tree/my_node.dart';

class FamilyTreePage extends StatefulWidget {
  const FamilyTreePage({super.key, required this.title});

  @override
  State<FamilyTreePage> createState() => _FamilyTreePageState();

  final String title;

  Future readJsonData() async {
    debugPrint("readJsonData");
    final map = await readJson();
    if (map.isEmpty) {
      final content =
          await rootBundle.loadString('lib/family_tree/family.json');
      // debugPrint(content);
      return jsonDecode(content);
    } else {
      return map;
    }
  }
}

class _FamilyTreePageState extends State<FamilyTreePage> {
  late Map<String, dynamic> data;
  TransformationController transformationController =
      TransformationController();

  static const nodesKey = 'nodes';
  static const edgesKey = 'edges';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder(
        future: widget.readJsonData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                  backgroundColor: Colors.red,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            data = snapshot.data;
            final edges = data["edges"];
            updateNode(edges);
            return Column(
              children: [
                Expanded(
                  child: InteractiveViewer(
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(100),
                    minScale: 0.01,
                    maxScale: 5.6,
                    transformationController: transformationController,
                    child: GraphView(
                      graph: graph,
                      algorithm: BuchheimWalkerAlgorithm(
                          builder, TreeEdgeRenderer(builder)),
                      paint: Paint()
                        ..color = Colors.green
                        ..strokeWidth = 1
                        ..style = PaintingStyle.stroke,
                      builder: (Node node) {
                        final a = node.key!.value as int?;
                        final nodes = data[nodesKey];
                        // debugPrint(nodes.toString());
                        final nodeValue =
                            nodes.firstWhere((element) => element['id'] == a);
                        return rectangleWidget(nodeValue);
                      },
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(
            child: Text("Something went wrong, please try again later."),
          );
        },
      ),
    );
  }

  Widget rectangleWidget(Map<String, dynamic> nodeValue) {
    final id = nodeValue['id'];
    final nodeIndex = id - 1;
    final value = nodeValue['label'].toString();
    final readOnly = nodeValue['readOnly'] ?? true;
    InputDecoration inputDecoration;
    if (readOnly) {
      inputDecoration = const InputDecoration.collapsed(
        hintText: "Enter Name",
      );
    } else {
      inputDecoration = const InputDecoration(
        hintText: "Enter Name",
      );
    }
    TextEditingController textController = TextEditingController();
    textController.text = value;
    // debugPrint(value);
    return InkWell(
      onTap: () {
        debugPrint('Node $value clicked.');
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(color: Colors.blue[100]!, spreadRadius: 1),
          ],
        ),
        child: Row(children: [
          Expanded(
            child: TextField(
              maxLines: null,
              controller: textController,
              decoration: inputDecoration,
              readOnly: readOnly,
            ),
          ),
          Column(
            children: [
              IconButton(
                  onPressed: () {
                    debugPrint("Delete for $value pressed.");
                    data[nodesKey].remove(nodeValue);
                    data[edgesKey].removeWhere(
                        (edge) => edge['from'] == id || edge['to'] == id);
                    writeJsonData(data);
                    graph.removeNode(Node.Id(id));
                    /*
                      List edgesToDelete = data[edgesKey]
                          .where(
                              (edge) => edge['from'] == id || edge['to'] == id)
                          .toList();
                      List<Edge> deleteEdges = edgesToDelete
                          .map((edge) =>
                              Edge(Node.Id(edge['from']), Node.Id(edge['to'])))
                          .toList();
                      graph.removeEdges(deleteEdges);
                      */
                    setState(() {});
                  },
                  icon: const Icon(Icons.delete)),
              readOnly
                  ? IconButton(
                      onPressed: () {
                        debugPrint("Edit for $value pressed.");
                        nodeValue['readOnly'] = false;
                        data[nodesKey][nodeIndex] = nodeValue;
                        writeJsonData(data);
                        setState(() {});
                      },
                      icon: const Icon(Icons.edit))
                  : IconButton(
                      onPressed: () {
                        debugPrint("Done for $value pressed.");
                        nodeValue['label'] = textController.text;
                        nodeValue['readOnly'] = true;
                        data[nodesKey][nodeIndex] = nodeValue;
                        writeJsonData(data);
                        setState(() {});
                      },
                      icon: const Icon(Icons.done_outline)),
              IconButton(
                  onPressed: () {
                    debugPrint("Add for $value pressed.");
                    final newId = data[nodesKey].length + 1;
                    final newNodeValue = {"id": newId, "label": ""};
                    newNodeValue['readOnly'] = false;
                    debugPrint(newNodeValue.toString());
                    data[nodesKey].add(newNodeValue);
                    final edgeValue = {"from": id, "to": newId};
                    debugPrint(edgeValue.toString());
                    data[edgesKey].add(edgeValue);
                    writeJsonData(data);
                    setState(() {});
                  },
                  icon: const Icon(Icons.add_circle)),
            ],
          ),
        ]),
      ),
    );
  }

  Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  void initState() {
    debugPrint("initState");
    super.initState();
    builder
      ..siblingSeparation = (10)
      ..levelSeparation = (15)
      ..subtreeSeparation = (15)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);

    // const zoomFactor = 1.0;
    final double xTranslate;
    final double yTranslate;
    if (kIsWeb ||
        Platform.isMacOS ||
        Platform.isLinux ||
        Platform.isWindows ||
        Platform.isFuchsia) {
      xTranslate = 4900.0;
      yTranslate = 900.0;
    } else {
      xTranslate = 5380.35;
      yTranslate = 659.40;
    }
    debugPrint("x: $xTranslate, y: $yTranslate");
    /*
    transformationController.value.setEntry(0, 0, zoomFactor);
    transformationController.value.setEntry(1, 1, zoomFactor);
    transformationController.value.setEntry(2, 2, zoomFactor);
    */
    transformationController.value.setEntry(0, 3, -xTranslate);
    transformationController.value.setEntry(1, 3, -yTranslate);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (MediaQuery.of(context).orientation == Orientation.landscape &&
          !kIsWeb &&
          (Platform.isAndroid || Platform.isIOS)) {
        const xTranslate = 5150.0;
        const yTranslate = 855.0;
        transformationController.value.setEntry(0, 3, -xTranslate);
        transformationController.value.setEntry(1, 3, -yTranslate);
        debugPrint("x: $xTranslate, y: $yTranslate");
      }
    });
  }

  void updateNode(List edges) {
    debugPrint("updateNode");
    for (var element in edges) {
      // debugPrint(element.toString());
      var fromNodeId = element['from'];
      var toNodeId = element['to'];
      graph.addEdge(Node.Id(fromNodeId), Node.Id(toNodeId));
    }
  }
}
