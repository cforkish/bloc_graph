abstract class GraphNode {
  const GraphNode({required this.id, required this.nodePath, required this.nodePathSegment});
  final String id;
  final String nodePath;
  final String nodePathSegment;
}

abstract class ChildNode extends GraphNode {
  const ChildNode({
    required super.id,
    required this.parentId,
    required this.rootId,
    required this.trunkId,
    required super.nodePath,
    required super.nodePathSegment,
  });
  final String parentId;
  final String rootId;
  final String trunkId;
}

abstract class ParentNode implements GraphNode {}

abstract class ParentChildNode implements ParentNode, ChildNode {}

class RootNode extends GraphNode implements ParentNode {
  const RootNode({required super.id, required super.nodePathSegment})
    : super(nodePath: nodePathSegment);

  @override
  String get nodePath => nodePathSegment;
}

class TrunkNode extends ChildNode implements ParentChildNode {
  const TrunkNode({
    required super.id,
    required super.rootId,
    required super.nodePath,
    required super.nodePathSegment,
  }) : super(parentId: rootId, trunkId: id);
}

class BranchNode extends ChildNode implements ParentChildNode {
  const BranchNode({
    required super.id,
    required super.parentId,
    required super.rootId,
    required super.trunkId,
    required super.nodePath,
    required super.nodePathSegment,
  });
}

class LeafNode extends ChildNode {
  const LeafNode({
    required super.id,
    required super.parentId,
    required super.rootId,
    required super.trunkId,
    required super.nodePath,
    required super.nodePathSegment,
  });
}
