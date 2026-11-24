#' @export
#' @noRd
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
