#' Define a population model
#'
#' Define how individuals arrive, their attributes, and how these
#' attributes update over time. Rules are evaluated by
#' [make_outbreak()].
#'
#'
#' @param landscape A location table from [make_landscape()].
#' @param arrivals Function `(data, t)` returning a non-negative integer
#'   vector of arrivals per location, not exceeding `data$available`.
#' @param attributes Function `(data, t)` returning one row per new arrival,
#'   preserving the input columns and adding `stay` (length of stay in days)
#'   and `tau` (non-negative transmission rate).
#' @param update Optional function `(data, t)` returning updated attributes
#'   for current occupants, preserving their identities, locations,
#'   and infection history.
#'
#' @details
#' For `arrivals`, `data` is the landscape with an additional `available`
#' column giving free capacity at time `t` (a Date).
#'
#' For `attributes`, `data` contains one row per new arrival, with
#' location attributes but without `capacity` or `available`.
#' `stay` must be a positive integer or `Inf`; `tau` must be finite
#' and non-negative. Optional `labels` identify returning individuals.
#'
#' For `update`, `data` contains this model's current occupants after transmission,
#' including `labels`, `start`, `population`, and `date_infection` alongside
#' location and custom attributes. Preserve row order and those generated
#' columns. Changes to other attributes persist until updated again or departure.
#'
#' `stay` includes the admission day. Reusing a label across stays
#' preserves infection history; other attributes are assigned afresh on arrival.
#'
#' @return A `nososim_population` containing the landscape and rules.
#' @export
#'
#' @examples
#' population <- make_population(
#'   make_landscape(list(A = 10)),
#'   arrivals = function(data, t) data$available,
#'   attributes = function(data, t) {
#'     dplyr::mutate(data, stay = 5L, tau = 0.1)
#'   }
#' )
make_population <- function(landscape, arrivals, attributes, update = NULL) {
  landscape <- tibble::as_tibble(landscape)
  keys <- level_columns(landscape)
  reserved <- c(
    "labels",
    "start",
    "t",
    "population",
    "date_infection",
    ".location"
  )
  # Validate the location table once; callbacks are evaluated during simulation.
  stopifnot(
    length(keys) > 0,
    "capacity" %in% names(landscape),
    !anyDuplicated(landscape[keys]),
    !any(reserved %in% names(landscape)),
    is.function(arrivals),
    is.function(attributes),
    is.null(update) || is.function(update)
  )
  check_counts(landscape$capacity)
  structure(
    list(
      landscape = landscape,
      arrivals = arrivals,
      attributes = attributes,
      update = update
    ),
    class = "nososim_population"
  )
}
#' Admit people into available locations
#'
#' Apply arrival and attribute rules, then assign labels and admission dates.
#' @param model Population rules from [make_population()].
#' @param current Current occupants of this population.
#' @param t Current Date.
#' @param known_labels All person labels previously used in the simulation.
#' @return A tibble of new arrivals with an internal `.location` row index.
#' @noRd
admit_individuals <- function(model, current, t, known_labels) {
  # .location is an internal landscape row index, used to count occupants.
  landscape <- model$landscape |>
    mutate(
      available = capacity -
        tabulate(.env$current$.location, nbins = dplyr::n())
    )
  counts <- model$arrivals(landscape, t)
  check_counts(counts, nrow(landscape), landscape$available)
  if (sum(counts) == 0) {
    return(current[0, ])
  }

  location_indices <- rep(seq_len(nrow(model$landscape)), times = counts)
  # Copy those rows so each person inherits their location's attributes.
  admitted <- model$landscape |>
    dplyr::slice(.env$location_indices) |>
    select(-capacity)
  data <- admitted |>
    model$attributes(t) |>
    tibble::as_tibble()
  reserved <- c("start", "t", "population", "date_infection", ".location")
  keys <- level_columns(admitted)
  stopifnot(
    "`attributes()` must preserve the allocated rows and locations." =
      identical(as.list(data[keys]), as.list(admitted[keys])),
    "`attributes()` must not set simulation-owned columns." =
      !any(reserved %in% names(data))
  )
  check_attributes(data)
  if (!"labels" %in% names(data)) {
    # Generated identifiers must not collide with any previously seen person.
    data <- data |>
      mutate(
        labels = c(.env$known_labels, simulacr::draw_labels(dplyr::n())) |>
          make.unique() |>
          utils::tail(dplyr::n())
      )
  }
  data <- data |>
    mutate(
      labels = as.character(labels),
      start = .env$t,
      .location = .env$location_indices
    )
  data
}

# Apply each model's updates without changing identity or infection records.
update_population <- function(current, models, t) {
  bind_rows(lapply(names(models), function(group) {
    residents <- current[current$population == group, ]
    update <- models[[group]]$update
    if (!nrow(residents) || is.null(update)) {
      return(residents)
    }

    # Callbacks see public attributes; retain the internal index separately.
    data <- select(residents, -.location)
    updated <- tibble::as_tibble(update(data, t))
    fixed <- c(
      "labels",
      "start",
      "population",
      "date_infection",
      level_columns(data)
    )
    stopifnot(
      "`update()` must preserve rows, identities, locations and infection history." =
        identical(as.list(updated[fixed]), as.list(data[fixed])),
      "`update()` must not set `t` or `.location`." =
        !any(c("t", ".location") %in% names(updated))
    )
    check_attributes(updated)
    updated$.location <- residents$.location
    updated
  }))
}

#' @export
#' @noRd
print.nososim_population <- function(x, ...) {
  cat("<nososim_population>\n")
  cat(
    nrow(x$landscape),
    "locations;",
    sum(x$landscape$capacity),
    "total capacity\n"
  )
  cat(
    "Rules: arrivals, attributes",
    if (!is.null(x$update)) ", update",
    "\n",
    sep = ""
  )
  invisible(x)
}
