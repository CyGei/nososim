# Rebuild the packaged example from the runnable example script.
local({
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  source("inst/examples/outbreak.R", local = TRUE)

  # The example captures callback dependencies in its local environment.
  dir.create("data", showWarnings = FALSE)
  save(outbreak, file = "data/outbreak.rda", compress = "xz", version = 2)
})
