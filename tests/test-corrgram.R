library(tidycorrgram)

tbl <- corrgram_data(
  mtcars,
  columns = c("mpg", "disp", "hp", "wt"),
  triangle = "lower",
  diagonal = FALSE
)

stopifnot(is.data.frame(tbl))
stopifnot(identical(names(tbl), c("var1", "var2", "r", "row", "col", "abs_r")))
stopifnot(nrow(tbl) == 6L)
stopifnot(all(tbl$abs_r >= 0, na.rm = TRUE))
stopifnot(all(tbl$abs_r <= 1, na.rm = TRUE))

tbl_p <- corrgram_data(
  mtcars,
  columns = c("mpg", "disp", "hp", "wt"),
  p_values = TRUE,
  adjust = "BH"
)

stopifnot(all(c("p", "p_adjusted", "significant") %in% names(tbl_p)))
stopifnot(is.logical(tbl_p$significant))

pal <- corrgram_palette()
stopifnot(identical(names(pal), c("low", "mid", "high")))

p <- corrgram(mtcars, columns = c("mpg", "disp", "hp", "wt"))
stopifnot(inherits(p, "ggplot"))

err <- try(corrgram_data(data.frame(a = letters[1:3], b = LETTERS[1:3])), silent = TRUE)
stopifnot(inherits(err, "try-error"))
