# ecn372-hw2

ECN 372 Homework 2: Predict article popularity (`shares`) on the Online News Popularity dataset.

## Environment

- **R** (tested with R ≥ 4.0)
- **R packages:** `readr`, `dplyr`, `caret`

Install packages (run once):
```bash
make install
```
Or in R: `install.packages(c("readr","dplyr","caret"))`

## Usage

From the project root:

Please make sure that the test.csv is stored outside of all the folders and placed individually

```bash
make train    # Train model on train.csv (run first)
make evaluate # Test on data/raw/test.csv, print MSE and RMSE
```

`make evaluate` will:

1. Load the trained model from `models/models.rds`
2. Read test data from `data/raw/test.csv`
3. Compute predictions and print **MSE** and **RMSE** to stdout

Example output:
```
MSE: 58571478
RMSE: 7653.2
```

## Model Selection and Choices

- **Model:** Linear regression (lm) with optimized formula including polynomials and interactions.
- **Formula:** Main effects (n_tokens_content, n_unique_tokens, num_hrefs, data channels, keywords, LDA, etc.) + poly(global_subjectivity, 2) + poly(global_sentiment_polarity, 2) + title_subjectivity * title_sentiment_polarity + abs_title_subjectivity.
- **Training:** caret::train with method = "lm", 10-fold CV.
- **Preprocessing:** Drop `url`. Median imputation.
- **Replicability:** Run `make train` then `make evaluate` from project root once `test.csv` is in `data/raw/`.

## AI Usage

See `AI_USAGE.md` for documentation of AI tools used.
