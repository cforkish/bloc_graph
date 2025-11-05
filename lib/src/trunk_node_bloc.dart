part of 'graph_node_bloc.dart';

class TrunkNodeBloc<T extends TrunkNode, Data>
    extends ParentChildNodeBloc<T, Data, TrunkNodeLoaded<T, Data>> {
  TrunkNodeBloc({
    required super.initialNode,
    required RootNodeBloc root,
    required super.nodeStream,
    required super.dataStream,
    required super.childNodesStream,
    required super.childNodeBlocBuilder,
  }) : super(parent: root);

  @override
  List<GraphNodeBloc> get lineage => [parent, this];
  @override
  RootNodeBloc get root => parent as RootNodeBloc;
  @override
  TrunkNodeBloc get trunk => this;

  @override
  TrunkNodeLoaded<T, Data> loadedStateFromCombinedSnapshot<C extends NodeDataSnapshot<T, Data>>(
    C snapshot,
  ) {
    final children = (snapshot as NodeDataChildrenSnapshot<T, Data>).children;
    return TrunkNodeLoaded(node: snapshot.node, children: children, data: snapshot.data);
  }
}

class TrunkNodeLoaded<T extends TrunkNode, Data> extends ParentNodeLoaded<T, Data> {
  const TrunkNodeLoaded({required super.node, required super.children, required super.data});

  @override
  TrunkNodeLoaded<T, Data> copyWith({T? node, List<ChildNodeBloc>? children, Data? data}) {
    return TrunkNodeLoaded(
      node: node ?? this.node,
      children: children ?? this.children,
      data: data ?? this.data,
    );
  }
}
