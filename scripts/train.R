# Train: Linear model with optimized formula (poly + interactions)
# 10-fold CV via caret
source(file.path(getwd(), "scripts", "setup.R")) 

# Keep self_reference_avg_sharess (formula uses this name)
load_data <- function(path) {
  df <- read_csv(path, show_col_types = FALSE)
  df <- select(df, -any_of("url"))
  df[] <- lapply(df, function(col) {
    if (is.numeric(col)) col[is.na(col)] <- median(col, na.rm = TRUE)
    col
  })
  df
}

final_formula <- as.formula(
  "shares ~ n_tokens_content + n_unique_tokens + n_non_stop_words +
   num_hrefs + num_self_hrefs + average_token_length + num_keywords +
   data_channel_is_entertainment + data_channel_is_bus + data_channel_is_socmed +
   data_channel_is_tech + kw_min_min + kw_max_min + kw_avg_min +
   kw_min_max + kw_max_max + kw_avg_max + kw_min_avg + kw_max_avg +
   kw_avg_avg + self_reference_avg_sharess + weekday_is_monday +
   weekday_is_tuesday + weekday_is_wednesday + weekday_is_thursday +
   weekday_is_friday + LDA_00 + LDA_01 + LDA_02 + LDA_03 +
   poly(global_subjectivity, 2) + poly(global_sentiment_polarity, 2) +
   rate_negative_words + min_positive_polarity +
   max_positive_polarity + title_subjectivity * title_sentiment_polarity +
   abs_title_subjectivity"
)

df_train <- load_data(TRAIN_PATH)

# Remove outliers in shares (IQR method)
q <- quantile(df_train$shares, c(0.25, 0.75))
iqr <- diff(q)
lo <- q[1] - 1.5 * iqr
hi <- q[2] + 1.5 * iqr
df_train <- df_train[df_train$shares >= lo & df_train$shares <= hi, ]
message("Training samples after outlier removal: ", nrow(df_train))

train_control <- trainControl(method = "cv", number = 10)
set.seed(42)
final_model <- train(final_formula, data = df_train, method = "lm", trControl = train_control)

dir.create(MODELS_DIR, showWarnings = FALSE, recursive = TRUE)
saveRDS(final_model, MODEL_PATH)

cv_rmse <- final_model$results$RMSE
cv_mse <- cv_rmse^2
cat("10-fold CV Training RMSE:", round(cv_rmse, 2), "\n")
cat("10-fold CV Training MSE:", round(cv_mse, 2), "\n")
message("Model saved to ", MODEL_PATH)
