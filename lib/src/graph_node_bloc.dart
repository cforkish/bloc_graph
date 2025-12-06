import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'graph_node.dart';

part 'branch_node_bloc.dart';
part 'graph_node_events.dart';
part 'graph_node_state.dart';
part 'leaf_node_bloc.dart';
part 'parent_child_blocs.dart';
part 'root_node_bloc.dart';
part 'trunk_node_bloc.dart';
part 'util.dart';

abstract class GraphNodeBloc<T extends GraphNode, Data, S extends GraphNodeLoaded<T, Data>>
    extends Bloc<GraphNodeEvent, GraphNodeState<T, Data>> {
  GraphNodeBloc({required this.initialNode}) : super(GraphNodeInitial(node: initialNode)) {
    on<GraphNodeLoadRequested>(_load);
    on<GraphNodeReloadRequested>(_reload);
    on<GraphNodeNodeUpdated>(_onNodeUpdated);
    on<GraphNodeDataUpdated>(_onDataUpdated);
  }

  final T initialNode;
  @protected
  Stream<T?> get nodeStream;
  @protected
  Stream<Data?> get dataStream;

  @protected
  List<Stream<dynamic>> get subStreams => [nodeStream, dataStream];

  RootNodeBloc get root;
  bool get isLoaded => state is GraphNodeLoaded;

  Future<void> awaitLoaded() async {
    if (state is GraphNodeLoaded) return;
    await stream.firstWhere((s) => s is GraphNodeLoaded);
  }

  /// List of ancestors plus self, reversed to start with root
  List<GraphNodeBloc> get lineage;

  bool isAncestorOf(GraphNodeBloc other) {
    return other != this && other.lineage.contains(this);
  }

  bool isDescendantOf(GraphNodeBloc other) {
    return other != this && lineage.contains(other);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GraphNodeBloc<T, Data, S> && other.initialNode == initialNode;
  }

  @override
  int get hashCode => initialNode.hashCode;

  @override
  void add(GraphNodeEvent event) {
    // Filter extraneous load requests
    if (event is GraphNodeLoadRequested && state is! GraphNodeInitial) {
      return;
    }
    super.add(event);
  }

  // Subscriptions
  @protected
  late final StreamSubscription<T?> nodeSubscription;
  @protected
  late final StreamSubscription<Data?> dataSubscription;

  S loadedStateFromCombinedSnapshot<C extends NodeDataSnapshot<T, Data>>(C snapshot);

  NodeDataSnapshot<T, Data> combinedStreamsSnapshot(List<dynamic> substreamSnapshots) {
    return NodeDataSnapshot<T, Data>(
      node: substreamSnapshots[0] as T,
      data: substreamSnapshots[1] as Data,
    );
  }

  Future<void> _load(
    GraphNodeEvent event,
    Emitter<GraphNodeState<T, Data>> emit, {
    bool reload = false,
  }) async {
    if (state is! GraphNodeInitial) {
      return;
    }
    emit(GraphNodeLoading(node: initialNode));

    final List<dynamic> data = await CombineLatestStream.list(subStreams).first;
    emit(loadedStateFromCombinedSnapshot(combinedStreamsSnapshot(data)));
    subscribeToSubStreams();
  }

  Future<void> _reload(GraphNodeEvent event, Emitter<GraphNodeState<T, Data>> emit) async {
    _load(event, emit, reload: true);
  }

  void subscribeToSubStreams() {
    nodeSubscription = nodeStream.listen((node) {
      if (node == null || node == (state as GraphNodeLoaded).node) {
        return;
      }
      add(GraphNodeNodeUpdated(node));
    });
    dataSubscription = dataStream.listen((data) {
      if (data == null || data == (state as GraphNodeLoaded).data) {
        return;
      }
      add(GraphNodeDataUpdated(data));
    });
  }

  void _onNodeUpdated(GraphNodeNodeUpdated event, Emitter<GraphNodeState<T, Data>> emit) {
    final loadedState = state as GraphNodeLoaded;
    emit(loadedState.copyWith(node: event.node) as GraphNodeLoaded<T, Data>);
  }

  void _onDataUpdated(GraphNodeDataUpdated event, Emitter<GraphNodeState<T, Data>> emit) {
    final loadedState = state as GraphNodeLoaded;
    emit(loadedState.copyWith(data: event.data) as GraphNodeLoaded<T, Data>);
  }

  @override
  Future<void> close() {
    nodeSubscription.cancel();
    dataSubscription.cancel();
    return super.close();
  }
}
