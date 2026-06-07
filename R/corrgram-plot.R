#' Create a correlogram
#'
#' `corrgram()` computes correlations and returns a `ggplot2` correlogram.
#'
#' @inheritParams corrgram_data
#' @param geom Plot style. `"tile"` uses colored squares, `"point"` uses sized
#'   circles, and `"mixed"` combines both.
#' @param labels Should correlation values be drawn as text?
#' @param label_digits Number of digits for text labels.
#' @param palette A named color vector with `low`, `mid`, and `high` values.
#' @param significant_only If `TRUE`, non-significant off-diagonal cells are
#'   removed using adjusted p-values and `alpha`. This sets `p_values = TRUE`.
#'
#' @return A `ggplot2` object.
#' @export
#'
#' @examples
#' corrgram(mtcars, columns = c("mpg", "disp", "hp", "wt"))
#' corrgram(mtcars, geom = "point", triangle = "upper", diagonal = FALSE)
corrgram <- function(data,
                     columns = NULL,
                     method = c("pearson", "kendall", "spearman"),
                     use = "pairwise.complete.obs",
                     triangle = c("lower", "full", "upper"),
                     diagonal = TRUE,
                     reorder = c("hclust", "none", "alphabetical"),
                     p_values = FALSE,
                     adjust = c("none", "holm", "hochberg", "hommel",
                                "bonferroni", "BH", "BY", "fdr"),
                     alpha = 0.05,
                     exact = NULL,
                     geom = c("tile", "point", "mixed"),
                     labels = FALSE,
                     label_digits = 2,
                     palette = corrgram_palette(),
                     significant_only = FALSE) {
  method <- match.arg(method)
  triangle <- match.arg(triangle)
  reorder <- match.arg(reorder)
  adjust <- match.arg(adjust)
  geom <- match.arg(geom)
  validate_palette(palette)

  plot_data <- corrgram_data(
    data = data,
    columns = columns,
    method = method,
    use = use,
    triangle = triangle,
    diagonal = diagonal,
    reorder = reorder,
    p_values = p_values || significant_only,
    adjust = adjust,
    alpha = alpha,
    exact = exact
  )

  vars <- attr(plot_data, "variables", exact = TRUE)
  if (significant_only) {
    diagonal_cells <- plot_data$row == plot_data$col
    plot_data <- plot_data[diagonal_cells | plot_data$significant, , drop = FALSE]
  }
  plot_data$var1 <- factor(as.character(plot_data$var1), levels = rev(vars))
  plot_data$var2 <- factor(as.character(plot_data$var2), levels = vars)

  p <- ggplot2::ggplot(plot_data, ggplot2::aes(var2, var1))

  if (geom %in% c("tile", "mixed")) {
    p <- p +
      ggplot2::geom_tile(ggplot2::aes(fill = r), color = "white", linewidth = 0.4) +
      ggplot2::scale_fill_gradient2(
        low = unname(palette[["low"]]),
        mid = unname(palette[["mid"]]),
        high = unname(palette[["high"]]),
        midpoint = 0,
        limits = c(-1, 1),
        name = "Correlation"
      )
  }

  if (geom %in% c("point", "mixed")) {
    p <- p +
      ggplot2::geom_point(
        ggplot2::aes(size = abs_r, color = r),
        alpha = 0.9
      ) +
      ggplot2::scale_size_continuous(
        limits = c(0, 1),
        range = c(1, 9),
        name = "|Correlation|"
      ) +
      ggplot2::scale_color_gradient2(
        low = unname(palette[["low"]]),
        mid = unname(palette[["mid"]]),
        high = unname(palette[["high"]]),
        midpoint = 0,
        limits = c(-1, 1),
        name = "Correlation"
      )
  }

  if (labels) {
    plot_data$label <- formatC(plot_data$r, format = "f", digits = label_digits)
    p <- p +
      ggplot2::geom_text(
        data = plot_data,
        ggplot2::aes(label = label),
        size = 3,
        color = "grey15"
      )
  }

  p +
    ggplot2::coord_equal() +
    ggplot2::labs(x = NULL, y = NULL) +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(
      panel.grid = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
      axis.text.y = ggplot2::element_text(hjust = 1)
    )
}

#' Create a diverging correlogram palette
#'
#' @param low Color used for correlations near -1.
#' @param mid Color used for correlations near 0.
#' @param high Color used for correlations near 1.
#'
#' @return A named character vector with `low`, `mid`, and `high`.
#' @export
#'
#' @examples
#' corrgram_palette()
#' corrgram_palette(low = "#2166AC", mid = "white", high = "#B2182B")
corrgram_palette <- function(low = "#3B4CC0",
                             mid = "#F7F7F7",
                             high = "#B40426") {
  colors <- c(low = low, mid = mid, high = high)
  validate_palette(colors)
  colors
}

validate_palette <- function(palette) {
  if (!is.character(palette) || length(palette) != 3L ||
      !all(c("low", "mid", "high") %in% names(palette))) {
    stop(
      "`palette` must be a named character vector with low, mid, and high.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}
