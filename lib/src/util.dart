part of 'graph_node_bloc.dart';

typedef ChildNodeBlocBuilder = ChildNodeBloc Function(ChildNode childNode, ParentNodeBloc parent);

/// Synchronizes a list of ChildNode objects with a list of ChildNodeBloc objects.
List<ChildNodeBloc> synchronizeChildNodeBlocs({
  required List<ChildNode> newChildNodes,
  required List<ChildNodeBloc> existingChildNodeBlocs,
  required ParentNodeBloc parent,
  required ChildNodeBlocBuilder childNodeBlocBuilder,
}) {
  final result = <ChildNodeBloc>[];

  final existingChildNodeBlocsMap = {
    for (var bloc in existingChildNodeBlocs) bloc.initialNode.id: bloc,
  };

  for (final childNode in newChildNodes) {
    if (existingChildNodeBlocsMap.containsKey(childNode.id)) {
      result.add(existingChildNodeBlocsMap[childNode.id]!);
    } else {
      final newBloc = childNodeBlocBuilder(childNode, parent);
      result.add(newBloc);
    }
  }

  for (final unusedBloc in existingChildNodeBlocsMap.values) {
    unusedBloc.close();
  }
  return result;
}

class NodeDataSnapshot<T extends GraphNode, Data> extends Equatable {
  const NodeDataSnapshot({required this.node, required this.data});
  final T node;
  final Data data;

  @override
  List<Object?> get props => [node, data];
}

class NodeDataChildrenSnapshot<T extends GraphNode, Data> extends NodeDataSnapshot<T, Data> {
  const NodeDataChildrenSnapshot({
    required super.node,
    required super.data,
    required this.children,
  });
  final List<ChildNodeBloc> children;

  @override
  List<Object?> get props => [...super.props, children];
}
