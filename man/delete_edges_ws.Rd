% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/delete_edges_ws.R
\name{delete_edges_ws}
\alias{delete_edges_ws}
\title{Delete all selected edges in an edge selection}
\usage{
delete_edges_ws(graph)
}
\arguments{
\item{graph}{A graph object of class \code{dgr_graph}.}
}
\value{
A graph object of class \code{dgr_graph}.
}
\description{
In a graph object of class \code{dgr_graph}, delete all edges present in a
selection.

This function makes use of an active selection of edges (and the function
ending with \verb{_ws} hints at this).

Selections of edges can be performed using the following selection
(\verb{select_*()}) functions: \code{\link[=select_edges]{select_edges()}}, \code{\link[=select_last_edges_created]{select_last_edges_created()}},
\code{\link[=select_edges_by_edge_id]{select_edges_by_edge_id()}}, or \code{\link[=select_edges_by_node_id]{select_edges_by_node_id()}}.

Selections of edges can also be performed using the following traversal
(\verb{trav_*()}) functions: \code{\link[=trav_out_edge]{trav_out_edge()}}, \code{\link[=trav_in_edge]{trav_in_edge()}},
\code{\link[=trav_both_edge]{trav_both_edge()}}, or \code{\link[=trav_reverse_edge]{trav_reverse_edge()}}.
}
\examples{
# Create a graph
graph <-
  create_graph() \%>\%
  add_n_nodes(n = 3) \%>\%
  add_edges_w_string(
    edges = "1->3 1->2 2->3")

# Select edges attached to
# node with ID `3` (these are
# `1`->`3` and `2`->`3`)
graph <-
  graph \%>\%
  select_edges_by_node_id(nodes = 3)

# Delete edges in selection
graph <-
  graph \%>\%
  delete_edges_ws()

# Get a count of edges in the graph
graph \%>\% count_edges()

}
\seealso{
Other Edge creation and removal: 
\code{\link{add_edge_clone}()},
\code{\link{add_edge_df}()},
\code{\link{add_edges_from_table}()},
\code{\link{add_edges_w_string}()},
\code{\link{add_edge}()},
\code{\link{add_forward_edges_ws}()},
\code{\link{add_reverse_edges_ws}()},
\code{\link{copy_edge_attrs}()},
\code{\link{create_edge_df}()},
\code{\link{delete_edge}()},
\code{\link{delete_loop_edges_ws}()},
\code{\link{drop_edge_attrs}()},
\code{\link{edge_data}()},
\code{\link{join_edge_attrs}()},
\code{\link{mutate_edge_attrs_ws}()},
\code{\link{mutate_edge_attrs}()},
\code{\link{recode_edge_attrs}()},
\code{\link{rename_edge_attrs}()},
\code{\link{rescale_edge_attrs}()},
\code{\link{rev_edge_dir_ws}()},
\code{\link{rev_edge_dir}()},
\code{\link{set_edge_attr_to_display}()},
\code{\link{set_edge_attrs_ws}()},
\code{\link{set_edge_attrs}()}
}
\concept{Edge creation and removal}
