part of 'graph_node_bloc.dart';

class BranchNodeBloc<T extends BranchNode, Data>
    extends ParentChildNodeBloc<T, Data, BranchNodeLoaded<T, Data>> {
  BranchNodeBloc({
    required super.initialNode,
    required super.parent,
    required super.nodeStream,
    required super.dataStream,
    required super.childNodesStream,
    required super.childNodeBlocBuilder,
  });

  @override
  BranchNodeLoaded<T, Data> loadedStateFromCombinedSnapshot<C extends NodeDataSnapshot<T, Data>>(
    C snapshot,
  ) {
    final children = (snapshot as NodeDataChildrenSnapshot<T, Data>).children;
    return BranchNodeLoaded(node: snapshot.node, children: children, data: snapshot.data);
  }
}

class BranchNodeLoaded<T extends BranchNode, Data> extends ParentNodeLoaded<T, Data> {
  const BranchNodeLoaded({required super.node, required super.children, required super.data});

  @override
  BranchNodeLoaded<T, Data> copyWith({T? node, List<ChildNodeBloc>? children, Data? data}) {
    return BranchNodeLoaded(
      node: node ?? this.node,
      children: children ?? this.children,
      data: data ?? this.data,
    );
  }
}
