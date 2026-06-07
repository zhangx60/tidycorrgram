\name{corrgram}
\alias{corrgram}
\title{Create a correlogram}
\usage{
corrgram(
  data,
  columns = NULL,
  method = c("pearson", "kendall", "spearman"),
  use = "pairwise.complete.obs",
  triangle = c("lower", "full", "upper"),
  diagonal = TRUE,
  reorder = c("hclust", "none", "alphabetical"),
  p_values = FALSE,
  adjust = c("none", "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr"),
  alpha = 0.05,
  exact = NULL,
  geom = c("tile", "point", "mixed"),
  labels = FALSE,
  label_digits = 2,
  palette = corrgram_palette(),
  significant_only = FALSE
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
\item{geom}{Plot style. \code{"tile"} uses colored squares, \code{"point"} uses sized circles, and \code{"mixed"} combines both.}
\item{labels}{Should correlation values be drawn as text?}
\item{label_digits}{Number of digits for text labels.}
\item{palette}{A named color vector with \code{low}, \code{mid}, and \code{high} values.}
\item{significant_only}{If \code{TRUE}, non-significant off-diagonal cells are removed using adjusted p-values and \code{alpha}. This sets \code{p_values = TRUE}.}
}
\value{
A \pkg{ggplot2} object.
}
\description{
\code{corrgram()} computes correlations and returns a \pkg{ggplot2} correlogram.
}
\examples{
corrgram(mtcars, columns = c("mpg", "disp", "hp", "wt"))
corrgram(mtcars, geom = "point", triangle = "upper", diagonal = FALSE)
}
\seealso{
\code{\link{corrgram_data}}, \code{\link{corrgram_palette}}
}
