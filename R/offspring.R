#' Count secondary infections
#'
#' Count the direct secondary infections caused by each infected individual,
#' including those with no offspring.
#'
#' @param x An object of class `nososim_outbreak`.
#' @return A tibble with `id` and `offspring` counts.
#' @export
offspring <- function(x) {
  stopifnot(inherits(x, "nososim_outbreak"))

  infections <- x$infections

  tibble::tibble(
    id = infections$id,
    offspring = tabulate(
      match(infections$source, infections$id),
      nbins = nrow(infections)
    )
  )
}
