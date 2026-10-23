# Use installed project and user libraries without changing their configuration.
.libPaths(c("E:/Github/smart-cfa/renv/library/windows/R-4.5/x86_64-w64-mingw32",
  "C:/Users/pablo/AppData/Local/R/win-library/4.5", .libPaths()))
source("Scripts/DataAppendixScripts/models.R")

# Load the previous and current diagram functions independently.
load_plot <- function(lines, name) {
  Encoding(lines) <- "UTF-8"
  env <- new.env()
  for (expr in parse(text = lines)) {
    if (is.call(expr) && identical(expr[[1]], as.name("<-")) &&
        identical(expr[[2]], as.name(name))) eval(expr, env)
  }
  env[[name]]
}
old <- load_plot(system2("git",
  c("show", "HEAD:Scripts/DataAppendixScripts/helpers.R"), stdout = TRUE), "plot_color")
plot_cfa <- load_plot(readLines("Scripts/DataAppendixScripts/helpers.R",
  encoding = "UTF-8"), "plot_cfa")
labels <- c(psycho = "PSI", physical = "FIS", social = "SOC", environment = "AMB")
models <- list(popmodel = popmodel, h1model = h1model, adjustedzemodel = adjustedzemodel)

# Check the same three article diagrams in both appearances.
for (name in names(models)) {
  model <- models[[name]]
  what <- if (name == "adjustedzemodel") "no" else "est"
  png(paste0("tmp/cfa-", name, "-color.png"), width = 1200, height = 960)
  colored <- plot_cfa(model, color = "color", node_labels = labels, what_labels = what)
  dev.off()
  png(paste0("tmp/cfa-", name, "-bw.png"), width = 1200, height = 960)
  bw <- plot_cfa(model, color = "BW", node_labels = labels, what_labels = what)
  dev.off()
  png("tmp/cfa-baseline.png", width = 1200, height = 960)
  baseline <- old(model, node_labels = labels, what_labels = what)
  dev.off()
  stopifnot(identical(colored$layout, baseline$layout),
    identical(colored$graphAttributes, baseline$graphAttributes),
    identical(bw$layout, colored$layout),
    identical(bw$graphAttributes$Nodes$labels, colored$graphAttributes$Nodes$labels))
  colors <- c(bw$graphAttributes$Nodes$color,
    bw$graphAttributes$Nodes$border.color,
    bw$graphAttributes$Nodes$label.color,
    bw$graphAttributes$Edges$color,
    bw$graphAttributes$Edges$label.color)
  rgb <- grDevices::col2rgb(colors[!is.na(colors)])
  stopifnot(all(rgb[1, ] == rgb[2, ]), all(rgb[2, ] == rgb[3, ]))
  cat(name, ": color unchanged; BW grayscale; layout and labels preserved.\n")
}
stopifnot(inherits(try(plot_cfa(popmodel, color = "invalid"), silent = TRUE), "try-error"))

# Parse article chunks and verify all call sites use the new name.
for (path in c("03_model_selection.qmd", "08_model_comparison.qmd")) {
  lines <- readLines(path, encoding = "UTF-8")
  stopifnot(!any(grepl("plot_color", lines)))
  active <- FALSE
  for (line in lines) {
    if (!active && grepl("^```\\{r", line)) {
      active <- TRUE
      chunk <- character()
    } else if (active && grepl("^```\\s*$", line)) {
      parse(text = chunk)
      active <- FALSE
    } else if (active) chunk <- c(chunk, line)
  }
  stopifnot(!active)
  cat(path, ": R syntax and renamed calls passed.\n")
}
