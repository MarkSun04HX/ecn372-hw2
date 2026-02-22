# Setup: packages and project paths (run from project root)
PROJECT_ROOT <- getwd() 

required <- c("readr", "dplyr", "caret")
missing <- required[!sapply(required, requireNamespace, quietly = TRUE)]
if (length(missing) > 0) {
  stop("Install missing packages: ", paste(missing, collapse = ", "))
}
library(readr)
library(dplyr)
library(caret)

TRAIN_PATH <- file.path(PROJECT_ROOT, "train.csv")
TEST_PATH <- file.path(PROJECT_ROOT, "data", "raw", "test.csv")
MODELS_DIR <- file.path(PROJECT_ROOT, "models")
MODEL_PATH <- file.path(MODELS_DIR, "models.rds")
TARGET <- "shares"
