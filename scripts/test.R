# Test: load model, predict on data/raw/test.csv, output MSE and RMSE
source(file.path(getwd(), "scripts", "setup.R")) 

load_data <- function(path) {
  df <- read_csv(path, show_col_types = FALSE)
  df <- select(df, -any_of("url"))
  df[] <- lapply(df, function(col) {
    if (is.numeric(col)) col[is.na(col)] <- median(col, na.rm = TRUE)
    col
  })
  df
}

final_model <- readRDS(MODEL_PATH)
df_test <- load_data(TEST_PATH)
y_test <- df_test$shares
pred <- predict(final_model, newdata = df_test)
pred <- pmax(pred, 0)

mse <- mean((y_test - pred)^2)
rmse <- sqrt(mse)

cat("MSE:", round(mse, 2), "\n")
cat("RMSE:", round(rmse, 2), "\n")
