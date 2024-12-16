import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:yv_counter/common/image_file_handler.dart';
import 'package:yv_counter/common/json_file_handler.dart';
import 'package:yv_counter/common/snackbar_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:yv_counter/family_members/family_member_page.dart';

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
    if (data.isEmpty) {
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
  final Map<int, dynamic> _images = {};
  late ImageFileHandler imageFileHandler;

  static const nodesKey = 'nodes';
  static const edgesKey = 'edges';

  static const spacing = 20.0;
  static const boxSide = 320.0;
  static const imageSide = 100.0;

  final _graph = Graph()..isTree = true;
  final BuchheimWalkerConfiguration _builder = BuchheimWalkerConfiguration();
  late final _CallbackBuchheimWalkerAlgorithm _algorithm;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    debugPrint("initState");
    super.initState();

    imageFileHandler = ImageFileHandler(prefix: widget.getFileName());

    _builder
      ..siblingSeparation = (spacing.toInt())
      ..levelSeparation = (spacing.toInt())
      ..subtreeSeparation = (spacing.toInt());

    _algorithm = _CallbackBuchheimWalkerAlgorithm(
      _builder,
      TreeEdgeRenderer(_builder),
      onFirstCalculated: () => _jumpToRootNode(),
    );
  }

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
                _reset();
              },
              icon: const Icon(Icons.restore)),
        ],
      ),
      body: _futureBuilder(),
    );
  }

  void _reset() {
    if (_transformationController.value != Matrix4.identity()) {
      _jumpToRootNode();
    }
    /*
    widget._jsonFileHandler.deleteLocalFile(widget.getFileName());
    _graph = Graph()..isTree = true;
    setState(() {
      _data.clear();
    });
    */
  }

  Widget _borderedWidget(Widget widget) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
      ),
      child: widget,
    );
  }

  /*
  Widget _clipRectWidget(Widget widget, double radius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: widget,
    );
  }
  */

  Widget _imageWidget(File image) {
    return _borderedWidget(
      Image.file(
        image,
        width: imageSide,
        height: imageSide,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _rectangleWidget(Node node) {
    // debugPrint("rectangleWidget: ${node.toString()}");
    final nodes = _data[nodesKey];
    final id = node.key!.value;
    final nodeIndex = nodes.indexWhere((node) => node['id'] == id);
    // debugPrint("id: $id, nodeIndex: $nodeIndex");
    final nodeValue = nodes[nodeIndex];
    // debugPrint(nodeValue.toString());
    final value = nodeValue['label'].toString();
    final readOnly = nodeValue['readOnly'] ?? true;
    final isRoot = nodeValue['isRoot'] ?? false;
    final isRootChild = nodeValue['isRootChild'] ?? false;
    final localizations = AppLocalizations.of(context);
    final hintText = isRoot
        ? localizations.enterParentsName
        : localizations.enterChildAndSpouseName;
    InputDecoration inputDecoration = InputDecoration(
      border: readOnly ? InputBorder.none : const OutlineInputBorder(),
      hintText: hintText,
      isDense: true,
    );
    TextEditingController textController = TextEditingController();
    textController.text = value;
    final image = _images[id];

    return InkWell(
      onTap: () {
        debugPrint('Node $value clicked at ${node.toString()}.');
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => FamilyMemberPage(
              id: id,
              name: value,
              familyFileName: widget.getFileName(),
            ),
          ),
        )
            .then((val) {
          setState(() {
            _data.clear();
            _images.clear();
          });
        });
      },
      child: Container(
        width: boxSide,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(color: Colors.red[300]!, spreadRadius: 1),
          ],
        ),
        child: Row(children: [
          image != null
              ? _imageWidget(image)
              : FutureBuilder(
                  future: imageFileHandler.loadImage(id),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      final image = snapshot.data!;
                      _images[id] = image;
                      return _imageWidget(image);
                    } else {
                      return _borderedWidget(
                        Icon(
                          Icons.person,
                          size: imageSide,
                        ),
                      );
                    }
                  },
                ),
          SizedBox(width: 8),
          Expanded(
            child: readOnly
                ? Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                : TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: textController,
                    decoration: inputDecoration,
                    readOnly: readOnly,
                    autofocus: !readOnly,
                  ),
          ),
          SizedBox(width: 4),
          Column(
            children: [
              if (!isRoot && ((!isRootChild && nodes.length > 2) || readOnly))
                IconButton(
                    onPressed: () {
                      debugPrint("Delete for $value pressed.");
                      showDeleteConfirmationDialog(
                          context,
                          AppLocalizations.of(context)
                              .deleteConfirmation(name: value), () async {
                        setState(() {
                          _removeNodeFromData(node);
                        });
                        await widget.writeJsonData(_data);
                        if (_data[edgesKey].length <= 1) {
                          _reset();
                        }
                        if (!mounted) return;
                        Navigator.pop(context);
                        showSnackBar(
                            context, "$value ${localizations.deleted}");
                      });
                    },
                    icon: const Icon(Icons.delete))
              else if (isRoot && readOnly)
                IconButton(
                    onPressed: () async {
                      debugPrint("Add on top for $value pressed.");
                      final nodes = _data[nodesKey];
                      final newId = _getNewNodeId();
                      final currentRoot = nodes.firstWhere(
                        (node) => node['isRoot'] == true,
                      );
                      currentRoot.remove('isRoot');
                      try {
                        final currentRootChild = nodes.firstWhere(
                          (node) => node['isRootChild'] == true,
                        );
                        currentRootChild.remove('isRootChild');
                      } catch (error) {
                        debugPrint("No root child found.\n$error");
                      }
                      currentRoot['isRootChild'] = true;
                      final newNode = _getNewNodeMap(newId, isRoot: true);
                      final newEdge = {"from": newId, "to": id};
                      setState(() {
                        _data[nodesKey].add(newNode);
                        _data[edgesKey].add(newEdge);
                      });
                      await widget.writeJsonData(_data);
                    },
                    icon: const Icon(Icons.add_box)),
              readOnly
                  ? IconButton(
                      onPressed: () {
                        debugPrint("Edit for $value pressed.");
                        try {
                          final currentEditableNode = nodes.firstWhere(
                            (node) =>
                                node['readOnly'] == false &&
                                !node['label'].isEmpty,
                          );
                          currentEditableNode['readOnly'] = true;
                        } catch (error) {
                          debugPrint("No editable node found.\n$error");
                        }
                        setState(() {
                          nodeValue['readOnly'] = false;
                        });
                        // await widget.writeJsonData(_data);
                      },
                      icon: const Icon(Icons.edit))
                  : IconButton(
                      onPressed: () async {
                        debugPrint("Done for $value pressed.");
                        final text = textController.text;
                        if (text.isNotEmpty) {
                          setState(() {
                            nodeValue['label'] = textController.text;
                            nodeValue['readOnly'] = true;
                          });
                          await widget.writeJsonData(_data);
                          if (!mounted) return;
                          final message = value.isEmpty
                              ? "$text ${localizations.added}"
                              : "$value ${localizations.updated}";
                          showSnackBar(context, message);
                        } else {
                          debugPrint(hintText);
                        }
                      },
                      icon: const Icon(Icons.done_outline)),
              if (readOnly)
                IconButton(
                    onPressed: () async {
                      debugPrint("Add for $value pressed.");
                      final newId = _getNewNodeId();
                      final newNode = _getNewNodeMap(newId);
                      final newEdge = {"from": id, "to": newId};
                      setState(() {
                        _data[nodesKey].add(newNode);
                        _data[edgesKey].add(newEdge);
                      });
                      await widget.writeJsonData(_data);
                    },
                    icon: const Icon(Icons.add_circle))
              else if (value.isNotEmpty)
                IconButton(
                    onPressed: () {
                      debugPrint("Cancel for $value pressed.");
                      setState(() {
                        nodeValue['readOnly'] = true;
                      });
                      // await widget.writeJsonData(_data);
                    },
                    icon: const Icon(Icons.cancel)),
            ],
          ),
        ]),
      ),
    );
  }

  int _getNewNodeId() {
    return _data[nodesKey].fold(0, (previousValue, element) {
          final currentValue = element['id'] ?? 0;
          return previousValue > currentValue ? previousValue : currentValue;
        }) +
        1;
  }

  Map<String, dynamic> _getNewNodeMap(int id, {bool isRoot = false}) {
    final newNodeValue = {"id": id, "label": ""};
    newNodeValue['readOnly'] = false;
    if (isRoot) {
      newNodeValue['isRoot'] = isRoot;
    }
    // debugPrint(newNodeValue.toString());
    return newNodeValue;
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
                final data = snapshot.data!;
                if (data.isEmpty) {
                  _data = {nodesKey: [], edgesKey: []};
                } else {
                  _data = data;
                }
                return _graphView();
              } else {
                return Center(
                  child: Text(AppLocalizations.of(context).commonError),
                );
              }
            },
          )
        : _graphView();
  }

  Widget _graphView() {
    final edges = _data[edgesKey];
    _updateNode(edges);

    final contextSize = MediaQuery.sizeOf(context);
    final horizontalInsets = contextSize.width - boxSide - spacing;
    final topToExclude = Platform.isAndroid
        ? MediaQuery.viewPaddingOf(context).top + kToolbarHeight
        : 0;
    final verticalInsets =
        contextSize.height - boxSide - spacing - topToExclude;

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: EdgeInsets.symmetric(
        horizontal: horizontalInsets,
        vertical: verticalInsets,
      ),
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
          return _rectangleWidget(node);
        },
      ),
    );
  }

  void _jumpToRootNode() {
    final currentRoot = _data[nodesKey].firstWhere(
      (node) => node['isRoot'] == true,
    );
    _jumpToNode(currentRoot['id']);
  }

  void _jumpToNode(int nodeId) {
    final startNode = _graph.nodes.firstWhere(
      (node) => node.key!.value == nodeId,
    );

    // Positions are custom for our page. You might need something different.
    final position = Offset(
      -(startNode.x -
          MediaQuery.sizeOf(context).width / 2 +
          startNode.width / 2),
      -(startNode.y - spacing),
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _transformationController.value = Matrix4.identity()
        ..translate(position.dx, position.dy);
    });
  }

  void _updateNode(List edges) {
    /*
    debugPrint("updateNode");
    debugPrint("Edges count: ${edges.length.toString()}");
    debugPrint("Edges value: ${edges.toString()}");
    */

    if (edges.isEmpty) {
      final nodes = _data[nodesKey];
      /*
      debugPrint("Nodes count: ${nodes.length.toString()}");
      debugPrint("Nodes value: ${nodes.toString()}");
      */
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
      if (!firstReadOnly) {
        _data[nodesKey].add(
          {
            "id": firstId,
            "label": "",
            "readOnly": firstReadOnly,
            "isRoot": true
          },
        );
      }
      if (!secondReadOnly) {
        _data[nodesKey].add(
          {
            "id": secondId,
            "label": "",
            "readOnly": secondReadOnly,
            "isRootChild": true
          },
        );
      }
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

      /*
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
      */
    }
  }
}

class _CallbackBuchheimWalkerAlgorithm extends BuchheimWalkerAlgorithm {
  bool _wasCalculated = false;
  void Function() onFirstCalculated;

  _CallbackBuchheimWalkerAlgorithm(
    super.configuration,
    super.renderer, {
    required this.onFirstCalculated,
  });

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
