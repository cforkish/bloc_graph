part of 'graph_node_bloc.dart';

sealed class GraphNodeState<T extends GraphNode, Data> extends Equatable {
  const GraphNodeState({required this.node});
  final T node;

  @override
  List<Object?> get props => [node];
}

final class GraphNodeInitial<T extends GraphNode, Data> extends GraphNodeState<T, Data> {
  const GraphNodeInitial({required super.node});
}

final class GraphNodeLoading<T extends GraphNode, Data> extends GraphNodeState<T, Data> {
  const GraphNodeLoading({required super.node});
}

abstract class GraphNodeLoaded<T extends GraphNode, Data> extends GraphNodeState<T, Data> {
  const GraphNodeLoaded({required super.node, required this.data});

  final Data data;

  @mustBeOverridden
  GraphNodeState<T, Data> copyWith({T? node, Data? data});

  @override
  List<Object?> get props => [node, data];
}

abstract class ParentNodeLoaded<T extends ParentNode, Data> extends GraphNodeLoaded<T, Data> {
  const ParentNodeLoaded({required super.node, required super.data, required this.children});

  final List<ChildNodeBloc> children;

  @override
  ParentNodeLoaded<T, Data> copyWith({T? node, Data? data, List<ChildNodeBloc>? children});

  @override
  List<Object?> get props => [...super.props, children];
}

final class GraphNodeError<T extends GraphNode, Data> extends GraphNodeState<T, Data> {
  const GraphNodeError({required super.node, required this.error});
  final Object error;

  @override
  List<Object?> get props => [node, error];
}
