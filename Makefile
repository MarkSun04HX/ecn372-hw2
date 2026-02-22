.PHONY: train evaluate install

# Install R package dependencies (run once)
install:
	Rscript -e 'for (pkg in c("readr","dplyr","caret")) if (!requireNamespace(pkg, quietly=TRUE)) install.packages(pkg, repos="https://cloud.r-project.org")'

# Train model (saved to models/models.rds, not committed)
train:
	Rscript scripts/train.R

# Evaluate on test set. Trains model first if it doesn't exist.
# BEFORE running: place test.csv in data/raw/test.csv (same structure as train.csv, target = shares)
evaluate: models/models.rds
	Rscript scripts/test.R

models/models.rds: train.csv scripts/train.R scripts/setup.R
	@mkdir -p models
	Rscript scripts/train.R
