#' Example nosocomial outbreak
#'
#' A simulated outbreak in a population of 40 people over 21 days, with ward
#' and role attributes, per-contact transmission rates, one imported case,
#' and no intervention. Generated with
#' seed 123 by `inst/examples/outbreak.R`.
#'
#' @format A `nososim_outbreak` list with `population`, `infections`,
#'   `reproduction`, simulation `dates`, and `parameters`.
#' @examples
#' outbreak$infections
#' count_edges(outbreak, by = "ward")
"outbreak"
