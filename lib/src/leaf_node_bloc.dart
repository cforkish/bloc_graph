part of 'graph_node_bloc.dart';

class LeafNodeBloc<T extends LeafNode, Data>
    extends ChildNodeBloc<T, Data, LeafNodeLoaded<T, Data>> {
  LeafNodeBloc({
    required super.initialNode,
    required super.parent,
    required this.nodeStream,
    required this.dataStream,
  });

  @override
  final Stream<T?> nodeStream;
  @override
  final Stream<Data?> dataStream;

  @override
  LeafNodeLoaded<T, Data> loadedStateFromCombinedSnapshot<C extends NodeDataSnapshot<T, Data>>(
    C snapshot,
  ) {
    return LeafNodeLoaded(node: snapshot.node, data: snapshot.data);
  }
}

class LeafNodeLoaded<T extends LeafNode, Data> extends GraphNodeLoaded<T, Data> {
  const LeafNodeLoaded({required super.node, required super.data});

  @override
  LeafNodeLoaded<T, Data> copyWith({T? node, Data? data}) {
    return LeafNodeLoaded(node: node ?? this.node, data: data ?? this.data);
  }
}
