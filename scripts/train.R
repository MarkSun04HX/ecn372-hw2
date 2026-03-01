# ============================================================
# TRAINING SCRIPT: Linear Regression Model with Polynomial
# Terms, Interactions, and 10-Fold Cross-Validation
# ============================================================

# ------------------------------------------------------------
# Load project-wide setup (paths, libraries, global constants)
# This ensures TRAIN_PATH, MODELS_DIR, MODEL_PATH are defined
# ------------------------------------------------------------
source(file.path(getwd(), "scripts", "setup.R")) 


# ------------------------------------------------------------
# Data Loading + Basic Preprocessing Function
# ------------------------------------------------------------
# - Reads CSV file
# - Drops URL column (non-predictive identifier)
# - Imputes missing numeric values with column median
# - Returns cleaned dataframe
# ------------------------------------------------------------
load_data <- function(path) {
  df <- read_csv(path, show_col_types = FALSE)
  
  # Remove non-informative identifier column if it exists
  df <- select(df, -any_of("url"))
  
  # Median imputation for numeric columns
  # This prevents model failure due to NA values
  df[] <- lapply(df, function(col) {
    if (is.numeric(col)) col[is.na(col)] <- median(col, na.rm = TRUE)
    col
  })
  
  return(df)
}


# ------------------------------------------------------------
# Model Formula Specification
# ------------------------------------------------------------
# This formula includes:
#  - Content structure features
#  - Keyword statistics
#  - LDA topic proportions
#  - Polynomial terms for non-linear effects
#  - Interaction between title subjectivity and sentiment
# ------------------------------------------------------------
final_formula <- as.formula(
  "shares ~ n_tokens_content + n_unique_tokens + n_non_stop_words +
   num_hrefs + num_self_hrefs + average_token_length + num_keywords +
   data_channel_is_entertainment + data_channel_is_bus + data_channel_is_socmed +
   data_channel_is_tech + kw_min_min + kw_max_min + kw_avg_min +
   kw_min_max + kw_max_max + kw_avg_max + kw_min_avg + kw_max_avg +
   kw_avg_avg + self_reference_avg_sharess + weekday_is_monday +
   weekday_is_tuesday + weekday_is_wednesday + weekday_is_thursday +
   weekday_is_friday + LDA_00 + LDA_01 + LDA_02 + LDA_03 +
   poly(global_subjectivity, 2) +                 # Quadratic nonlinearity
   poly(global_sentiment_polarity, 2) +           # Quadratic nonlinearity
   rate_negative_words + min_positive_polarity +
   max_positive_polarity +
   title_subjectivity * title_sentiment_polarity + # Interaction term
   abs_title_subjectivity"
)


# ------------------------------------------------------------
# Load and Clean Training Data
# ------------------------------------------------------------
df_train <- load_data(TRAIN_PATH)


# ------------------------------------------------------------
# Outlier Removal (IQR Method)
# ------------------------------------------------------------
# Removes extreme values in 'shares' to reduce influence
# of viral outliers on linear regression estimates.
#
# IQR rule:
#   Lower bound = Q1 − 1.5*IQR
#   Upper bound = Q3 + 1.5*IQR
# ------------------------------------------------------------
q <- quantile(df_train$shares, c(0.25, 0.75))
iqr <- diff(q)
lo <- q[1] - 1.5 * iqr
hi <- q[2] + 1.5 * iqr

df_train <- df_train[df_train$shares >= lo & df_train$shares <= hi, ]

message("Training samples after outlier removal: ", nrow(df_train))


# ------------------------------------------------------------
# 10-Fold Cross-Validation Setup
# ------------------------------------------------------------
# - Data split into 10 folds
# - Each fold used once as validation
# - RMSE averaged across folds
# ------------------------------------------------------------
train_control <- trainControl(method = "cv", number = 10)


# ------------------------------------------------------------
# Model Training using caret
# Method: Ordinary Least Squares (lm)
# ------------------------------------------------------------
set.seed(42)  # Reproducibility

final_model <- train(
  final_formula,
  data = df_train,
  method = "lm",
  trControl = train_control
)


# ------------------------------------------------------------
# Save Trained Model to Disk
# ------------------------------------------------------------
# Creates directory if it does not exist
# Saves model as RDS file for later prediction use
# ------------------------------------------------------------
dir.create(MODELS_DIR, showWarnings = FALSE, recursive = TRUE)
saveRDS(final_model, MODEL_PATH)


# ------------------------------------------------------------
# Extract Cross-Validated Performance Metrics
# ------------------------------------------------------------
cv_rmse <- final_model$results$RMSE
cv_mse  <- cv_rmse^2

cat("10-fold CV Training RMSE:", round(cv_rmse, 2), "\n")
cat("10-fold CV Training MSE:", round(cv_mse, 2), "\n")

message("Model saved to ", MODEL_PATH)
