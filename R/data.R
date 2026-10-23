#' Example nosocomial outbreak
#'
#' A simulated outbreak in a population of 40 people over 21 days, with ward
#' and role attributes, one imported case, and no intervention. Generated with
#' seed 123 by `inst/examples/outbreak.R`.
#'
#' @format A `nososim_outbreak` list with population `timeline`, `infections`,
#'   simulation `dates`, and `parameters`.
#' @examples
#' summary(outbreak)
#' count_edges(outbreak, by = "ward")
"outbreak"
