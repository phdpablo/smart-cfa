# Format native data tables separately from Quarto's layout tables.
# Uses xml2 and zip, both already recorded in renv.lock.
format_docx <- function(path) {
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  workspace <- tempfile("docx-format-")
  dir.create(workspace)
  on.exit(unlink(workspace, recursive = TRUE), add = TRUE)
  utils::unzip(path, exdir = workspace)
  document_path <- file.path(workspace, "word", "document.xml")
  document <- xml2::read_xml(document_path)
  ns <- xml2::xml_ns(document)
  word_ns <- "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

  # Build namespaced properties without altering document text or relationships.
  element <- function(text) {
    xml2::read_xml(paste0(
      '<w:root xmlns:w="', word_ns, '">', text, "</w:root>"
    )) |> xml2::xml_child()
  }
  properties <- function(node, name) {
    found <- xml2::xml_find_first(node, paste0("./w:", name), ns)
    if (inherits(found, "xml_missing")) {
      found <- xml2::xml_add_child(
        node, element(paste0("<w:", name, "/>")), .where = 0
      )
    }
    found
  }
  replace_property <- function(parent, name, text) {
    xml2::xml_remove(xml2::xml_find_all(
      parent, paste0("./w:", name), ns
    ))
    xml2::xml_add_child(parent, element(text))
  }

  tables <- xml2::xml_find_all(document, ".//w:tbl", ns)
  data_count <- 0L
  for (table in tables) {
    nested <- xml2::xml_find_all(table, ".//w:tbl | .//w:drawing", ns)
    text <- xml2::xml_find_all(table, ".//w:t", ns)
    is_data <- length(nested) == 0L && length(text) > 0L
    table_properties <- properties(table, "tblPr")
    style <- if (is_data) "DataTable" else "Table"
    replace_property(table_properties, "tblStyle", paste0(
      '<w:tblStyle w:val="', style, '"/>'
    ))

    # Suppress borders on containers, including overrides on their own cells.
    if (!is_data) {
      edges <- c("top", "left", "bottom", "right", "insideH", "insideV")
      borders <- paste0('<w:', edges, ' w:val="nil"/>', collapse = "")
      replace_property(table_properties, "tblBorders", paste0(
        "<w:tblBorders>", borders, "</w:tblBorders>"
      ))
      cells <- xml2::xml_find_all(table, "./w:tr/w:tc", ns)
      for (cell in cells) {
        replace_property(properties(cell, "tcPr"), "tcBorders", paste0(
          "<w:tcBorders>", borders, "</w:tcBorders>"
        ))
      }
    } else {
      data_count <- data_count + 1L
      # Explicit run size also covers paragraphs with their own text styles.
      for (run in xml2::xml_find_all(table, ".//w:r[w:t]", ns)) {
        run_properties <- properties(run, "rPr")
        replace_property(run_properties, "sz", '<w:sz w:val="20"/>')
        replace_property(run_properties, "szCs", '<w:szCs w:val="20"/>')
      }
    }
  }

  # Add 18 pt of breathing room above and below each top-level float.
  # Cell margins work for both a following heading and a following paragraph.
  floats <- xml2::xml_find_all(document, "/w:document/w:body/w:tbl", ns)
  for (float in floats) {
    first_cells <- xml2::xml_find_all(float, "./w:tr[1]/w:tc", ns)
    last_cells <- xml2::xml_find_all(float, "./w:tr[last()]/w:tc", ns)
    for (side in c("top", "bottom")) {
      cells <- if (side == "top") first_cells else last_cells
      for (cell in cells) {
        margins <- properties(properties(cell, "tcPr"), "tcMar")
        replace_property(margins, side, paste0(
          "<w:", side, ' w:w="360" w:type="dxa"/>'
        ))
      }
    }
  }

  # Word requires property children in the OOXML schema order.
  property_order <- list(
    tblPr = c("tblStyle", "tblpPr", "tblOverlap", "bidiVisual",
              "tblStyleRowBandSize", "tblStyleColBandSize", "tblW", "jc",
              "tblCellSpacing", "tblInd", "tblBorders", "shd", "tblLayout",
              "tblCellMar", "tblLook", "tblCaption", "tblDescription",
              "tblPrChange"),
    tcPr = c("cnfStyle", "tcW", "gridSpan", "hMerge", "vMerge",
             "tcBorders", "shd", "noWrap", "tcMar", "textDirection",
             "tcFitText", "vAlign", "hideMark", "headers", "cellIns",
             "cellDel", "cellMerge", "tcPrChange")
  )
  for (name in names(property_order)) {
    for (parent in xml2::xml_find_all(document, paste0(".//w:", name), ns)) {
      children <- xml2::xml_children(parent)
      positions <- match(xml2::xml_name(children), property_order[[name]])
      for (child in children[order(positions, na.last = TRUE)]) {
        xml2::xml_add_child(parent, child, .copy = TRUE)
      }
      xml2::xml_remove(children)
    }
  }
  xml2::write_xml(document, document_path)
  output <- tempfile(fileext = ".docx")
  on.exit(unlink(output), add = TRUE)
  zip::zipr(output, list.files(workspace, all.files = TRUE, no.. = TRUE),
            include_directories = FALSE, root = workspace)
  if (!file.copy(output, path, overwrite = TRUE)) {
    stop("Cannot replace DOCX; close it in Word and render again: ", path)
  }
  message("Formatted ", data_count, " data tables and ", length(floats),
          " float containers in ", basename(path))
}

# Quarto supplies only this render's outputs; HTML/PDF renders are unaffected.
outputs <- commandArgs(trailingOnly = TRUE)
if (!length(outputs)) {
  outputs <- strsplit(Sys.getenv("QUARTO_PROJECT_OUTPUT_FILES"), "\n")[[1]]
}
for (output in outputs[grepl("\\.docx$", outputs, ignore.case = TRUE)]) {
  format_docx(output)
}
