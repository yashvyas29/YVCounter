
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:yv_counter/common/json_file_handler.dart';
import 'package:yv_counter/common/snackbar_dialog.dart';

import '../common/sqlite_db_provider.dart';
import '../data_model/treemember.dart';

class FamilyTreePage extends StatefulWidget {
  const FamilyTreePage({super.key, required this.title});

  @override
  State<FamilyTreePage> createState() => _FamilyTreePageState();

  final String title;
  final _jsonFileHandler = const JsonFileHandler();

  static const edgesKey = 'edges';

  String getFileName() {
    return _jsonFileHandler.getFamilyFileName(title);
  }

  Future<Map<String, dynamic>> readJsonData() async {
    final fileName = getFileName();
    final data = await _jsonFileHandler.readJson(fileName);
    if (data[edgesKey].isEmpty) {
      return await _jsonFileHandler.readJsonFromBundle(fileName);
    } else {
      return data;
    }
  }

  Future<void> writeJsonData(Map<String, dynamic> map) async {
    await _jsonFileHandler.writeJsonData(getFileName(), map);
  }
}

class _FamilyTreePageState extends State<FamilyTreePage> {
  Map<String, dynamic> _data = {};
  final TransformationController _transformationController = TransformationController();

  static const nodesKey = 'nodes';
  static const edgesKey = 'edges';

  static const spacing = 20.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                debugPrint("Reset to family pressed.");
                widget._jsonFileHandler.deleteLocalFile(widget.getFileName());
                if (_transformationController.value != Matrix4.identity()) {
                  _jumpToNode(1);
                }
                _graph = Graph()..isTree = true;
                setState(() {
                  _data.clear();
                });
              },
              icon: const Icon(Icons.restore)),
        ],
      ),
      body: _futureBuilder(),
    );
  }

  Widget rectangleWidget(Node node) {
    // debugPrint("rectangleWidget: ${node.toString()}");
    final nodes = _data[nodesKey];
    final id = node.key!.value;
    final nodeIndex = nodes.indexWhere((node) => node['id'] == id);
    // debugPrint("id: $id, nodeIndex: $nodeIndex");
    final nodeValue = nodes[nodeIndex];
    // debugPrint(nodeValue.toString());
    final value = nodeValue['label'].toString();
    final readOnly = nodeValue['readOnly'] ?? true;
    InputDecoration inputDecoration = InputDecoration(
      border: readOnly ? InputBorder.none : const OutlineInputBorder(),
      hintText: "Enter Name",
    );
    TextEditingController textController = TextEditingController();
    textController.text = value;
    // debugPrint(value);
    return InkWell(
      onTap: () {
        debugPrint('Node $value clicked at ${node.toString()}.');
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(color: Colors.red[400]!, spreadRadius: 1),
          ],
        ),
        child: Row(children: [
          Expanded(
            child: TextField(
              keyboardType: TextInputType.multiline,
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
                    showDeleteConfirmationDialog(
                        context, 'Are you sure you want to delete ?', () {
                      setState(() {
                        _removeNodeFromData(node);
                      });
                      Navigator.pop(context);
                      // debugPrint(graph.nodes.toString());
                      // debugPrint(graph.edges.toString());
                      widget.writeJsonData(_data);
                      // debugPrint(_data.toString());
                    });
                  },
                  icon: const Icon(Icons.delete)),
              readOnly
                  ? IconButton(
                      onPressed: () {
                        debugPrint("Edit for $value pressed.");
                        setState(() {
                          nodeValue['readOnly'] = false;
                          // _data[nodesKey][nodeIndex] = nodeValue;
                        });
                        widget.writeJsonData(_data);
                      },
                      icon: const Icon(Icons.edit))
                  : IconButton(
                      onPressed: () {
                        debugPrint("Done for $value pressed.");
                        setState(() {
                          nodeValue['label'] = textController.text;
                          nodeValue['readOnly'] = true;
                          // _data[nodesKey][nodeIndex] = nodeValue;
                        });
                        widget.writeJsonData(_data);
                      },
                      icon: const Icon(Icons.done_outline)),
              IconButton(
                  onPressed: () {
                    debugPrint("Add for $value pressed.");
                    final newId =
                        _data[nodesKey].fold(0, (previousValue, element) {
                              final currentValue = element['id'] ?? 0;
                              return previousValue > currentValue
                                  ? previousValue
                                  : currentValue;
                            }) +
                            1;
                    // debugPrint(newId.toString());
                    final newNodeValue = {"id": newId, "label": ""};
                    newNodeValue['readOnly'] = false;
                    // debugPrint(newNodeValue.toString());
                    setState(() {
                      _data[nodesKey].add(newNodeValue);
                      final edgeValue = {"from": id, "to": newId};
                      // debugPrint(edgeValue.toString());
                      _data[edgesKey].add(edgeValue);
                    });
                    widget.writeJsonData(_data);
                  },
                  icon: const Icon(Icons.add_circle)),
            ],
          ),
        ]),
      ),
    );
  }

  void _removeNodeFromData(Node node) {
    final id = node.key?.value;
    _data[nodesKey].removeWhere((element) => element['id'] == id);
    _data[edgesKey]
        .removeWhere((edge) => edge['from'] == id || edge['to'] == id);
    if (_graph.isTree) {
      _graph
          .successorsOf(node)
          .forEach((nodeElement) => _removeNodeFromData(nodeElement));
    }
    _graph.removeNode(node);
  }

  Graph _graph = Graph()..isTree = true;
  final BuchheimWalkerConfiguration _builder = BuchheimWalkerConfiguration();
  late final _CallbackBuchheimWalkerAlgorithm _algorithm;

  @override
  void initState() {
    debugPrint("initState");
    super.initState();

    _builder
      ..siblingSeparation = (spacing.toInt())
      ..levelSeparation = (spacing.toInt())
      ..subtreeSeparation = (spacing.toInt());

    _algorithm = _CallbackBuchheimWalkerAlgorithm(
      _builder,
      TreeEdgeRenderer(_builder),
      onFirstCalculated: () => _jumpToNode(1),
    );
  }

  /*
  void setupTransformationController() {
    // const zoomFactor = 1.0;
    final double xTranslate;
    final double yTranslate;
    if (kIsWeb ||
        Platform.isMacOS ||
        Platform.isLinux ||
        Platform.isWindows ||
        Platform.isFuchsia) {
      xTranslate = 4900.0;
      yTranslate = 1050.0;
    } else {
      xTranslate = 5380.0;
      yTranslate = 1100.0;
    }
    debugPrint("x: $xTranslate, y: $yTranslate");
    /*
    transformationController.value.setEntry(0, 0, zoomFactor);
    transformationController.value.setEntry(1, 1, zoomFactor);
    transformationController.value.setEntry(2, 2, zoomFactor);
    */
    _transformationController.value.setEntry(0, 3, -xTranslate);
    _transformationController.value.setEntry(1, 3, -yTranslate);
    /*
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
    */
  }
  */

  Widget _futureBuilder() {
    return _data.isEmpty
        ? FutureBuilder(
            future: widget.readJsonData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.red,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                _data = snapshot.data;
                return _graphView();
              } else {
                return const Center(
                  child: Text("Something went wrong, please try again later."),
                );
              }
            },
          )
        : _graphView();
  }

  Widget _graphView() {
    final edges = _data[edgesKey];
    updateNode(edges);

    final contextSize = MediaQuery.sizeOf(context);
    final horizontalInsets = contextSize.width - 200;
    final verticalInsets = contextSize.height - 200;

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: EdgeInsets.symmetric(horizontal: horizontalInsets, vertical: verticalInsets),
      minScale: 0.05,
      maxScale: 1,
      transformationController: _transformationController,
      child: GraphView(
        graph: _graph,
        algorithm: _algorithm,
        paint: Paint()
          ..color = Colors.green
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
        builder: (Node node) {
          return rectangleWidget(node);
        },
      ),
    );
  }

  Future<void> _jumpToNode(int nodeId) async {
    final startNode = _graph.nodes.firstWhere(
      (node) => node.key!.value == nodeId,
    );

    // Positions are custom for our page. You might need something different.
    final position = Offset(
      -(startNode.x - MediaQuery.sizeOf(context).width/2 + startNode.width/2),
      spacing,
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _transformationController.value = Matrix4.identity()
        ..translate(position.dx, position.dy);
    });
  }

  Future<void> updateNode(List edges) async {
    debugPrint("updateNode");
    debugPrint(edges.length.toString());
    // debugPrint(edges.toString());

    if (edges.isEmpty) {
      final nodes = _data[nodesKey];
      final int firstId;
      final int secondId;
      final bool firstReadOnly;
      final bool secondReadOnly;
      if (nodes.length >= 2) {
        firstId = nodes.first['id'];
        secondId = nodes.last['id'];
        firstReadOnly = true;
        secondReadOnly = true;
      } else if (nodes.length == 1) {
        firstId = nodes.first['id'];
        secondId = firstId + 1;
        firstReadOnly = true;
        secondReadOnly = false;
      } else {
        firstId = 1;
        secondId = 2;
        firstReadOnly = false;
        secondReadOnly = false;
      }
      final fromNode = Node.Id(firstId);
      final toNode = Node.Id(secondId);
      _data[nodesKey].add(
        {"id": firstId, "label": "", "readOnly": firstReadOnly},
      );
      _data[nodesKey].add(
        {"id": secondId, "label": "", "readOnly": secondReadOnly},
      );
      _data[edgesKey].add(
        {"from": firstId, "to": secondId},
      );
      _graph.addEdge(fromNode, toNode);
    } else {
      for (final element in edges) {
        var fromNodeId = element['from'];
        var toNodeId = element['to'];
        _graph.addEdge(Node.Id(fromNodeId), Node.Id(toNodeId));
      }

      var rowCount = await DBProvider.db.getRowCount(widget.title);
      // debugPrint(rowCount.toString());
      if (rowCount > 1) {
        await DBProvider.db.cleanTable(widget.title);
        // debugPrint("Cleaned ${widget.title} Table");
        final nodes = _data[nodesKey];

        for (final element in edges) {
          var fromNodeId = element['from'];
          var toNodeId = element['to'];

          final nodeIndex =
              nodes.indexWhere((node) => node['id'] == fromNodeId);
          final nodeValue = nodes[nodeIndex];
          final value = nodeValue['label'].toString();
          if (!await DBProvider.db
              .checkIfValueExists(widget.title, 'name', value)) {
            await DBProvider.db
                .insertMember(TreeMember(value, fromNodeId), widget.title);
            // debugPrint("From Inserted $value:$fromNodeId");
          }

          final nodeIndex1 = nodes.indexWhere((node) => node['id'] == toNodeId);
          final nodeValue1 = nodes[nodeIndex1];
          final value1 = nodeValue1['label'].toString();
          if (!await DBProvider.db
              .checkIfValueExists(widget.title, 'name', value1)) {
            await DBProvider.db.insertMember(
                TreeMember(value1, fromNodeId, toNodeId), widget.title);
            // debugPrint("To Inserted $value:$fromNodeId");
          } else {
            await DBProvider.db.updateMember(
                widget.title, TreeMember(value1, fromNodeId, toNodeId));
            // debugPrint("To Updated $value1:$fromNodeId");
          }
        }
      }
    }
  }
}

class _CallbackBuchheimWalkerAlgorithm extends BuchheimWalkerAlgorithm {
  _CallbackBuchheimWalkerAlgorithm(super.configuration, super.renderer, {required this.onFirstCalculated});

  bool _wasCalculated = false;
  void Function() onFirstCalculated;

  @override
  Size run(Graph? graph, double shiftX, double shiftY) {
    final size = super.run(graph, shiftX, shiftY);
    if (!_wasCalculated) {
      onFirstCalculated();
      _wasCalculated = true;
    }
    return size;
  }
}
