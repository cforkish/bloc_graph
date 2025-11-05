part of 'graph_node_bloc.dart';

mixin ParentNodeBlocMixin<T extends ParentNode, Data, S extends ParentNodeLoaded<T, Data>>
    on GraphNodeBloc<T, Data, S> {}

abstract class ParentNodeBloc<T extends ParentNode, Data, S extends ParentNodeLoaded<T, Data>>
    extends GraphNodeBloc<T, Data, S>
    with ParentNodeBlocMixin<T, Data, S> {
  ParentNodeBloc({
    required super.initialNode,
    required super.nodeStream,
    required super.dataStream,
    required this.childNodesStream,
    required this.childNodeBlocBuilder,
  }) {
    on<GraphNodeChildrenUpdated>(_onChildrenUpdated);
  }

  @protected
  final Stream<List<ChildNode>> childNodesStream;

  @protected
  final ChildNodeBlocBuilder childNodeBlocBuilder;

  @protected
  late final StreamSubscription<List<ChildNode>> childrenSubscription;

  @override
  List<Stream<dynamic>> get subStreams => [...super.subStreams, childNodesStream];

  @override
  bool isAncestorOf(GraphNodeBloc other) {
    return other != this && other.lineage.contains(this);
  }

  Future<List<GraphNodeBloc>> getChildren() async {
    await awaitLoaded();
    return (state as S).children;
  }

  @override
  NodeDataSnapshot<T, Data> combinedStreamsSnapshot(List<dynamic> substreamSnapshots) {
    final NodeDataSnapshot<T, Data> nodeDataSnapshot = super.combinedStreamsSnapshot(
      substreamSnapshots,
    );
    final List<ChildNodeBloc> children = synchronizeChildNodeBlocs(
      newChildNodes: (substreamSnapshots[2] as List<ChildNode>),
      existingChildNodeBlocs: (state as S).children,
      parent: this,
      childNodeBlocBuilder: childNodeBlocBuilder,
    );
    return NodeDataChildrenSnapshot<T, Data>(
      node: nodeDataSnapshot.node,
      data: nodeDataSnapshot.data,
      children: children,
    );
  }

  @override
  void subscribeToSubStreams() {
    super.subscribeToSubStreams();
    childrenSubscription = childNodesStream.listen((children) {
      if (ListEquality().equals(children, (state as S).children)) {
        return;
      }
      add(GraphNodeChildrenUpdated(children));
    });
  }

  void _onChildrenUpdated(GraphNodeChildrenUpdated event, Emitter<GraphNodeState<T, Data>> emit) {
    final loadedState = state as ParentNodeLoaded;
    final List<ChildNodeBloc> childBlocs = synchronizeChildNodeBlocs(
      newChildNodes: event.children,
      existingChildNodeBlocs: loadedState.children,
      parent: this,
      childNodeBlocBuilder: childNodeBlocBuilder,
    );
    emit(loadedState.copyWith(children: childBlocs) as S);
  }

  @override
  Future<void> close() {
    childrenSubscription.cancel();
    for (final child in (state as S).children) {
      child.close();
    }
    return super.close();
  }
}

mixin ChildNodeBlocMixin<T extends ChildNode, Data, S extends GraphNodeLoaded<T, Data>>
    on GraphNodeBloc<T, Data, S> {
  @override
  RootNodeBloc get root => lineage.first as RootNodeBloc;
  TrunkNodeBloc get trunk => lineage[1] as TrunkNodeBloc;
  ParentNodeBloc get parent;

  @override
  late final List<GraphNodeBloc> lineage = _getLineage();

  List<GraphNodeBloc> _getLineage() {
    final ancestors = <GraphNodeBloc>[];
    GraphNodeBloc? current = this;
    while (current is ChildNodeBlocMixin) {
      ancestors.add(current);
      current = current.parent;
    }
    return ancestors.reversed.toList();
  }

  @override
  bool isAncestorOf(GraphNodeBloc other) => false;

  @override
  bool isDescendantOf(GraphNodeBloc other) {
    return other != this && lineage.contains(other);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChildNodeBlocMixin<T, Data, S> &&
        other.initialNode == initialNode &&
        other.parent == parent;
  }

  @override
  int get hashCode => initialNode.hashCode ^ parent.hashCode;
}

abstract class ChildNodeBloc<T extends ChildNode, Data, S extends GraphNodeLoaded<T, Data>>
    extends GraphNodeBloc<T, Data, S>
    with ChildNodeBlocMixin<T, Data, S> {
  ChildNodeBloc({
    required super.initialNode,
    required super.nodeStream,
    required super.dataStream,
    required this.parent,
  });

  @override
  final ParentNodeBloc parent;
}

abstract class ParentChildNodeBloc<
  T extends ParentChildNode,
  Data,
  S extends ParentNodeLoaded<T, Data>
>
    extends ParentNodeBloc<T, Data, S>
    with ChildNodeBlocMixin<T, Data, S> {
  ParentChildNodeBloc({
    required super.initialNode,
    required this.parent,
    required super.nodeStream,
    required super.dataStream,
    required super.childNodesStream,
    required super.childNodeBlocBuilder,
  });

  @override
  final ParentNodeBloc parent;
}
