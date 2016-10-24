#' Build pkgdown website
#'
#' \code{build_site()} is a convenient wrapper around four functions:
#' \itemize{
#'   \item \code{\link{build_articles}()}
#'   \item \code{\link{build_home}()}
#'   \item \code{\link{build_reference}()}
#'   \item \code{\link{build_news}()}
#' }
#' See the documentation for the each function to learn how to control
#' that aspect of the site.
#'
#' @section YAML config:
#'
#' There are four top-level YAML settings that affect the entire site:
#' \code{title}, \code{assets}, \code{templates}, and \code{navbar}.
#'
#' \code{title} overrides the default site title, which is the package name.
#' It's used in the page title and default navbar.
#'
#' \code{assets} describes where to find arbitrary additional files to
#' copy into \code{path}. Use this when you need additional control over the
#' visual design of the site. Recommended for advanced users only. Specify
#' either \code{path} or \code{package}: \code{path} is a path relative to the
#' site directory; \code{package} is an installed containing directory
#' \code{inst/pkgdown/assets/}. Set \code{include_default} to \code{false} if
#' you don't want to copy pkgdown's default assets (in which case you'll also
#' need to override the default \code{head} template.
#'
#' \code{templates} overrides the built-in templates. You don't need to supply
#' all templates: pkgdown will continue to use defaults for missing templates.
#' Recommended for advanced users only. Specify either \code{path} or
#' \code{package}. \code{path} is a path relative to the site directory;
#' \code{package} is an installed containing directory
#' \code{inst/pkgdown/templates/}.
#'
#' You can put additional parameters to be passed onto the templates in
#' \code{params}. The default template supports \code{bootswatch} to
#' customise the overall theme with a bootswatch theme. You can see a
#' complete list of themes and preview how they look at
#' \url{https://gallery.shinyapps.io/117-shinythemes/}:
#'
#' \preformatted{
#' templates:
#'   params:
#'     bootswatch: cerulean
#' }
#'
#' You can also control the \code{navbar}. It uses the same syntax as
#' \href{RMarkdown}{http://rmarkdown.rstudio.com/rmarkdown_websites.html#site_navigation}.
#' The following YAML snippet illustrates some of the most important features.
#'
#' \preformatted{
#' navbar:
#'   type: inverse
#'   left:
#'     - text: "Home"
#'       href: index.html
#'     - text: "Reference"
#'       href: reference/index.html
#'     - text: "Articles"
#'       menu:
#'         - text: "Heading 1"
#'         - text: "Article A"
#'           href: articles/page_a.html
#'         - text: "Article B"
#'           href: articles/page_b.html
#'         - text: "---------"
#'         - text: "Heading 2"
#'         - text: "Article C"
#'           href: articles/page_c.html
#'         - text: "Article D"
#'           href: articles/page_d.html
#'   right:
#'     - icon: fa-github fa-lg
#'       href: https://example.com
#' }
#'
#'
#' Use \code{type} to choose between "default" and "inverse" themes.
#'
#' You position elements by placing under either \code{left} or \code{right}.
#' Components can contain sub-\code{menu}s with headings (indicated by missing
#' \code{href}) and separators. Currently pkgdown only supports fontawesome
#' icons. You can see a full list of options at
#' \url{http://fontawesome.io/icons/}.
#'
#' @inheritParams build_articles
#' @inheritParams build_reference
#' @param path Location in which to save website, relative to package
#'   path.
#' @param preview If \code{TRUE}, will preview freshly generated site
#' @export
#' @examples
#' \dontrun{
#' build_site()
#' }
build_site <- function(pkg = ".",
                       path = "docs",
                       examples = TRUE,
                       run_dont_run = FALSE,
                       mathjax = TRUE,
                       preview = interactive(),
                       seed = 1014
                       ) {

  pkg <- as_pkgdown(pkg)
  # Use path relative to pkg
  if (pkg$path != ".") {
    path <- file.path(pkg$path, path)
  }

  init_site(pkg, path)

  build_logo(pkg, path = path)
  build_home(pkg, path = path)
  build_reference(pkg,
    examples = TRUE,
    run_dont_run = TRUE,
    mathjax = TRUE,
    seed = seed,
    path = file.path(path, "reference"),
    depth = 1L
  )
  build_articles(pkg, path = file.path(path, "articles"), depth = 1L)
  build_news(pkg, path = file.path(path, "news"), depth = 1L)

  if (preview) {
    preview_site(path)
  }
  invisible(TRUE)
}

preview_site <- function(path) {
  utils::browseURL(file.path(path, "index.html"))
}

build_site_rstudio <- function() {
  devtools::document()
  build_site(preview = TRUE)
}

#' @export
#' @rdname build_site
init_site <- function(pkg = ".", path = "docs") {
  rule("Initialising site")

  mkdir(path)

  assets <- data_assets(pkg)
  for (asset in assets) {
    message("Copying '", asset, "'")
    file.copy(asset, path, recursive = TRUE)
  }
}

data_assets <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  assets <- pkg$meta$assets
  paths <- c(
    if (!is.null(assets$path))
      rel_path(assets$path, base = pkg$path),
    if (!is.null(assets$package))
      system.file("pkgdown", "assets", package = assets$package, mustWork = TRUE),
    if (!identical(assets$include_default, FALSE)) {
      file.path(inst_path(), "assets")
    }
  )

  if (length(paths) == 0)
    return(character())

  dir(paths, full.names = TRUE)
}

