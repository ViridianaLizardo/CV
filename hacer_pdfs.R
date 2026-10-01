# Proceso 1: CV extenso en PDF (español e inglés) -> pdf/CV-es.pdf y pdf/CV-en.pdf
# Correr desde la raíz del proyecto (abre CV.Rproj y luego: source("hacer_pdfs.R")).
# Requiere: vitae, rmarkdown, readr, dplyr, tidyr y una instalación de LaTeX con XeLaTeX
# (si no tienes una: install.packages("tinytex"); tinytex::install_tinytex()).

source("R/funciones.R")
datos <- leer_datos()

# TRUE solo para generar copias con referencias (con correos de terceros) en privado/,
# que está fuera de git. Las versiones públicas nunca llevan referencias.
con_referencias <- FALSE

for (lang in c("es", "en")) {
  destino <- if (con_referencias) "privado" else "pdf"
  rmarkdown::render(
    "extenso/cv.Rmd",
    output_file = paste0("CV-", lang, ".pdf"),
    output_dir  = destino,
    envir = list2env(list(
      datos = datos, lang = lang, con_referencias = con_referencias,
      ruta_referencias = normalizePath("privado/referencias.csv", mustWork = FALSE)
    ), parent = globalenv()),
    quiet = TRUE
  )
  message("✓ ", destino, "/CV-", lang, ".pdf")
}

# Opcional: si el repo del sitio personal está junto a este, copia ahí los PDFs
# para que los botones de su portada (cv/cv-es.pdf, cv/cv-en.pdf) queden al día.
sitio <- "../viridianalizardo.github.io/cv"
if (!con_referencias && dir.exists(sitio)) {
  file.copy(c("pdf/CV-es.pdf", "pdf/CV-en.pdf"),
            file.path(sitio, c("cv-es.pdf", "cv-en.pdf")), overwrite = TRUE)
  message("✓ PDFs copiados también a ", sitio)
}
