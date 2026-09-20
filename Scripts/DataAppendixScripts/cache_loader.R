cache_load_existing <- function(
  envir = parent.frame(),
  dir = "Data/IntermediateData"
) {
  if (!dir.exists(dir)) return(invisible(character()))

  files <- list.files(dir, pattern = "\\.rds$", full.names = TRUE)

  if (!length(files)) return(invisible(character()))

  nms <- tools::file_path_sans_ext(basename(files))
  objs <- lapply(files, readRDS)
  names(objs) <- nms
  list2env(objs, envir = envir)

  invisible(nms)
}
