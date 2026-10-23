# Rebuild the packaged example from the runnable example script.
local({
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  source("inst/examples/outbreak.R", local = TRUE)

  # The intervention uses only base functions; avoid saving this build environment.
  environment(outbreak$parameters$intervention) <- baseenv()
  dir.create("data", showWarnings = FALSE)
  save(outbreak, file = "data/outbreak.rda", compress = "xz", version = 2)
})
