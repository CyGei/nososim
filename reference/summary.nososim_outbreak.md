# Summarise an outbreak

Summarise an outbreak

## Usage

``` r
# S3 method for class 'nososim_outbreak'
summary(object, ...)
```

## Arguments

- object:

  An outbreak created by
  [`make_outbreak()`](https://cygei.github.io/nososim/reference/make_outbreak.md).

- ...:

  Unused.

## Value

A one-row tibble with population size, simulation duration, initial and
secondary case counts, total cases, and the first and last infection
dates. Case counts include infections outside the simulation period.

## See also

[`make_outbreak()`](https://cygei.github.io/nososim/reference/make_outbreak.md)
