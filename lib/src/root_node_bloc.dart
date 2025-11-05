part of 'graph_node_bloc.dart';

class RootNodeBloc<T extends RootNode, Data>
    extends ParentNodeBloc<T, Data, RootNodeLoaded<T, Data>> {
  RootNodeBloc({
    required super.nodeStream,
    required super.dataStream,
    required super.childNodesStream,
    required super.initialNode,
    required super.childNodeBlocBuilder,
  });

  @override
  RootNodeBloc get root => this;

  @override
  List<GraphNodeBloc> get lineage => [this];

  @override
  bool isDescendantOf(GraphNodeBloc other) => false;

  @override
  RootNodeLoaded<T, Data> loadedStateFromCombinedSnapshot<C extends NodeDataSnapshot<T, Data>>(
    C snapshot,
  ) {
    final children = (snapshot as NodeDataChildrenSnapshot<T, Data>).children;
    return RootNodeLoaded(node: snapshot.node, children: children, data: snapshot.data);
  }
}

class RootNodeLoaded<T extends RootNode, Data> extends ParentNodeLoaded<T, Data> {
  const RootNodeLoaded({required super.node, required super.children, required super.data});

  @override
  RootNodeLoaded<T, Data> copyWith({T? node, List<ChildNodeBloc>? children, Data? data}) {
    return RootNodeLoaded(
      node: node ?? this.node,
      children: children ?? this.children,
      data: data ?? this.data,
    );
  }
}
