#' Count secondary infections
#'
#' Count the direct secondary infections caused by each infected individual,
#' including those with no offspring.
#'
#' @param x An object of class `nososim_outbreak`.
#' @return A tibble with `labels` and `offspring` counts.
#' @export
offspring <- function(x) {
  infections <- x$infections

  tibble::tibble(
    labels = infections$to,
    offspring = tabulate(
      match(infections$from, infections$to),
      nbins = nrow(infections)
    )
  )
}
