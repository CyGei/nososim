#' Summarise a population timeline
#'
#' @param object A timeline created by [make_timeline()].
#' @param ... Unused.
#'
#' @return A tibble with the number of individuals and person-days,
#'   overall and by attribute value. Individuals may be counted in
#'   multiple groups if their attributes change over time.
#'
#' @export
#' @examples
#' timeline <- make_timeline(10, as.Date("2026-01-01") + 0:6,
#'   attributes = list(ward = c(A = 1, B = 1))
#' )
#' summary(timeline)
summary.nososim_timeline <- function(object, ...) {
  rlang::check_dots_empty()
  data <- tibble::as_tibble(object)
  total <- tibble(
    attribute = NA_character_, value = NA_character_,
    individuals = dplyr::n_distinct(data$id), person_days = nrow(data)
  )
  attributes <- setdiff(names(data), c("id", "date", "R_i"))
  groups <- lapply(attributes, function(column) {
    tibble(id = data$id, value = as.character(data[[column]])) |>
      dplyr::summarise(
        individuals = dplyr::n_distinct(.data$id), person_days = n(),
        .by = "value"
      ) |>
      mutate(attribute = column, .before = 1)
  })
  bind_rows(total, bind_rows(groups))
}


#' Summarise an outbreak
#'
#' @param object An outbreak created by [make_outbreak()].
#' @param ... Unused.
#'
#' @return A one-row tibble with population size, simulation duration,
#'   initial and secondary case counts, total cases, and the first and
#'   last infection dates. Case counts include infections outside the
#'   simulation period.
#'
#' @export
#' @seealso [make_outbreak()]
summary.nososim_outbreak <- function(object, ...) {
  rlang::check_dots_empty()
  infections <- object$infections
  present <- object$timeline$id[object$timeline$date %in% object$dates]
  dates <- infections$date_infection
  tibble(
    individuals = dplyr::n_distinct(present),
    simulation_days = dplyr::n_distinct(object$dates),
    initial_cases = sum(is.na(infections$source)),
    secondary_cases = sum(!is.na(infections$source)),
    total_cases = nrow(infections),
    first_case = if (length(dates)) min(dates) else as.Date(NA),
    last_case = if (length(dates)) max(dates) else as.Date(NA)
  )
}
