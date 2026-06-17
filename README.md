# Course website template

A Quarto website template for a course/workshop iteration. The repository ships with generic placeholder values so it renders cleanly out of the box. Create a new iteration with **Use this template**, then customise it by editing one file and running one script.

## Using this template

1. On GitHub, click **Use this template** to create a new repository for your iteration.
2. Clone it locally.
3. Edit `_variables.yml` (the single source of truth for every iteration-specific value).
4. Run the setup script to propagate the values that Quarto's `{{< var >}}` shortcode cannot reach:

   ```bash
   Rscript setup-template.R
   ```

5. Replace the schedule data and images, and review the editorial content (see Group D below).
6. Render to check everything:

   ```bash
   quarto render
   ```

7. In the new repo, set **Settings → Pages → Build and deployment → Source** to **GitHub Actions**. On the next push to `main`, `.github/workflows/publish.yml` renders the site and publishes it to the `gh-pages` branch.

> The template renders cleanly before any edits, so run `quarto render` first to verify your toolchain.

### How values flow

- Most values live in `_variables.yml` and reach the pages through Quarto's `{{< var ... >}}` shortcode (Group A below).
- `{{< var >}}` does **not** work in `_quarto.yml`, inside executable R chunks, or in `.qmd` front matter. Those are written by `Rscript setup-template.R`, which reads the same `_variables.yml` (Groups B and C).
- A few things are content/data and are edited by hand (Group D).

Re-running `Rscript setup-template.R` after editing `_variables.yml` is safe (idempotent).

### Group A — set in `_variables.yml`, applied automatically via `{{< var >}}`

| Variable | What it is | Example | Used in |
|---|---|---|---|
| `author` | Instructor name | `Lars Schöbitz` | `index.qmd` intro (also patched into front matter, Group C) |
| `author-url` | Instructor profile link | `https://www.linkedin.com/in/larsschoebitz/` | `index.qmd` intro |
| `institute` | Affiliation | `ETH Zurich` | reserved for slides |
| `department` | Department | `Global Health Engineering` | reserved for slides |
| `course.code` | Course slug | `quarto-rdmss-26` | sidebar instruction text in `1-3-websites`, `2-1-about-page` |
| `course.short-title` | Short title | `quarto-rdmss-26` | reserved |
| `course.long-title` | Full course title | `Quarto - authoring and publishing ...` | slide subtitles (generic; usually keep) |
| `course.site` | Public site URL | `https://quarto-rdmss-26.github.io/website/` | abstract, slide footers |
| `course.site-short` | Site URL, display form | `quarto-rdmss-26.github.io/website` | slide footers |
| `course.github-org` | GitHub org URL | `https://github.com/quarto-rdmss-26/` | reserved |
| `session.event-name` | Hosting event | `ETH Research Data Management Summer School 2026` | `index.qmd` |
| `session.day-label` | Which day | `Day 4` | `index.qmd` |
| `session.room` | Room | `Breakout Gallery, RZD 8` | `index.qmd` |
| `session.datetime` | Date and time | `04 June 2026 - 15:15 to 17:30 CET` | `index.qmd` |
| `session.survey-deadline` | Survey due date | `Tuesday, 02 June 2026` | `index.qmd` |
| `resources.posit-space` | Posit Cloud workspace | `https://posit.cloud/spaces/785946` | `1-1` slide |
| `resources.posit-space-content` | Posit Cloud content page | `https://posit.cloud/spaces/785946/content/` | homework, `1-3-websites`, `2-1-about-page` |
| `resources.posit-join-url` | Posit Cloud join link (with access code) | `https://posit.cloud/spaces/785946/join?access_code=...` | `0-2-pre-work/02-posit-cloud.qmd` |
| `resources.survey-url` | Pre-course survey | `https://forms.gle/gQht71nvHPTb3Ddw9` | `0-2-pre-work/04-survey.qmd` |
| `resources.exercises-raw` | Exercises repo raw base URL | `https://raw.githubusercontent.com/quarto-rdmss-26/exercises/main` | `1-1`, `1-2` index pages |
| `resources.exercises-repo` | Exercises repo URL | `https://github.com/quarto-rdmss-26/exercises` | `1-2` index page |

### Group B — set in the `github:` block of `_variables.yml`; `setup-template.R` writes `_quarto.yml`

`{{< var >}}` does not work in `_quarto.yml`, so the script copies these in.

| Variable | What it is | Example | Target in `_quarto.yml` |
|---|---|---|---|
| `github.owner` | GitHub org or user | `quarto-rdmss-26` | (set this and `repo` to derive the URLs below) |
| `github.repo` | Repository name | `website` | |
| `github.site-url` | GitHub Pages URL | `https://quarto-rdmss-26.github.io/website/` | `site-url` |
| `github.repo-url` | Repository URL | `https://github.com/quarto-rdmss-26/website` | `repo-url` and the sidebar GitHub `href` |
| `github.plausible-domain` | Plausible analytics domain (set `""` to disable) | `quarto-rdmss-26.github.io/website` | `data-domain` in the `include-in-header` script (removed if empty) |

### Group C — set in `_variables.yml`; `setup-template.R` writes R chunks / front matter

| Variable | What it is | Example | Target |
|---|---|---|---|
| `resources.participants-data-url` | Cohort survey CSV (URL or local path) | `https://raw.githubusercontent.com/quarto-rdmss-26/admin/refs/heads/main/data/public/participants-anonymized.csv` | `read_csv()` in `1-1-hello-quarto/1-1-hello-quarto.qmd` (defaults to local `data/participants-sample.csv`) |
| `author` | Instructor name | `Lars Schöbitz` | `author:` in the 5 slide decks and `0-4-abstract/index.qmd` |

### Group D — content and data, edited by hand

| Item | What to do | Where |
|---|---|---|
| Course schedule | Replace the committed `data/course-schedule.csv` with your schedule (columns `day`, `time`, `title` are used by `index.qmd`), or regenerate it via `data/get_course_data.R` after setting your own Google Sheet ID in that script. | `data/` |
| Cohort survey data | The slide reads `data/participants-sample.csv` by default. Point `resources.participants-data-url` at your real anonymised CSV once it exists, then re-run `setup-template.R`. | `_variables.yml`, `data/` |
| Slide narrative | The `1-1-hello-quarto` deck contains cohort-specific commentary (the "Meet the lecturer" bio and the "What you want to learn" counts). Update these per iteration. | `1-1-hello-quarto/1-1-hello-quarto.qmd` |
| Images / logos | Swap the sidebar logo, profile photo, and any course-specific images. | `images/`, `*/images/` |
| README | Update the title and any course-specific text in this file. | `README.md` |
| Licence, citations, styles | Review and keep as appropriate. | `LICENSE.md`, `references.bib`, `apa.csl` |

### What is NOT committed

Rendered output (`docs/`) and the Quarto freeze cache (`_freeze/`) are git-ignored. The site is built and deployed by the GitHub Actions workflow, so you never commit build artifacts.

## Abstract

As the expectations of researchers increase, publishing reproducible scientific articles becomes essential. However, choosing tools for these tasks can be difficult. This course aims to guide researchers through these challenges by introducing a workflow that utilizes the Quarto scientific and technical publishing system for collaborative scientific writing.

## Attribution

Content was re-used from a workshop hosted by [Mine Çetinkaya-Rundel](https://mine-cr.com/) at the 2023 Symposium on Data Science and Statistics and stored at <https://github.com/mine-cetinkaya-rundel/quarto-sdss>. The original content is licensed under a [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).

--------------------------------------------------------------------------------

![](https://i.creativecommons.org/l/by/4.0/88x31.png) This work is licensed under a [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).
