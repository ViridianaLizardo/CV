# Todo en uno: edita los CSV de datos/ y corre este archivo.
# Los dos procesos son independientes; puedes correr solo uno.
source("hacer_pdfs.R")   # 1) PDFs extensos -> pdf/CV-es.pdf, pdf/CV-en.pdf
source("hacer_web.R")    # 2) Página breve   -> docs/ (incluye copia de los PDFs)

# 3) Publicar: desde la pestaña Git de RStudio (commit + push), o descomenta:
# system("git add -A && git commit -m \"Actualiza CV\" && git push")
