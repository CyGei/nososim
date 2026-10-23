# Simulate an outbreak

Simulates nosocomial outbreaks. Each individual can be infected once,
and new cases become infectious from the following day.

## Usage

``` r
make_outbreak(timeline, imported, w, dates, intervention, mixing = NULL)
```

## Arguments

- timeline:

  A population timeline from
  [`make_timeline()`](https://cygei.github.io/nososim/reference/make_timeline.md).

- imported:

  Data frame with `id` and `date` (infection date) for imported cases.

- w:

  Probability mass function of the generation time distribution.

- dates:

  Dates over which to simulate transmission.

- intervention:

  Function of `present` and `date` returning the matrix E(t) of
  proportional hazard reductions (0 = none, 1 = complete), as defined in
  METHODS.md, Interventions. Rows represent sources and columns
  recipients. `present` contains the daily population, infection status,
  infection age, and infectiousness.

- mixing:

  Named list of mixing matrices by population attribute. Rows represent
  source groups and columns recipient groups. Weights are multiplied
  across attributes. `NULL` assumes equal mixing.

## Value

A `nososim_outbreak` containing the population timeline, infection
records (`id`, `source`, `date_infection`), simulation dates, and
parameters. Imported cases have `NA` sources.

## Examples

``` r
dates <- as.Date("2026-01-01") + 0:6
timeline <- make_timeline(10, dates, stay = 7,  
attributes = list(
 ward = c(A = 0.5, B = 0.5),
group = c(patient = 0.8, staff = 0.2)
))

imported <- data.frame(id = "ID_1", date = dates[1])

global_ipc <- function(present, date) {
  E_t <- matrix(
    0, nrow(present), nrow(present),
    dimnames = list(present$id, present$id)
  )
  if (date >= dates[4]) E_t[,] <- 0.9
  E_t
}

staff_masking <- function(present, date) {
  E_t <- matrix(
    0, nrow(present), nrow(present),
    dimnames = list(present$id, present$id)
  )
  E_t[present$group == "staff", ] <- 0.9
  E_t
}

A_to_B_IPC <- function(present, date) {
  E_t <- matrix(
    0, nrow(present), nrow(present),
    dimnames = list(present$id, present$id)
  )
  E_t[present$ward == "A", present$ward == "B"] <- 0.9
  E_t
}

make_outbreak(timeline, imported, w = c(0.2, 0.5, 0.3),
  dates, intervention = A_to_B_IPC
)
#> <nososim_outbreak>
#> # A tibble: 1 × 7
#>   individuals simulation_days initial_cases secondary_cases total_cases
#>         <int>           <int>         <int>           <int>       <int>
#> 1          10               7             1               2           3
#> # ℹ 2 more variables: first_case <date>, last_case <date>
```
