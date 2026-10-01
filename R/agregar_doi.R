# Opcional: agrega un artículo a datos/publicaciones.csv a partir de su DOI (vía Crossref).
# Uso:  source("R/agregar_doi.R"); agregar_doi("10.1111/jbi.70183")
# Revisa después la fila en el CSV (mayúsculas, cursivas de especies, páginas).
agregar_doi <- function(doi, seccion = "articulos", archivo = "datos/publicaciones.csv") {
  doi <- sub("^https?://(dx\\.)?doi\\.org/", "", doi)
  x <- jsonlite::fromJSON(paste0("https://api.crossref.org/works/", doi))$message
  iniciales <- function(n) gsub("([[:upper:]])[^ .-]*\\.?", "\\1.", n)      # "Juan José" -> "J. J."
  a <- paste0(x$author$family, ", ", iniciales(x$author$given))
  autores <- if (length(a) == 1) a else paste0(paste(head(a, -1), collapse = ", "), ", & ", tail(a, 1))
  vol <- if (!is.null(x[["volume"]])) paste0(x[["volume"]], if (!is.null(x[["issue"]])) paste0("(", x[["issue"]], ")")) else ""
  fila <- data.frame(
    seccion = seccion,
    anio    = x$issued$`date-parts`[[1]][1],
    autores = autores,
    titulo  = x$title[[1]],
    fuente  = x$`container-title`[[1]],
    volumen = vol,
    paginas = if (is.null(x[["page"]])) "" else sub("-", "–", x[["page"]]),
    doi = doi, isbn = "", enlace = "", web = "FALSE"
  )
  readr::write_csv(fila, archivo, append = TRUE)
  print(fila)
  invisible(fila)
}
