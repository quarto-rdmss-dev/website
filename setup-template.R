#!/usr/bin/env Rscript

# setup-template.R
# ---------------------------------------------------------------------------
# Propagates iteration-specific values from _variables.yml into the places
# Quarto's {{< var >}} shortcode cannot reach:
#   1. _quarto.yml          (site-url, repo-url, sidebar GitHub href, Plausible)
#   2. R chunk in the slide (participants data URL)
#   3. .qmd front matter    (author: in the slide decks and the abstract)
#
# _variables.yml is the single source of truth. Edit it, then run:
#   Rscript setup-template.R
#
# The script is idempotent: it keys replacements on YAML keys / stable
# patterns, not on the previous values, so re-running after editing
# _variables.yml simply re-derives the targets.
# ---------------------------------------------------------------------------

if (!requireNamespace("yaml", quietly = TRUE)) {
  stop("The 'yaml' package is required. Install it with install.packages('yaml').")
}

root <- tryCatch(
  here::here(),
  error = function(e) normalizePath(dirname(sub("--file=", "",
    grep("--file=", commandArgs(FALSE), value = TRUE)[1])), mustWork = FALSE)
)
if (length(root) == 0 || is.na(root) || !nzchar(root)) root <- getwd()

vars_path <- file.path(root, "_variables.yml")
if (!file.exists(vars_path)) stop("Could not find _variables.yml at: ", vars_path)
vars <- yaml::read_yaml(vars_path)

changed <- character(0)

# Replace the first capture-preserving match of `pattern` in file `path`.
# `pattern` must contain exactly one group capturing the prefix to keep; the
# replacement is paste0(prefix, value). Operates line-aware on the whole file.
patch_file <- function(path, pattern, value, label) {
  if (!file.exists(path)) {
    message("  skip (missing): ", path)
    return(invisible(FALSE))
  }
  txt <- readLines(path, warn = FALSE, encoding = "UTF-8")
  hit <- grepl(pattern, txt, perl = TRUE)
  if (!any(hit)) {
    message("  no match for ", label, " in ", basename(path))
    return(invisible(FALSE))
  }
  new <- txt
  new[hit] <- sub(pattern, paste0("\\1", value), new[hit], perl = TRUE)
  if (identical(new, txt)) {
    return(invisible(FALSE))   # already up to date; idempotent
  }
  writeLines(new, path, useBytes = TRUE)
  message("  set ", label, " in ", basename(path))
  changed <<- union(changed, path)
  invisible(TRUE)
}

gh   <- vars$github
res  <- vars$resources
auth <- vars$author

message("Reading values from _variables.yml ...")

# --- 1. _quarto.yml --------------------------------------------------------
quarto_yml <- file.path(root, "_quarto.yml")
patch_file(quarto_yml, '^(\\s*site-url:\\s*").*(?="\\s*$)', gh$`site-url`, "site-url")
patch_file(quarto_yml, '^(\\s*repo-url:\\s*").*(?="\\s*$)', gh$`repo-url`, "repo-url")
patch_file(quarto_yml, '^(\\s*href:\\s*").*(?="\\s*$)',     gh$`repo-url`, "sidebar github href")

# Plausible analytics: set the data-domain, or remove the script if disabled.
plausible <- gh$`plausible-domain`
if (is.null(plausible) || !nzchar(plausible)) {
  txt <- readLines(quarto_yml, warn = FALSE, encoding = "UTF-8")
  keep <- !grepl("plausible\\.io/js/script\\.js", txt)
  if (!all(keep)) {
    writeLines(txt[keep], quarto_yml, useBytes = TRUE)
    message("  removed Plausible analytics script (plausible-domain empty)")
    changed <- union(changed, quarto_yml)
  }
} else {
  patch_file(quarto_yml,
    '^(\\s*<script defer data-domain=").*?(?=")', plausible, "Plausible data-domain")
}

# --- 2. participants data URL (R chunk in the slide) -----------------------
slide_1_1 <- file.path(root, "1-1-hello-quarto", "1-1-hello-quarto.qmd")
# Matches both here::here("...") and a quoted URL on the read_csv line.
patch_url <- res$`participants-data-url`
if (!is.null(patch_url) && nzchar(patch_url)) {
  if (file.exists(slide_1_1)) {
    txt <- readLines(slide_1_1, warn = FALSE, encoding = "UTF-8")
    line <- grep("participants <- readr::read_csv\\(", txt)
    if (length(line) == 1 && line < length(txt)) {
      target <- line + 1L
      if (grepl("^data/", patch_url) || !grepl("^https?://", patch_url)) {
        repl <- paste0('  here::here("', patch_url, '"),')
      } else {
        repl <- paste0('  "', patch_url, '",')
      }
      if (!identical(txt[target], repl)) {
        txt[target] <- repl
        writeLines(txt, slide_1_1, useBytes = TRUE)
        message("  set participants data URL in ", basename(slide_1_1))
        changed <- union(changed, slide_1_1)
      }
    } else {
      message("  could not locate participants read_csv() call")
    }
  }
}

# --- 3. front-matter author: -----------------------------------------------
author_files <- file.path(root, c(
  "1-1-hello-quarto/1-1-hello-quarto.qmd",
  "1-2-documents/1-2-documents.qmd",
  "1-3-websites/1-3-websites.qmd",
  "1-4-publish/1-4-publish.qmd",
  "1-5-wrap-up/1-5-wrap-up.qmd",
  "0-4-abstract/index.qmd"
))
for (f in author_files) {
  patch_file(f, '^(author:\\s*").*(?="\\s*$)', auth, "author")
}

message("")
if (length(changed)) {
  message("Done. Files updated:")
  for (f in changed) message("  - ", sub(paste0("^", root, "/?"), "", f))
} else {
  message("Done. No files needed changes (already up to date).")
}
message("\nNext: run `quarto render` and set GitHub Pages source to 'GitHub Actions'.")
