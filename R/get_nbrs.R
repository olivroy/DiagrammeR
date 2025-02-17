#' Get all neighbors of one or more nodes
#'
#' @description
#'
#' With one or more nodes, get the set of all neighboring nodes.
#'
#' @inheritParams render_graph
#' @param nodes A vector of node ID values.
#'
#' @return A vector of node ID values.
#'
#' @examples
#' # Create a simple, directed graph with 5
#' # nodes and 4 edges
#' graph <-
#'   create_graph() %>%
#'   add_path(n = 5)
#'
#' # Find all neighbor nodes for node `2`
#' graph %>% get_nbrs(nodes = 2)
#'
#' # Find all neighbor nodes for nodes `1`
#' # and `5`
#' graph %>% get_nbrs(nodes = c(1, 5))
#'
#' # Color node `3` with purple, get its
#' # neighbors and color those nodes green
#' graph <-
#'   graph %>%
#'   select_nodes_by_id(nodes = 3) %>%
#'   set_node_attrs_ws(
#'     node_attr = color,
#'     value = "purple") %>%
#'   clear_selection() %>%
#'   select_nodes_by_id(
#'     nodes = get_nbrs(
#'       graph = .,
#'       nodes = 3)) %>%
#'   set_node_attrs_ws(
#'     node_attr = color,
#'     value = "green")
#'
#' @export
get_nbrs <- function(
    graph,
    nodes
) {

  # Get the name of the function
  fcn_name <- get_calling_fcn()

  # Validation: Graph object is valid
  if (graph_object_valid(graph) == FALSE) {

    emit_error(
      fcn_name = fcn_name,
      reasons = "The graph object is not valid")
  }

  # Get predecessors and successors for all nodes
  # in `nodes`
  for (i in 1:length(nodes)) {
    if (i == 1) {
      node_nbrs <- vector(mode = 'numeric')
    }
    node_nbrs <-
      c(node_nbrs,
        c(get_predecessors(graph, node = nodes[i]),
          get_successors(graph, node = nodes[i])))
  }

  # Get a unique set of node ID values
  node_nbrs <- sort(unique(node_nbrs))

  # If there are no neighbors, then return NA
  if (length(node_nbrs) == 0) {
    return(NA)
  } else {
    return(node_nbrs)
  }
}
