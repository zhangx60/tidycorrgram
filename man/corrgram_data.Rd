\name{corrgram_data}
\alias{corrgram_data}
\title{Compute a tidy correlation matrix}
\usage{
corrgram_data(
  data,
  columns = NULL,
  method = c("pearson", "kendall", "spearman"),
  use = "pairwise.complete.obs",
  triangle = c("full", "lower", "upper"),
  diagonal = TRUE,
  reorder = c("none", "hclust", "alphabetical"),
  p_values = FALSE,
  adjust = c("none", "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr"),
  alpha = 0.05,
  exact = NULL
)
}
\arguments{
\item{data}{A data frame.}
\item{columns}{Optional column selection. Use \code{NULL} to select all numeric columns, a character vector of names, a numeric vector of positions, or a logical vector with length \code{ncol(data)}.}
\item{method}{Correlation method passed to \code{\link[stats:cor]{stats::cor()}} and \code{\link[stats:cor.test]{stats::cor.test()}}.}
\item{use}{Missing-value handling passed to \code{\link[stats:cor]{stats::cor()}}.}
\item{triangle}{Which part of the matrix to return: \code{"full"}, \code{"lower"}, or \code{"upper"}.}
\item{diagonal}{Should diagonal values be retained?}
\item{reorder}{Variable ordering. \code{"none"} preserves the selected column order, \code{"alphabetical"} sorts names, and \code{"hclust"} uses hierarchical clustering on \code{1 - abs(correlation)}.}
\item{p_values}{Should pairwise correlation p-values be computed?}
\item{adjust}{P-value adjustment method passed to \code{\link[stats:p.adjust]{stats::p.adjust()}}.}
\item{alpha}{Significance threshold used to create the \code{significant} column when \code{p_values = TRUE}.}
\item{exact}{Passed to \code{\link[stats:cor.test]{stats::cor.test()}} for rank-based methods. The default \code{NULL} lets R choose.}
}
\value{
A data frame with columns \code{var1}, \code{var2}, \code{r}, \code{abs_r}, \code{row}, and \code{col}. If \code{p_values = TRUE}, it also includes \code{p}, \code{p_adjusted}, and \code{significant}.
}
\description{
\code{corrgram_data()} selects numeric columns, computes pairwise correlations, and returns the matrix as a tidy data frame that is ready for \pkg{ggplot2}.
}
\examples{
corrgram_data(mtcars, columns = c("mpg", "disp", "hp", "wt"))
corrgram_data(mtcars, triangle = "lower", diagonal = FALSE)
}
