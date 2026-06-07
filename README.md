# tidycorrgram

`tidycorrgram` turns numeric data into tidy correlation tables and
`ggplot2` correlograms.

The package is meant for the common teaching and exploratory analysis workflow:
choose numeric variables, compute pairwise correlations, optionally compute
p-values, reorder the matrix, and draw a tile, point, or mixed correlogram.

## Installation

```r
install.packages("tidycorrgram")
```

During development, install from a local checkout:

```r
install.packages("tidycorrgram", repos = NULL, type = "source")
```

## Example

```r
library(tidycorrgram)

corrgram_data(mtcars, columns = c("mpg", "disp", "hp", "wt"))

corrgram(
  mtcars,
  columns = c("mpg", "disp", "hp", "wt"),
  geom = "mixed",
  reorder = "hclust",
  p_values = TRUE
)
```

## Why this package?

Baseline `ggplot2` can draw a correlogram once correlations have already been
computed and reshaped. `tidycorrgram` provides that missing glue in a small,
teachable API while still returning ordinary data frames and `ggplot2` objects.
