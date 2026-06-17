# header ------------------------------------------------------------------

# This script accesses the tables stored as Google Sheets which contain
# the course data. Each table is read and stored locally as a CSV.

# library -------------------------------------------------------------------

library(googlesheets4)
library(readr)
library(dplyr)
library(lubridate)
library(stringr)

# script ------------------------------------------------------------------

# course-schedule

# Per iteration: replace this link with your own Google Sheet lesson plan.
# This script is run by the instructor on demand; it is NOT part of the website
# render. The committed data/course-schedule.csv is what index.qmd reads.
link_lesson_plan <- "https://docs.google.com/spreadsheets/d/REPLACE_WITH_YOUR_SHEET_ID/edit?gid=0#gid=0"

googlesheets4::read_sheet(link_lesson_plan) |>
  mutate(title = case_when(
    is.na(page_link) == FALSE ~  paste0("[", title, "](", page_link, "/)"),
    TRUE ~ title
  )) |>
  mutate(start_time = as.character(start_time)) |>
  mutate(start_time = str_extract(start_time, "\\b\\d{2}:\\d{2}\\b")) |>
  mutate(end_time = as.character(end_time)) |>
  mutate(end_time = str_extract(end_time, "\\b\\d{2}:\\d{2}\\b")) |>
  mutate(time = paste(start_time, end_time, sep = " - ")) |>
  write_csv(here::here("data/course-schedule.csv"))
