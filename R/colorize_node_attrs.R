#' Apply colors based on node attribute values
#'
#' @description
#'
#' Within a graph's internal node data frame (ndf), use a categorical node
#' attribute to generate a new node attribute with color values.
#'
#' @inheritParams render_graph
#' @param node_attr_from The name of the node attribute column from which color
#'   values will be based.
#' @param node_attr_to The name of the new node attribute to which the color
#'   values will be applied.
#' @param cut_points An optional vector of numerical breaks for bucketizing
#'   continuous numerical values available in a edge attribute column.
#' @param palette Can either be: (1) a palette name from the RColorBrewer
#'   package (e.g., `Greens`, `OrRd`, `RdYlGn`), (2) `viridis`, which indicates
#'   use of the `viridis` color scale from the package of the same name, or (3)
#'   a vector of hexadecimal color names.
#' @param alpha An optional alpha transparency value to apply to the generated
#'   colors. Should be in the range of `0` (completely transparent) to `100`
#'   (completely opaque).
#' @param reverse_palette An option to reverse the order of colors in the chosen
#'   palette. The default is `FALSE`.
#' @param default_color A hexadecimal color value to use for instances when the
#'   values do not fall into the bucket ranges specified in the `cut_points`
#'   vector.
#'
#' @return A graph object of class `dgr_graph`.
#'
#' @examples
#' # Create a graph with 8
#' # nodes and 7 edges
#' graph <-
#'   create_graph() %>%
#'   add_path(n = 8) %>%
#'   set_node_attrs(
#'     node_attr = weight,
#'     values = c(
#'       8.2, 3.7, 6.3, 9.2,
#'       1.6, 2.5, 7.2, 5.4))
#'
#' # Find group membership values for all nodes
#' # in the graph through the Walktrap community
#' # finding algorithm and join those group values
#' # to the graph's internal node data frame (ndf)
#' # with the `join_node_attrs()` function
#' graph <-
#'   graph %>%
#'   join_node_attrs(
#'     df = get_cmty_walktrap(.))
#'
#' # Inspect the number of distinct communities
#' graph %>%
#'   get_node_attrs(
#'     node_attr = walktrap_group) %>%
#'   unique() %>%
#'   sort()
#'
#' # Visually distinguish the nodes in the different
#' # communities by applying colors using the
#' # `colorize_node_attrs()` function; specifically,
#' # set different `fillcolor` values with an alpha
#' # value of 90 and apply opaque colors to the node
#' # border (with the `color` node attribute)
#' graph <-
#'   graph %>%
#'   colorize_node_attrs(
#'     node_attr_from = walktrap_group,
#'     node_attr_to = fillcolor,
#'     palette = "Greens",
#'     alpha = 90) %>%
#'   colorize_node_attrs(
#'     node_attr_from = walktrap_group,
#'     node_attr_to = color,
#'     palette = "viridis",
#'     alpha = 80)
#'
#' # Show the graph's internal node data frame
#' graph %>% get_node_df()
#'
#' # Create a graph with 8 nodes and 7 edges
#' graph <-
#'   create_graph() %>%
#'   add_path(n = 8) %>%
#'   set_node_attrs(
#'     node_attr = weight,
#'     values = c(
#'       8.2, 3.7, 6.3, 9.2,
#'       1.6, 2.5, 7.2, 5.4))
#'
#' # We can bucketize values in `weight` using
#' # `cut_points` and assign colors to each of the
#' # bucketed ranges (for values not part of any
#' # bucket, a gray color is assigned by default)
#' graph <-
#'   graph %>%
#'   colorize_node_attrs(
#'     node_attr_from = weight,
#'     node_attr_to = fillcolor,
#'     cut_points = c(1, 3, 5, 7, 9))
#'
#' # Now there will be a `fillcolor` node attribute
#' # with distinct colors (the `#D9D9D9` color is
#' # the default `gray85` color)
#' graph %>% get_node_df()
#'
#' @import RColorBrewer
#' @import rlang
#' @family Node creation and removal
#' @export
colorize_node_attrs <- function(
    graph,
    node_attr_from,
    node_attr_to,
    cut_points = NULL,
    palette = "Spectral",
    alpha = NULL,
    reverse_palette = FALSE,
    default_color = "#D9D9D9"
) {

  # Get the time of function start
  time_function_start <- Sys.time()

  # Get the name of the function
  fcn_name <- get_calling_fcn()

  # Validation: Graph object is valid
  if (graph_object_valid(graph) == FALSE) {

    emit_error(
      fcn_name = fcn_name,
      reasons = "The graph object is not valid")
  }

  # Get the requested `node_attr_from`
  node_attr_from <-
    rlang::enquo(node_attr_from) %>% rlang::get_expr() %>% as.character()

  # Get the requested `node_attr_to`
  node_attr_to <-
    rlang::enquo(node_attr_to) %>% rlang::get_expr() %>% as.character()

  # Extract ndf from graph
  nodes_df <- graph$nodes_df

  # Get the column number in the ndf from which to
  # recode values
  col_to_recode_no <-
    which(colnames(nodes_df) %in% node_attr_from)

  # Get the number of recoded values
  if (is.null(cut_points)) {
    num_recodings <-
      nrow(unique(nodes_df[col_to_recode_no]))
  } else if (!is.null(cut_points)) {
    num_recodings <- length(cut_points) - 1
  }

  # Handle vector of hexadecimal or named colors
  if (length(palette) > 1) {
    # Verify colors are valid
    is_valid_hex <- grepl(toupper(palette), pattern = "#[0-9A-F]{6}")
    if (!all(is_valid_hex)) {
      emit_error(fcn_name = fcn_name,
                 reasons = "The color palette contains invalid hexadecimal values.")
    }
    if (length(palette) < num_recodings) {
      # Revert to viridis if provided color vector is too short
      palette <- "viridis"
    } else {
      color_palette <- toupper(palette)[1:num_recodings]
    }
  }

  # Handle viridis and ColorBrewer palette name input
  if (length(palette) == 1) {
    # If the number of recodings lower than any Color
    # Brewer palette, shift palette to `viridis`
    if ((num_recodings < 3 | num_recodings > 10) & palette %in%
        c(row.names(RColorBrewer::brewer.pal.info))) {
      palette <- "viridis"
    }

    # or any of the RColorBrewer palettes
    if (!(palette %in% c(row.names(RColorBrewer::brewer.pal.info),
                         "viridis"))) {
      emit_error(
        fcn_name = fcn_name,
        reasons = "The color palette is not an `RColorBrewer` or `viridis` palette")
    }

    # Obtain a color palette
    if (palette %in% row.names(RColorBrewer::brewer.pal.info)) {
      color_palette <- RColorBrewer::brewer.pal(num_recodings, palette)
    } else if (palette == "viridis") {
      color_palette <- viridis::viridis(num_recodings)
      color_palette <- gsub("..$", "", color_palette)
    }
  }

  # Reverse color palette if `reverse_palette = TRUE`
  if (reverse_palette == TRUE) {
    color_palette <- rev(color_palette)
  }

  # Create a data frame with initial values
  new_node_attr_col <-
    data.frame(
      node_attr_to = rep(default_color, nrow(nodes_df)),
      stringsAsFactors = FALSE)

  # Get the column number for the new node attribute
  to_node_attr_colnum <- ncol(nodes_df) + 1

  # Bind the current ndf with the new column
  nodes_df <- cbind(nodes_df, new_node_attr_col)

  # Rename the new column with the target node attr name
  colnames(nodes_df)[to_node_attr_colnum] <- node_attr_to

  # Get a data frame of recodings
  if (is.null(cut_points)) {

    recode_df <-
      data.frame(
        to_recode = names(table(nodes_df[, col_to_recode_no])),
        colors = color_palette,
        stringsAsFactors = FALSE)

    # Recode rows in the new node attribute
    for (i in seq_along(names(table(nodes_df[, col_to_recode_no])))) {

      recode_rows <-
        which(nodes_df[, col_to_recode_no] %in%
                recode_df[i, 1])

      if (is.null(alpha)) {
        nodes_df[recode_rows, to_node_attr_colnum] <-
          color_palette[i]
      } else if (!is.null(alpha)) {
        if (alpha < 100) {
          nodes_df[recode_rows, to_node_attr_colnum] <-
            gsub("$", alpha, color_palette[i])
        } else if (alpha == 100) {
          nodes_df[recode_rows, to_node_attr_colnum] <-
            gsub("$", "", color_palette[i])
        }
      }
    }
  }

  # Recode according to provided cut points
  if (!is.null(cut_points)) {
    for (i in 1:(length(cut_points) - 1)) {
      recode_rows <-
        which(
          as.numeric(nodes_df[, col_to_recode_no]) >=
            cut_points[i] &
            as.numeric(nodes_df[, col_to_recode_no]) <
            cut_points[i + 1])

      nodes_df[recode_rows, to_node_attr_colnum] <-
        color_palette[i]
    }

    if (!is.null(alpha)) {
      if (alpha < 100) {
        nodes_df[, to_node_attr_colnum] <-
          gsub("$", alpha, nodes_df[, to_node_attr_colnum])
      } else if (alpha == 100) {
        nodes_df[, to_node_attr_colnum] <-
          gsub("$", "", nodes_df[, to_node_attr_colnum])
      }
    }
  }

  # Get the finalized column of values
  nodes_attr_vector_colorized <- nodes_df[, ncol(nodes_df)]

  node_attr_to_2 <- rlang::enquo(node_attr_to)

  # Set the node attribute values for nodes specified
  # in selection
  graph <-
    set_node_attrs(
      graph = graph,
      node_attr = !!node_attr_to_2,
      values = nodes_attr_vector_colorized
    )

  # Remove last action from the `graph_log`
  graph$graph_log <- graph$graph_log[1:(nrow(graph$graph_log) - 1), ]

  # Update the `graph_log` df with an action
  graph$graph_log <-
    add_action_to_log(
      graph_log = graph$graph_log,
      version_id = nrow(graph$graph_log) + 1,
      function_used = fcn_name,
      time_modified = time_function_start,
      duration = graph_function_duration(time_function_start),
      nodes = nrow(graph$nodes_df),
      edges = nrow(graph$edges_df))

  # Write graph backup if the option is set
  if (graph$graph_info$write_backups) {
    save_graph_as_rds(graph = graph)
  }

  graph
}
