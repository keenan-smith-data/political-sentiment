here::i_am("R/data_prep_modeling_sparse_bow.R")
library(tidymodels)

docid_to_bias <- function(df) {
  df |>
    tidytable::separate_wider_delim(doc_id, delim = "_", names = c("short_source", "pull_index", "source_bias"), cols_remove = TRUE) |>
    tidytable::select(-short_source, -pull_index)
}

# Reading in Bag of Words Data
bigram_bow <- tidytable::fread(here::here("data", "model_data", "bow_bigram_df_4k.csv.gz"))

# Docid to Rownames
rownames(bigram_bow) <- bigram_bow$doc_id

# Splitting Docid into Classification
bigram_bow <- docid_to_bias(bigram_bow)

# Data Split
set.seed(2023)
bow_split <- initial_split(bigram_bow, strata = source_bias)

# Splitting Data
bigram_train <- training(bow_split)
bigram_test <- testing(bow_split)
bigram_folds <- vfold_cv(bigram_train)