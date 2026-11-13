# Rebuild the packaged example from the runnable example script.
local({
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  source("inst/examples/outbreak.R", local = TRUE)

  # These callbacks need only base functions and a qualified nososim call.
  environment(outbreak$parameters$contacts) <- baseenv()
  outbreak$parameters$tau <- utils::removeSource(outbreak$parameters$tau)
  environment(outbreak$parameters$tau) <- baseenv()
  dir.create("data", showWarnings = FALSE)
  save(outbreak, file = "data/outbreak.rda", compress = "xz", version = 2)
})
