part of 'graph_node_bloc.dart';

abstract class GraphNodeEvent {
  const GraphNodeEvent();
}

class GraphNodeLoadRequested extends GraphNodeEvent {
  const GraphNodeLoadRequested();
}

class GraphNodeReloadRequested extends GraphNodeEvent {
  const GraphNodeReloadRequested();
}

class GraphNodeNodeUpdated<T extends GraphNode> extends GraphNodeEvent {
  const GraphNodeNodeUpdated(this.node);
  final T node;
}

class GraphNodeChildrenUpdated extends GraphNodeEvent {
  const GraphNodeChildrenUpdated(this.children);
  final List<ChildNode> children;
}

class GraphNodeDataUpdated<Data> extends GraphNodeEvent {
  const GraphNodeDataUpdated(this.data);
  final Data data;
}
