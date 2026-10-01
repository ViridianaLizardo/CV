# Funciones compartidas por la web (index.qmd) y los PDFs (extenso/cv.Rmd).
# Todo sale de tres CSV en datos/: secciones.csv, cv.csv y publicaciones.csv.

library(readr)
library(dplyr)

# ---- Lectura ---------------------------------------------------------------
# Todo se lee como texto; las celdas vacías quedan como "" (no NA).
# En las columnas pdf/web vale TRUE, sí, si, x o 1 (lo que sea cómodo en Excel).
leer_datos <- function(dir = "datos") {
  leer <- function(f) {
    ruta <- file.path(dir, f)
    # Se lee línea por línea: las que no son UTF-8 (Excel guarda en Windows-1252)
    # se convierten, sin estropear las que sí lo son.
    x <- readLines(ruta, warn = FALSE, encoding = "UTF-8")
    mal <- !validUTF8(x)
    if (any(mal)) {
      x[mal] <- iconv(x[mal], "windows-1252", "UTF-8")
      message("ℹ ", f, ": líneas ", paste(which(mal), collapse = ", "),
              " venían en Windows-1252; guarda el archivo como 'CSV UTF-8'.")
    }
    raro <- grep("Ã|Â|â€", x)
    if (length(raro)) warning(f, ": texto dañado (Ã, Â…) en líneas ", paste(raro, collapse = ", "))
    read_csv(I(x), col_types = cols(.default = "c"), na = character()) |>
      mutate(across(everything(), trimws))
  }
  logico <- function(x) tolower(x) %in% c("true", "sí", "si", "x", "1")

  secciones <- leer("secciones.csv") |>
    mutate(orden = as.numeric(orden), pdf = logico(pdf), web = logico(web)) |>
    arrange(orden)
  cv   <- leer("cv.csv") |> mutate(web = logico(web))
  pubs <- leer("publicaciones.csv") |>
    mutate(web = logico(web), doi = sub("^https?://(dx\\.)?doi\\.org/", "", doi))

  # Checkpoint: toda fila debe pertenecer a una sección declarada
  huerfanas <- setdiff(c(cv$seccion, pubs$seccion), secciones$seccion)
  if (length(huerfanas)) stop("Secciones no declaradas en secciones.csv: ",
                              paste(huerfanas, collapse = ", "))
  list(secciones = secciones, cv = cv, pubs = pubs)
}

# ---- Idioma ----------------------------------------------------------------
# Si la columna _en está vacía se usa la _es (p. ej. títulos de ponencias).
traducir <- function(d, lang) {
  en <- lang == "en"
  d$titulo  <- if (en) ifelse(d$titulo_en  != "", d$titulo_en,  d$titulo_es)  else d$titulo_es
  d$detalle <- if (en) ifelse(d$detalle_en != "", d$detalle_en, d$detalle_es) else d$detalle_es
  d
}

# "2025-07" -> "jul 2025"; "presente" -> "present" en inglés; "2021"-"2025" -> "2021–2025"
fechas <- function(inicio, fin, lang) {
  meses <- if (lang == "es") {
    c("ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic")
  } else month.abb
  bonita <- function(x) {
    x[tolower(x) %in% c("presente", "present")] <- if (lang == "es") "presente" else "present"
    m <- grepl("^\\d{4}-\\d{2}", x)
    x[m] <- paste(meses[as.integer(substr(x[m], 6, 7))], substr(x[m], 1, 4))
    x
  }
  ifelse(fin == "" | fin == inicio, bonita(inicio), paste0(bonita(inicio), "–", bonita(fin)))
}

# ---- Publicaciones (APA simplificado, en markdown) -------------------------
cita <- function(p, resaltar = "Lizardo, V.") {
  autores <- gsub(resaltar, paste0("**", resaltar, "**"), p$autores, fixed = TRUE)
  vol <- ifelse(p$volumen == "", "", paste0(", ", p$volumen))
  pag <- ifelse(p$paginas == "", "", paste0(", ", p$paginas))
  id  <- ifelse(p$doi  != "", paste0("<https://doi.org/", p$doi, ">"),
         ifelse(p$isbn != "", paste0("ISBN ", p$isbn),
         ifelse(p$enlace != "", paste0("<", p$enlace, ">"), "")))
  tit <- ifelse(p$titulo == "", "", paste0(p$titulo, ". "))
  fue <- ifelse(p$fuente == "", "", paste0("*", p$fuente, "*", vol, pag, ". "))
  ifelse(autores == "",
         paste0(p$titulo, " (", p$anio, "). ", fue, id),
         paste0(autores, " (", p$anio, "). ", tit, fue, id)) |>
    trimws()
}

# Filas de una sección, en el idioma pedido y de lo más reciente a lo más antiguo
filas <- function(datos, seccion, lang) {
  datos$cv |>
    filter(.data$seccion == !!seccion) |>
    arrange(desc(inicio)) |>
    traducir(lang)
}

# ---- CV breve para la web (markdown) ---------------------------------------
# Usa solo secciones con web = TRUE en secciones.csv y filas con web = TRUE.
cv_breve <- function(datos, lang) {
  linea <- function(...) paste0(..., collapse = "\n")
  out <- character()
  for (i in seq_len(nrow(datos$secciones))) {
    s <- datos$secciones[i, ]
    if (!s$web) next
    d <- filas(datos, s$seccion, lang) |> filter(web)
    p <- filter(datos$pubs, seccion == s$seccion, web) |> arrange(desc(anio))
    if (nrow(d) + nrow(p) == 0) next

    cuerpo <- switch(s$seccion,
      perfil   = d$detalle[1],
      contacto = linea("::: {.botonera}\n",
                       linea("[", d$titulo, "](", d$enlace, "){.boton}"), "\n:::"),
      intereses = ,
      idiomas  = paste(if (s$seccion == "idiomas") {
                         paste0(d$titulo, " (", tolower(d$detalle), ")")
                       } else d$titulo, collapse = " ✦ "),
      if (nrow(p) > 0) {
        paste0(linea("- ", cita(p)), "\n\n[",
               if (lang == "es") "Lista completa →" else "Full list →",
               "](https://viridianalizardo.github.io/ciencia.html)")
      } else {
        linea("- **", d$titulo, "** · ", d$institucion,
              " · [", fechas(d$inicio, d$fin, lang), "]{.cuando}")
      }
    )
    out <- c(out, paste0("## ", s[[lang]]), "", cuerpo, "")
  }
  paste0("::: {.idioma lang=\"", lang, "\"", if (lang != "es") " hidden=\"\"", "}\n\n",
         paste(out, collapse = "\n"), "\n:::\n")
}
