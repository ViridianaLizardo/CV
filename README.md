# CV · Viridiana Lizardo

Este repositorio contiene el código fuente de mi Currículum Vitae, generado dinámicamente en R a partir de CSV y publicado como sitio web y PDF. La versión breve usa Quarto y la versión extensa se genera con R Markdown + `vitae::awesomecv`.

## 👩‍🔬 Sobre mí

**Viridiana Lizardo**  
_Ecóloga y Biogeógrafa Computacional_  
Doctorado en Ciencias Biológicas, UNAM

Especializada en el estudio de gradientes espaciales y temporales de diversidad usando R. Experiencia en modelado de distribución de especies, manejo de grandes bases de datos y métodos filogenéticos comparativos. Actualmente interesada en estrategias de conservación basadas en datos científicos.

🌐 [Google Scholar](https://scholar.google.com/citations?user=mIFIwsMAAAAJ)  
🪪 [ORCID](https://orcid.org/0000-0003-3958-3373)

CV bilingüe generado desde R a partir de tres CSV:

- **Web breve** (Quarto) → <https://viridianalizardo.github.io/CV/>, con el mismo diseño que el sitio personal y botones **CV-es** / **CV-en**.
- **PDF extenso** (R Markdown + `vitae::awesomecv`) en español e inglés, para postulaciones.

## Estructura

```
CV/
├── datos/
│   ├── secciones.csv      # qué secciones existen, su orden, títulos es/en y equivalencia CVU-SECIHTI
│   ├── cv.csv             # todo lo que no es publicación
│   └── publicaciones.csv  # artículos, libros, reportes… con DOI / ISBN
├── R/
│   ├── funciones.R        # lectura, fechas, citas APA, CV breve (lo usan web y PDF)
│   └── agregar_doi.R      # opcional: añade una fila a publicaciones.csv desde un DOI
├── extenso/cv.Rmd         # plantilla del PDF (una sola para ambos idiomas)
├── index.qmd              # página web
├── _quarto.yml, estilos.scss, cv.scss, _parciales/
├── hacer_pdfs.R           # proceso 1 → pdf/CV-es.pdf, pdf/CV-en.pdf
├── hacer_web.R            # proceso 2 → docs/ (lo publica GitHub Pages)
├── actualizar.R           # corre ambos
├── pdf/                   # PDFs públicos (se copian a docs/pdf/)
└── privado/               # fuera de git: referencias.csv y PDFs con referencias
```

## Flujo de trabajo

1. Edita `datos/*.csv` (Excel, RStudio o cualquier editor; guarda como CSV UTF-8).
2. En RStudio, con `CV.Rproj` abierto: `source("actualizar.R")`.
3. Commit + push. GitHub Pages sirve `docs/`.

Los procesos son independientes: si solo cambió algo de la web, `source("hacer_web.R")`; si solo cambió el PDF, `source("hacer_pdfs.R")` y luego `hacer_web.R` (para copiar los PDFs nuevos a `docs/`).

Si el repo del sitio personal está en la carpeta de al lado (`../viridianalizardo.github.io`), `hacer_pdfs.R` también copia los PDFs a su carpeta `cv/`, así los botones de la portada quedan al día.

## Instalación (una vez)

```r
install.packages(c("vitae", "rmarkdown", "readr", "dplyr", "tidyr", "quarto", "jsonlite"))
# LaTeX con XeLaTeX (si no lo tienes):
install.packages("tinytex"); tinytex::install_tinytex()
```

Quarto viene con RStudio. En GitHub: *Settings → Pages → Deploy from a branch → `main` / `/docs`*.

## Los CSV

### `secciones.csv`

| columna | uso |
|---|---|
| `seccion` | clave (la misma que usan `cv.csv` y `publicaciones.csv`) |
| `orden` | orden en el PDF y la web |
| `es`, `en` | título de la sección en cada idioma |
| `cvu` | apartado equivalente del CVU-SECIHTI (solo referencia, para copiar datos de un lado a otro) |
| `pdf`, `web` | TRUE/FALSE: si la sección sale en el PDF extenso y/o en la web breve |

Para agregar una sección nueva basta una fila aquí; no hay que tocar código.

### `cv.csv`

| columna | uso |
|---|---|
| `seccion` | clave de `secciones.csv` |
| `inicio`, `fin` | `AAAA` o `AAAA-MM`; `fin` vacío = fecha única; `presente` = en curso |
| `titulo_es`, `titulo_en` | título, puesto o grado. Si `_en` está vacío se usa `_es` (útil para títulos de ponencias o tesis) |
| `institucion`, `lugar` | sin traducir |
| `detalle_es`, `detalle_en` | descripción; **`|` separa viñetas** en el PDF |
| `enlace` | URL (en `contacto` es el destino del botón) |
| `web` | TRUE si la fila aparece en la web breve |

Secciones especiales: `perfil` (una fila: `titulo` = subtítulo bajo tu nombre, `lugar` = ciudad, `detalle` = resumen) y `contacto` (cada fila es un botón en la web). `intereses`, `habilidades` e `idiomas` se imprimen como lista "título: detalle".

### `publicaciones.csv`

`seccion, anio, autores, titulo, fuente, volumen, paginas, doi, isbn, enlace, web`

- `autores` en formato APA (`Lizardo, V., & Ruggiero, A.`); tu nombre se pone en negritas solo.
- `doi` con o sin `https://doi.org/`. Si no hay DOI se usa `isbn`, y si no, `enlace`.
- `web = TRUE` → aparece en "artículos seleccionados" de la web.
- Atajo: `source("R/agregar_doi.R"); agregar_doi("10.1111/jbi.70183")` agrega la fila desde Crossref (revísala después).

## Referencias (privadas)

`privado/referencias.csv` (columnas `nombre, cargo_es, cargo_en, institucion, correo`) está fuera de git. Para una postulación que pida referencias, pon `con_referencias <- TRUE` en `hacer_pdfs.R`: los PDFs salen en `privado/` y nunca en la web.

## Diseño

`estilos.scss` y `_parciales/{head,cabecera,pie}.html` son copias del sitio personal; no se editan aquí. Para actualizarlas: `sincronizar_estilo <- TRUE` en `hacer_web.R`. Lo propio de esta página vive en `cv.scss` y `_parciales/cv.html`.
