utils::globalVariables(c("abs_r", "label", "r", "var1", "var2"))

#' Compute a tidy correlation matrix
#'
#' `corrgram_data()` selects numeric columns, computes pairwise correlations,
#' and returns the matrix as a tidy data frame that is ready for `ggplot2`.
#'
#' @param data A data frame.
#' @param columns Optional column selection. Use `NULL` to select all numeric
#'   columns, a character vector of names, a numeric vector of positions, or a
#'   logical vector with length `ncol(data)`.
#' @param method Correlation method passed to [stats::cor()] and
#'   [stats::cor.test()].
#' @param use Missing-value handling passed to [stats::cor()].
#' @param triangle Which part of the matrix to return: `"full"`, `"lower"`, or
#'   `"upper"`.
#' @param diagonal Should diagonal values be retained?
#' @param reorder Variable ordering. `"none"` preserves the selected column
#'   order, `"alphabetical"` sorts names, and `"hclust"` uses hierarchical
#'   clustering on `1 - abs(correlation)`.
#' @param p_values Should pairwise correlation p-values be computed?
#' @param adjust P-value adjustment method passed to [stats::p.adjust()].
#' @param alpha Significance threshold used to create the `significant` column
#'   when `p_values = TRUE`.
#' @param exact Passed to [stats::cor.test()] for rank-based methods. The
#'   default `NULL` lets R choose.
#'
#' @return A data frame with columns `var1`, `var2`, `r`, `abs_r`, `row`, and
#'   `col`. If `p_values = TRUE`, it also includes `p`, `p_adjusted`, and
#'   `significant`.
#' @export
#'
#' @examples
#' corrgram_data(mtcars, columns = c("mpg", "disp", "hp", "wt"))
#' corrgram_data(mtcars, triangle = "lower", diagonal = FALSE)
corrgram_data <- function(data,
                          columns = NULL,
                          method = c("pearson", "kendall", "spearman"),
                          use = "pairwise.complete.obs",
                          triangle = c("full", "lower", "upper"),
                          diagonal = TRUE,
                          reorder = c("none", "hclust", "alphabetical"),
                          p_values = FALSE,
                          adjust = c("none", "holm", "hochberg", "hommel",
                                     "bonferroni", "BH", "BY", "fdr"),
                          alpha = 0.05,
                          exact = NULL) {
  method <- match.arg(method)
  triangle <- match.arg(triangle)
  reorder <- match.arg(reorder)
  adjust <- match.arg(adjust)

  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  if (!is.numeric(alpha) || length(alpha) != 1L || is.na(alpha) ||
      alpha < 0 || alpha > 1) {
    stop("`alpha` must be a single number between 0 and 1.", call. = FALSE)
  }

  selected <- select_corr_columns(data, columns)
  x <- data[selected]
  non_numeric <- names(x)[!vapply(x, is.numeric, logical(1))]
  if (length(non_numeric) > 0L) {
    stop(
      "`columns` must identify numeric columns only. Non-numeric columns: ",
      paste(non_numeric, collapse = ", "),
      call. = FALSE
    )
  }
  if (ncol(x) < 2L) {
    stop("At least two numeric columns are required.", call. = FALSE)
  }

  cor_mat <- stats::cor(x, use = use, method = method)
  vars <- order_corr_vars(cor_mat, reorder)
  cor_mat <- cor_mat[vars, vars, drop = FALSE]

  out <- matrix_to_tidy(cor_mat)
  out <- filter_triangle(out, triangle = triangle, diagonal = diagonal)

  if (p_values) {
    p_mat <- pairwise_cor_pvalues(x[vars], method = method, exact = exact)
    p_adjusted <- adjust_pvalue_matrix(p_mat, method = adjust)
    p_out <- matrix_to_tidy(p_mat, value = "p")
    p_adj_out <- matrix_to_tidy(p_adjusted, value = "p_adjusted")
    out$p <- p_out$p[match(pair_key(out), pair_key(p_out))]
    out$p_adjusted <- p_adj_out$p_adjusted[match(pair_key(out), pair_key(p_adj_out))]
    out$significant <- !is.na(out$p_adjusted) & out$p_adjusted <= alpha
  }

  out$var1 <- factor(out$var1, levels = vars)
  out$var2 <- factor(out$var2, levels = vars)
  attr(out, "variables") <- vars
  out
}

select_corr_columns <- function(data, columns) {
  if (is.null(columns)) {
    selected <- names(data)[vapply(data, is.numeric, logical(1))]
    if (length(selected) == 0L) {
      stop("`data` does not contain numeric columns.", call. = FALSE)
    }
    return(selected)
  }

  if (is.character(columns)) {
    missing <- setdiff(columns, names(data))
    if (length(missing) > 0L) {
      stop(
        "`columns` contains unknown column names: ",
        paste(missing, collapse = ", "),
        call. = FALSE
      )
    }
    return(columns)
  }

  if (is.numeric(columns)) {
    if (any(is.na(columns)) || any(columns < 1L) || any(columns > ncol(data))) {
      stop("Numeric `columns` must be valid column positions.", call. = FALSE)
    }
    return(names(data)[columns])
  }

  if (is.logical(columns)) {
    if (length(columns) != ncol(data)) {
      stop("Logical `columns` must have length `ncol(data)`.", call. = FALSE)
    }
    return(names(data)[columns])
  }

  stop(
    "`columns` must be NULL, character, numeric, or logical.",
    call. = FALSE
  )
}

order_corr_vars <- function(cor_mat, reorder) {
  vars <- colnames(cor_mat)
  if (identical(reorder, "none")) {
    return(vars)
  }
  if (identical(reorder, "alphabetical")) {
    return(sort(vars))
  }

  distance <- 1 - abs(cor_mat)
  distance[is.na(distance)] <- 1
  diag(distance) <- 0
  vars[stats::hclust(stats::as.dist(distance), method = "complete")$order]
}

matrix_to_tidy <- function(mat, value = "r") {
  vars <- rownames(mat)
  out <- expand.grid(
    var1 = vars,
    var2 = colnames(mat),
    stringsAsFactors = FALSE
  )
  out[[value]] <- as.vector(mat)
  out$row <- match(out$var1, vars)
  out$col <- match(out$var2, colnames(mat))
  if (identical(value, "r")) {
    out$abs_r <- abs(out$r)
  }
  out
}

filter_triangle <- function(data, triangle, diagonal) {
  keep <- rep(TRUE, nrow(data))
  if (identical(triangle, "lower")) {
    keep <- data$row >= data$col
  } else if (identical(triangle, "upper")) {
    keep <- data$row <= data$col
  }
  if (!diagonal) {
    keep <- keep & data$row != data$col
  }
  data[keep, , drop = FALSE]
}

pairwise_cor_pvalues <- function(data, method, exact = NULL) {
  vars <- names(data)
  p_mat <- matrix(NA_real_, length(vars), length(vars), dimnames = list(vars, vars))
  diag(p_mat) <- NA_real_

  for (i in seq_along(vars)) {
    for (j in seq_along(vars)) {
      if (i >= j) {
        next
      }
      complete <- stats::complete.cases(data[[i]], data[[j]])
      x <- data[[i]][complete]
      y <- data[[j]][complete]
      p_value <- safe_cor_test_pvalue(x, y, method = method, exact = exact)
      p_mat[i, j] <- p_value
      p_mat[j, i] <- p_value
    }
  }

  p_mat
}

safe_cor_test_pvalue <- function(x, y, method, exact) {
  if (length(x) < 3L || length(unique(x)) < 2L || length(unique(y)) < 2L) {
    return(NA_real_)
  }

  args <- list(x = x, y = y, method = method)
  if (!is.null(exact)) {
    args$exact <- exact
  }

  result <- tryCatch(
    do.call(stats::cor.test, args),
    error = function(e) NULL,
    warning = function(w) suppressWarnings(do.call(stats::cor.test, args))
  )

  if (is.null(result)) {
    NA_real_
  } else {
    result$p.value
  }
}

adjust_pvalue_matrix <- function(p_mat, method) {
  if (identical(method, "none")) {
    return(p_mat)
  }

  adjusted <- p_mat
  upper <- upper.tri(p_mat)
  adjusted_values <- stats::p.adjust(p_mat[upper], method = method)
  adjusted[upper] <- adjusted_values
  adjusted[lower.tri(adjusted)] <- t(adjusted)[lower.tri(adjusted)]
  diag(adjusted) <- NA_real_
  adjusted
}

pair_key <- function(data) {
  paste(data$var1, data$var2, sep = "\r")
}
