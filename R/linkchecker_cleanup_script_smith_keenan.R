# This is a combination of two R scripts
# The first script is cleaning link data from Linkchecker
# Which ends at Line 237 Second is Webscrape Testing which ends at Line 340

# Library Initialize
library(tidyverse)

# Read In Jacobin Links
jacobin_raw <- read_rds("data/jacobin_unfiltered.rds")

# Vector for String Exclusion
jacobin_exclude <- c(
  "wp-content", "format", "category", "jpg", "png", "gif",
  "com$", "\\?"
)
# Cleaning Link Data
jacobin <-
  jacobin_raw |>
  filter(
    valid == TRUE,
    size > 1,
    is.na(infostring),
    str_detect(url, "jacobin\\.com/20"),
    str_detect(url, paste(jacobin_exclude, collapse = "|"), negate = TRUE)
  )

# Ensuring all links are distinct
jacobin_mod <-
  jacobin |>
  distinct(url)

# Selecting Years 2018 to now
jacobin_mod <-
  jacobin_mod |>
  mutate(year = as.numeric(str_extract(url, "\\d\\d\\d\\d"))) |>
  filter(year > 2018) |>
  arrange(desc(year))

# Writing cleaned link data to disk
write_rds(jacobin_mod, "data/jacobin.rds", "gz", compression = 9L)

# Reading in Brookings Data
brookings_raw <- read_rds("data/brookings_raw.rds")

# Exclusion Vector
brookings_exclude <- c(
  "com$", "/experts/", "html$", "#",
  "\\?", "%", "amp/$", "feed/$"
)
# Inclusion Vector
brookings_include <- c(
  "edu/blog/", "edu/testimonies/", "edu/research/", "edu/book/", "pdf$"
)

# Cleaning Data
brookings <-
  brookings_raw |>
  filter(
    valid == TRUE,
    size > 1,
    str_detect(url, paste(brookings_include, collapse = "|")),
    str_detect(url, paste(brookings_exclude, collapse = "|"), negate = TRUE)
  )

# Separating Data for different content types
brookings_blog <-
  brookings |>
  filter(
    str_detect(url, brookings_include[[1]])
  ) |>
  distinct(url) |>
  arrange(url)

brookings_testimonies <-
  brookings |>
  filter(
    str_detect(url, brookings_include[[2]])
  ) |>
  distinct(url) |>
  arrange(url)

brookings_research <-
  brookings |>
  filter(
    str_detect(url, brookings_include[[3]])
  ) |>
  distinct(url) |>
  arrange(url)

brookings_book <-
  brookings |>
  filter(
    str_detect(url, brookings_include[[4]])
  ) |>
  distinct(url) |>
  arrange(url)

brookings_pdf <-
  brookings |>
  filter(
    str_detect(url, brookings_include[[5]])
  ) |>
  distinct(url) |>
  arrange(url)

# Writing to Disk
write_rds(brookings_blog, "data/brookings_blog.rds", "gz", compression = 9L)
write_rds(brookings_testimonies, "data/brookings_testimonies.rds", "gz", compression = 9L)
write_rds(brookings_research, "data/brookings_research.rds", "gz", compression = 9L)
write_rds(brookings_book, "data/brookings_book.rds", "gz", compression = 9L)
write_rds(brookings_pdf, "data/brookings_pdf.rds", "gz", compression = 9L)

# Reading in the Nation Data
thenation_raw <- read_rds("data/thenation_unfilted.rds")

# Exclusion Vector
thenation_exclude <- c(
  "wp-", "com$", "/feed/$", "html$", "tnamp/$", "#",
  "\\?", "%"
)

# Cleaning Data
thenation <-
  thenation_raw |>
  filter(
    valid == TRUE,
    size > 1,
    is.na(infostring),
    str_detect(url, "thenation\\.com/article"),
    str_detect(url, paste(thenation_exclude, collapse = "|"), negate = TRUE)
  )

thenation_mod <-
  thenation |>
  distinct(url) |>
  arrange(url)

# Writing to Disk
write_rds(thenation_mod, "data/thenation.rds", "gz", compression = 9L)

# Reading in American Mind Data
features_raw <- read_delim("data/americanmindfeatures.csv", delim = ";", show_col_types = FALSE)
memos_raw <- read_delim("data/americanmindmemos.csv", delim = ";", show_col_types = FALSE)
salvos_raw <- read_delim("data/americanmindsalvos.csv", delim = ";", show_col_types = FALSE)
claremont_raw <- read_delim("data/claremontreviewessays.csv", delim = ";", show_col_types = FALSE)

# Exclusion Vector
features_exclude <- c("oembed", "twitter", "features/$", "\\.com$", "google\\.com/")

# Cleaning Data and Writing to Disk
features <-
  features_raw |>
  filter(
    valid == TRUE,
    size > 1,
    str_detect(url, "americanmind\\.org/features/"),
    str_detect(url, paste(features_exclude, collapse = "|"), negate = TRUE)
  ) |>
  distinct(url) |>
  arrange(url)

write_rds(features, "data/americanmindfeatures.rds", "gz", compression = 9L)

memos <-
  memos_raw |>
  filter(
    valid == TRUE,
    str_detect(url, "org/memo/")
  ) |>
  distinct(url) |>
  arrange(url)

write_rds(memos, "data/americanmindmemos.rds", "gz", compression = 9L)

salvos <-
  salvos_raw |>
  filter(
    valid == TRUE,
    str_detect(url, "org/salvo/")
  ) |>
  distinct(url) |>
  arrange(url)

write_rds(salvos, "data/americanmindsalvos.rds", "gz", compression = 9L)

# Exclusion Vector for Claremont Data
claremont_exclude <- c(
  "/auth", "/issue", "/article", "/subscribe", "/podcast/",
  "/donate", "/advertising/", "/archive", "/faqs/",
  "/about-us/", "/my-account/", "/contact-us/", "/digital-exclusive/",
  "/publication-committee/", "com/$", "com$", "wp-"
)

claremont <-
  claremont_raw |>
  filter(
    valid == TRUE,
    str_detect(url, "claremontreviewofbooks\\.com"),
    str_detect(url, paste(claremont_exclude, collapse = "|"), negate = TRUE)
  ) |>
  distinct(url) |>
  arrange(url)

# Writing to Disk
write_rds(claremont, "data/claremontreviewessays.rds", "gz", compression = 9L)

# Reading in Heritage Data
heritage_raw <- read_rds("data/heritage.rds")
# Exclusion Vector
heritage_exclude <- c("mailto", "staff", "wp-", "\\.com", "html$", "#", "\\?", "%", "=")
heritage_include <- c("commentary", "report")
# Cleaning Data
heritage <-
  heritage_raw |>
  filter(
    valid == TRUE,
    str_detect(infostring, "denied", negate = TRUE),
    str_detect(url, "www\\.heritage\\.org"),
    str_detect(url, paste(heritage_exclude, collapse = "|"), negate = TRUE),
    str_detect(url, paste(heritage_include, collapse = "|"))
  )

heritage_final <-
  heritage |>
  distinct(url) |>
  arrange(url)
# Splitting Data based on Content Type
heritage_commentary <-
  heritage_final |>
  filter(str_detect(url, "commentary"))

heritage_report <-
  heritage_final |>
  filter(str_detect(url, "report"))
# Writing to Disk
write_rds(heritage_commentary, "data/heritage_commentary.rds", "gz", compression = 9L)
write_rds(heritage_report, "data/heritage_report.rds", "gz", compression = 9L)

# Webscraping Library Load
library(rvest)

# Reading in Data from Disk
jacobin <- read_rds("data/jacobin.rds")
features <- read_rds("data/americanmindfeatures.rds")
memos <- read_rds("data/americanmindmemos.rds")
salvos <- read_rds("data/americanmindsalvos.rds")
h_commentary <- read_rds("data/heritage_commentary.rds")
h_report <- read_rds("data/heritage_report.rds")
b_blog <- read_rds("data/brookings_blog.rds")

# Webscraping Functions load
source("scraping_functions.R")

# Generating Testing Links for Scraping
j_tl <- sample(jacobin$url, 1)
j_tl_2 <- sample(jacobin$url, 1)
j_tl_3 <- sample(jacobin$url, 1)
j_tl_wrong <- "https://jacobin.com/2022/06/american-exceptionae-off-the-rails"

h_com_tl <- sample(h_commentary$url, 1)
h_com_tl_2 <- sample(h_commentary$url, 1)
h_com_tl_3 <- sample(h_commentary$url, 1)
h_com_tl_wrong <- "https://www.heritage.org/american-founders/commentary/pulitzer-overlooks-eggious-errors-award-prize-new-york-times-fatally"

h_rep_tl <- sample(h_report$url, 1)
h_rep_tl_2 <- sample(h_report$url, 1)
h_rep_tl_3 <- sample(h_report$url, 1)
h_rep_tl_wrong <- "https://www.heritage.org/arms-control/report/arms-cont-the-heritage-foundation-recommendations"

b_tl <- sample(b_blog$url, 1)
b_tl_2 <- sample(b_blog$url, 1)
b_tl_3 <- sample(b_blog$url, 1)

memo_tl <- sample(memos$url, 1)
memo_tl_2 <- sample(memos$url, 1)

salvo_tl <- sample(salvos$url, 1)
salvo_tl_2 <- sample(salvos$url, 1)

feature_tl <- sample(features$url, 1)
feature_tl <- sample(features$url, 1)

j_test_vec <- sample(jacobin$url, 10)
h_com_test_vec <- sample(h_commentary$url, 10)
h_rep_test_vec <- sample(h_report$url, 10)


# Basic Testing of Functions
b_test <- b_pull_try(b_tl)
b_test_2 <- b_pull_try(b_tl_2)

memo_test <- am_mind_pull_try(memo_tl)
salvo_test_2 <- am_mind_pull_try(salvo_tl)
feature_test_3 <- am_mind_pull_try(feature_tl)

jac_test <- j_pull_try(j_tl)
jac_test_2 <- j_pull_try(j_tl_2)
jac_test_3 <- j_pull_try(j_tl_3)

h_com_test <- h_com_pull_try(h_com_tl)
h_com_test_2 <- h_com_pull_try(h_com_tl_2)

h_rep_test <- h_rep_pull_try(h_rep_tl)
h_rep_test_2 <- h_rep_pull_try(h_rep_tl_2)
h_rep_test_3 <- h_rep_pull_try(h_rep_tl_wrong)
b_test_vec <- sample(b_blog$url, 10)

# Testing Loops for Larger Webscrape and Saving to Disk
j_data_list <- list()
h_com_data_list <- list()
h_rep_data_list <- list()
b_data_list <- list()

for (i in seq_along(j_test_vec)) {
  j_test_df <- j_pull_try(j_test_vec[i])
  j_test_df$i <- i
  j_data_list[[i]] <- j_test_df
  
  h_com_test_df <- h_com_pull_try(h_com_test_vec[i])
  h_com_test_df$i <- i
  h_com_data_list[[i]] <- h_com_test_df
  
  h_rep_test_df <- h_rep_pull_try(h_rep_test_vec[i])
  h_rep_test_df$i <- i
  h_rep_data_list[[i]] <- h_rep_test_df
  
  b_test_df <- b_pull_try(b_test_vec[i])
  b_test_df$i <- i
  b_data_list[[i]] <- b_test_df
}

j_text_test <- bind_rows(j_data_list)
h_com_text_test <- bind_rows(h_com_data_list)
h_rep_text_test <- bind_rows(h_rep_data_list)
b_text_test <- bind_rows(b_data_list)

write_rds(j_text_test, "data/jacobin_text_test.rds", "gz", compression = 9L)
write_rds(h_com_text_test, "data/heritage_com_text_test.rds", "gz", compression = 9L)
write_rds(h_rep_text_test, "data/heritage_rep_text_test.rds", "gz", compression = 9L)
write_rds(b_text_test, "data/brooking_text_test.rds", "gz", compression = 9L)