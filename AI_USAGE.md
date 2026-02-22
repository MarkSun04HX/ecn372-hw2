# AI Usage

## 2025-02-19 — ECN 372 HW2: Online News Popularity Prediction (R pipeline + model + AI usage)

- **Tool:** Cursor Agent
- **Prompt:** (Paraphrased) Complete ECN 372 Homework 2 per instructions: build a model to predict article popularity (`shares`) on a held-out test set; implement `make evaluate` that loads model, reads test from `data/raw/test.csv`, and prints only the test MSE; ensure replicability and thorough README. Then: convert everything from Python to R, and record AI usage in `AI_USAGE.md` using the specified format (date, task description, tool, prompt, output summary, what I used, verification).
- **Output summary:** Agent created an R-based pipeline: `scripts/setup.R` (loads readr, dplyr, xgboost, randomForest; defines PROJECT_ROOT and paths for train/test/model), `scripts/train.R` (loads train.csv, fixes column typo `self_reference_avg_sharess`, drops `url`, log-transforms target; uses randomForest for feature selection top-40; trains XGBoost with fixed hyperparameters; saves to `models/model.rds`), and `scripts/evaluate.R` (sources setup; loads model or trains if missing; loads test from `data/raw/test.csv`; predicts and prints only `MSE: X.XX`). Makefile updated with `train`, `evaluate`, and `install` targets. AI_USAGE.md created in the requested format.
- **What I used:** All of the above: the three scripts and Makefile as written. The model uses log-transformed shares, Random Forest feature selection (top 40 variables), and XGBoost for prediction. No manual edits to the generated artifacts.
- **Verification:** Run `make install` (if packages needed), then `Rscript scripts/train.R` to train; create `data/raw/test.csv` (e.g., from a held-out portion of train); run `make evaluate` from project root. Output is a single line: `MSE: X.XX`. Scripts use project-relative paths; single entry point `make evaluate` as required.

---

## 2025-02-19 — Restrict to Linear/Ridge/Lasso; variable combinations; MSE comparison; Lasso CV

- **Tool:** Cursor Agent
- **Prompt:** (Paraphrased) Record every conversation in AI_USAGE.md going forward. Restrict models to only Lasso Regression, Ridge Regression, and Linear Regression (no other models). In the evaluate script, provide output that compares MSEs of different models using different variable combinations. For Lasso: use 10-fold cross-validation with lambda ranging from 10^-4 to 10^2, and choose the lambda with the lowest MSE.
- **Output summary:** Agent replaced xgboost/randomForest with glmnet. Updated `scripts/setup.R` to require readr, dplyr, glmnet. Rewrote `scripts/train.R` to: (1) define three variable combinations—all features, top 30 by |correlation| with target, top 20 by |correlation|; (2) for each combination, fit Linear (lm), Ridge (cv.glmnet, 10-fold CV, lambda 10^-4 to 10^2), Lasso (cv.glmnet, 10-fold CV, lambda 10^-4 to 10^2, choose lambda with lowest CV MSE); (3) save all fits to `models/models.rds`. Rewrote `scripts/evaluate.R` to load models, predict on test for each (var_set × model) pair, compute MSE, and print a comparison table (long and wide format). Makefile and README updated for glmnet and new model choices. AI_USAGE.md appended with this entry.
- **What I used:** All of the above: setup.R, train.R, evaluate.R, Makefile, README. Models are Linear, Ridge, Lasso only. Variable sets: all, top30, top20. Lasso and Ridge both use 10-fold CV; Lasso lambda from 10^-4 to 10^2. Evaluate outputs MSE comparison table.
- **Verification:** Run `make install`, `make train`, then `make evaluate` from project root. Expect printed table comparing MSE across variable_set (all, top30, top20) and model (Linear, Ridge, Lasso).

---

## 2025-02-19 — Lasso/Ridge variable selection; Linear with poly + interactions; 10x10-fold CV

- **Tool:** Cursor Agent
- **Prompt:** (Paraphrased) Use Ridge and Lasso regression to eliminate unnecessary variables. For Linear Regression, add polynomial and interaction variables. Do a test of that process. Record the interaction in AI_USAGE.md. Output the model and its RMSE using 10-fold CV and random sampling for 10 times, take the average MSE and RMSE and output.
- **Output summary:** Agent created `scripts/cv_evaluate.R` that: (1) uses Lasso for variable selection (non-zero coefficients at lambda.1se); (2) defines three models—Linear with polynomial and 2-way interactions on Lasso-selected vars (top 12), Ridge on Lasso-selected vars, Lasso on all vars; (3) runs 10-fold CV repeated 10 times (10 random seeds) for each model; (4) reports average MSE and average RMSE. Updated `scripts/train.R` to add `lasso_select_vars()` and a fourth variable set `lasso_selected`. Added `make cv_evaluate` target to Makefile. AI_USAGE.md appended with this entry.
- **What I used:** All of the above: cv_evaluate.R, updated train.R, Makefile. Variable elimination via Lasso; Linear model uses formula `(var1+var2+...)^2` for main effects, squared terms, and 2-way interactions on top 12 Lasso-selected vars. 10-fold CV × 10 repetitions; inner Ridge/Lasso CV uses 5 folds for speed.
- **Verification:** Run `make cv_evaluate` from project root. Expect printed table with Model, Avg_MSE, Avg_RMSE for Linear (poly+interact), Ridge (Lasso-selected), Lasso (all vars).

---

## 2025-02-19 — Consolidate to train.R + test.R; Lasso+poly+interactions; remove outliers; MSE/RMSE output

- **Tool:** Cursor Agent
- **Prompt:** (Paraphrased) Keep only one of cv_evaluate and evaluate. Use a model that: (1) Lasso regression to shrink variables; (2) add polynomial and interaction terms to those variables; (3) remove outlier samples from training set. Output MSE and RMSE in the evaluating file. Train in train.R using all training data. Create test.R to test on test.csv using the designed model.
- **Output summary:** Agent removed evaluate.R and cv_evaluate.R. Rewrote train.R: load train.csv; impute; log-transform target; remove outliers (IQR on log(shares), drop outside Q1-1.5*IQR to Q3+1.5*IQR); Lasso variable selection; build design matrix with main effects + squared terms + 2-way interactions on selected vars; fit Lasso on expanded design (CV for lambda); save model, selected_vars, pred_cols. Created test.R: load model and test.csv; preprocess; build same poly+interaction design; predict; output MSE and RMSE. Makefile: make evaluate runs test.R.
- **What I used:** All of the above: train.R, test.R, Makefile. Single model: Lasso (var selection) → poly+interactions on selected vars → Lasso on expanded matrix.
- **Verification:** Run `make train`, then `make evaluate` from project root. Expect MSE and RMSE printed.

---

## 2025-02-19 — Final model: optimized formula with poly + interactions, caret lm, 10-fold CV

- **Tool:** Cursor Agent
- **Prompt:** (Paraphrased) Adapt the model to use the user's specific formula (n_tokens_content, n_unique_tokens, poly(global_subjectivity,2), title_subjectivity * title_sentiment_polarity, etc.), train with caret method="lm" and 10-fold CV, and calculate MSE and RMSE.
- **Output summary:** Agent replaced the Lasso-based pipeline with the user's formula-based linear model. Updated setup.R to use caret instead of glmnet. Rewrote train.R: load data (keep self_reference_avg_sharess), impute; train with caret::train(final_formula, method="lm", trControl=10-fold CV); save model. Rewrote test.R: load model, predict on test, output MSE and RMSE.
- **What I used:** All of the above. Final model uses the exact formula provided by the user.
- **Verification:** Run `make train`, `make evaluate`.

---

## 2025-02-19 — Add outlier filtering on shares; print 10-fold CV training RMSE

- **Tool:** Cursor Agent
- **Prompt:** (Paraphrased) Add filtering of shares to omit all outliers in the training data. Provide the RMSE again. Record this and all previous conversations in AI_USAGE.md.
- **Output summary:** Agent added outlier removal in train.R using IQR on shares: drop rows where shares < Q1 − 1.5×IQR or shares > Q3 + 1.5×IQR. Also added printing of 10-fold CV training RMSE and MSE after training. Training samples reduced from ~31k to 28,090. 10-fold CV RMSE: 1,043.27; MSE: 1,088,403. AI_USAGE.md appended with this entry.
- **What I used:** All of the above. Outlier filtering via IQR on shares before caret::train.
- **Verification:** Run `make train`. Expect "Training samples after outlier removal: 28090", "10-fold CV Training RMSE: 1043.27", "10-fold CV Training MSE: 1088403".

---

## 2025-02-19 — Keep model for test.csv; record interaction

- **Tool:** Cursor Agent
- **Prompt:** (Paraphrased) Keep this model and use it for test.csv. Record the interaction in AI_USAGE.md.
- **Output summary:** The current model (optimized formula, IQR outlier removal, caret lm, 10-fold CV) is already used for test.csv: train.R trains and saves to models/models.rds; test.R (run via `make evaluate`) loads the model and predicts on data/raw/test.csv, outputting MSE and RMSE. No code changes required. AI_USAGE.md appended with this entry.
- **What I used:** Pipeline as-is. `make train` trains the model; `make evaluate` runs test.R to evaluate on test.csv.
- **Verification:** Run `make train` then `make evaluate`. Expect test MSE and RMSE printed.
