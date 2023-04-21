here::i_am("R/data_prep_modeling_lsa.R")
library(tidymodels)

docid_to_bias <- function(df) {
  df |>
    tidytable::separate_wider_delim(docid, delim = "_", names = c("short_source", "pull_index", "source_bias"), cols_remove = TRUE) |>
    tidytable::select(-short_source, -pull_index)
}

# Reading in Bag of Words Data
bigram_lsa <- tidytable::fread(here::here("data", "model_data", "lsa_bigram_docs_200.csv.gz"))

# Docid to Rownames
rownames(bigram_lsa) <- bigram_lsa$doc_id

# Splitting Docid into Classification
bigram_lsa <- docid_to_bias(bigram_lsa)

# Data Split
set.seed(2023)
lsa_split <- initial_split(bigram_lsa, strata = source_bias)

# Splitting Data
bigram_train <- training(lsa_split)
bigram_test <- testing(lsa_split)
bigram_folds <- vfold_cv(bigram_train)