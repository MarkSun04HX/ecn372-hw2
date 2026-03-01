# ============================================================
# TEST SCRIPT: Load Model, Predict on Test Data, Evaluate
# ============================================================

# ------------------------------------------------------------
# Load project setup
# - Paths, packages, target variable
# ------------------------------------------------------------
source(file.path(getwd(), "scripts", "setup.R")) 


# ------------------------------------------------------------
# Data Loading + Preprocessing Function
# ------------------------------------------------------------
# - Reads CSV file
# - Removes 'url' column (non-predictive identifier)
# - Imputes missing numeric values with column median
# - Returns cleaned dataframe
# ------------------------------------------------------------
load_data <- function(path) {
  df <- read_csv(path, show_col_types = FALSE)
  
  # Remove identifier column if present
  df <- select(df, -any_of("url"))
  
  # Median imputation for numeric columns
  df[] <- lapply(df, function(col) {
    if (is.numeric(col)) col[is.na(col)] <- median(col, na.rm = TRUE)
    col
  })
  
  return(df)
}


# ------------------------------------------------------------
# Load Trained Model
# ------------------------------------------------------------
# The model was saved as an RDS file during training
# ------------------------------------------------------------
final_model <- readRDS(MODEL_PATH)


# ------------------------------------------------------------
# Load and Clean Test Data
# ------------------------------------------------------------
df_test <- load_data(TEST_PATH)

# Extract true target values
y_test <- df_test$shares


# ------------------------------------------------------------
# Generate Predictions
# ------------------------------------------------------------
pred <- predict(final_model, newdata = df_test)

# Ensure predictions are non-negative (shares cannot be negative)
pred <- pmax(pred, 0)


# ------------------------------------------------------------
# Calculate Performance Metrics
# ------------------------------------------------------------
# Mean Squared Error (MSE) and Root Mean Squared Error (RMSE)
# ------------------------------------------------------------
mse  <- mean((y_test - pred)^2)
rmse <- sqrt(mse)

# Print metrics to console
cat("MSE:", round(mse, 2), "\n")
cat("RMSE:", round(rmse, 2), "\n")