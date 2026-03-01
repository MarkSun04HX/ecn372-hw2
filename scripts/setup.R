# ============================================================
# PROJECT SETUP: Packages, Paths, and Global Constants
# ============================================================

# ------------------------------------------------------------
# Set project root
# ------------------------------------------------------------
# Assumes this script is run from the project root folder.
# This ensures all relative paths are resolved correctly.
PROJECT_ROOT <- getwd()  


# ------------------------------------------------------------
# Required packages
# ------------------------------------------------------------
# - readr: for fast CSV reading
# - dplyr: for data manipulation
# - caret: for model training and cross-validation
# ------------------------------------------------------------
required <- c("readr", "dplyr", "caret")

# Check if any required packages are missing
missing <- required[!sapply(required, requireNamespace, quietly = TRUE)]
if (length(missing) > 0) {
  stop("Install missing packages: ", paste(missing, collapse = ", "))
}

# Load packages into R session
library(readr)
library(dplyr)
library(caret)


# ------------------------------------------------------------
# File paths
# ------------------------------------------------------------
# TRAIN_PATH: Path to the training dataset
# TEST_PATH: Path to the raw test dataset
# MODELS_DIR: Directory to save trained model(s)
# MODEL_PATH: Full file path for RDS model file
# ------------------------------------------------------------
TRAIN_PATH  <- file.path(PROJECT_ROOT, "train.csv")
TEST_PATH   <- file.path(PROJECT_ROOT, "test.csv")
MODELS_DIR  <- file.path(PROJECT_ROOT, "models")
MODEL_PATH  <- file.path(MODELS_DIR, "models.rds")


# ------------------------------------------------------------
# Target variable
# ------------------------------------------------------------
# This variable is predicted by the model
TARGET <- "shares"
