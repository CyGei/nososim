# Plot a population timeline or outbreak

Plot a population timeline or outbreak

## Usage

``` r
# S3 method for class 'nososim_timeline'
autoplot(object, mapping = aes(), ...)

# S3 method for class 'nososim_outbreak'
autoplot(object, mapping = aes(), ...)
```

## Arguments

- object:

  A timeline or outbreak from
  [`make_timeline()`](https://cygei.github.io/nososim/reference/make_timeline.md)
  or
  [`make_outbreak()`](https://cygei.github.io/nososim/reference/make_outbreak.md).

- mapping:

  Additional aesthetics from
  [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html).

- ...:

  Unused.

## Value

A ggplot showing daily presence, with infection links for outbreaks.

## Examples

``` r
timeline <- make_timeline(2, as.Date("2026-01-01") + 0:6)
autoplot(timeline)
```
