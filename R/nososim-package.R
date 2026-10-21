#' nososim: Nosocomial Outbreak Simulation
#'
#' Create daily populations, simulate transmission, and plot outbreaks.
#'
#' @importFrom dplyr all_of arrange bind_rows coalesce filter if_else left_join
#' @importFrom dplyr mutate n select transmute
#' @importFrom ggplot2 aes element_blank element_line geom_point geom_segment
#' @importFrom ggplot2 ggplot labs scale_x_date theme theme_classic
#' @importFrom purrr imap map_chr reduce
#' @importFrom rlang .data .env
#' @importFrom stats rbinom
#' @importFrom tibble tibble
#' @importFrom utils globalVariables
"_PACKAGE"

#' @export
#' @importFrom ggplot2 autoplot
ggplot2::autoplot
