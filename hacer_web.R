# Proceso 2: página web breve y bilingüe -> docs/ (la sirve GitHub Pages)
# Correr desde la raíz del proyecto: source("hacer_web.R")
# Requiere: Quarto (viene con RStudio) y el paquete quarto (install.packages("quarto")).

# TRUE para traer de nuevo estilos.scss y _parciales/ del sitio personal
# (cuando cambies el diseño allá). cv.scss y _parciales/cv.html no se tocan.
sincronizar_estilo <- FALSE

if (sincronizar_estilo) {
  base <- "https://raw.githubusercontent.com/ViridianaLizardo/viridianalizardo.github.io/main/"
  for (f in c("estilos.scss", "_parciales/head.html",
              "_parciales/cabecera.html", "_parciales/pie.html")) {
    download.file(paste0(base, f), f, quiet = TRUE)
  }
}

if (!all(file.exists(c("pdf/CV-es.pdf", "pdf/CV-en.pdf")))) {
  warning("Faltan los PDFs: corre primero source('hacer_pdfs.R') o los botones darán 404.")
}

if (requireNamespace("quarto", quietly = TRUE)) quarto::quarto_render() else system2("quarto", "render")
invisible(file.create("docs/.nojekyll"))   # evita que GitHub Pages procese el sitio con Jekyll
message("✓ docs/index.html")
