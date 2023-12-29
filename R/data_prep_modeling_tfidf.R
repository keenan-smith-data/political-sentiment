here::i_am("R/data_prep_modeling_tfidf.R")
library(tidymodels)

docid_to_bias <- function(df) {
  df |>
    tidytable::separate_wider_delim(doc_id, delim = "_", names = c("short_source", "pull_index", "source_bias"), cols_remove = TRUE) |>
    tidytable::select(-short_source, -pull_index)
}

# Reading in Bag of Words Data
bigram_tfidf <- tidytable::fread(here::here("data", "model_data", "tfidf_bigram_df_4k.csv.gz"))

# Docid to Rownames
rownames(bigram_tfidf) <- bigram_tfidf$doc_id

# Splitting Docid into Classification
bigram_tfidf <- docid_to_bias(bigram_tfidf)

# Data Split
set.seed(2023)
tfidf_split <- initial_split(bigram_tfidf, strata = source_bias)

# Splitting Data
bigram_train <- training(tfidf_split)
bigram_test <- testing(tfidf_split)
bigram_folds <- vfold_cv(bigram_train)