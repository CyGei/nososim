#' Sample daily contact counts
#'
#' Draw directed contact counts with expected values given by a contact matrix.
#'
#' @param C A finite, non-negative numeric matrix of expected contact counts,
#'   with source labels in rows and recipient labels in columns, as returned by
#'   [get_contacts()].
#' @return A matrix of counts with the same dimensions and names as `C`.
#'   Zero entries remain zero; sampled counts may be asymmetric even if `C`
#'   is symmetric.
#' @details For each source, draw a Poisson total with mean `rowSums(C)`, then
#'   allocate contacts among recipients in proportion to that row of `C`.
#'   Sampling is optional: [make_outbreak()] also accepts contact intensities
#'   directly. Intervention multipliers are applied after sampling.
#' @seealso [get_intervention()]
#' @export
#' @examples
#' data <- tibble::tibble(labels = c("a", "b"), level_1 = "A")
#' sample_contacts(get_contacts(data))
sample_contacts <- function(C) {
  contacts <- matrix(0L, nrow(C), ncol(C), dimnames = dimnames(C))
  totals <- rowSums(C)

  for (i in which(totals > 0)) {
    contacts[i, ] <- as.vector(
      stats::rmultinom(1, size = stats::rpois(1, totals[i]), prob = C[i, ])
    )
  }

  contacts
}
