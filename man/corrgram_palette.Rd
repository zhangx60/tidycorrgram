\name{corrgram_palette}
\alias{corrgram_palette}
\title{Create a diverging correlogram palette}
\usage{
corrgram_palette(low = "#3B4CC0", mid = "#F7F7F7", high = "#B40426")
}
\arguments{
\item{low}{Color used for correlations near -1.}
\item{mid}{Color used for correlations near 0.}
\item{high}{Color used for correlations near 1.}
}
\value{
A named character vector with \code{low}, \code{mid}, and \code{high}.
}
\description{
Create a reusable three-color diverging palette for \code{\link{corrgram}}.
}
\examples{
corrgram_palette()
corrgram_palette(low = "#2166AC", mid = "white", high = "#B2182B")
}
