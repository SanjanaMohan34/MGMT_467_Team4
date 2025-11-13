## Insights
In this project, I developed and evaluated a linear regression model in to predict arrival delay (ArrDelay) based on flight data such as departure delay, distance, carrier, origin, destination, and day of week. The project helped further improve my skills in data preprocessing, model training, and performance evaluation using SQL in BigQuery. I also learned how to use ML.EXPLAIN_PREDICT to understand feature contributions and interpret model outputs for different scenarios.

## Model Failure
The linear regression model performed poorly overall, achieving a Mean Absolute Error of approximately 183.75 minutes, meaning predictions were on average more than three hours away from the true arrival delay. This level of error is far too high for any meaningful use. The likely causes include:
1. High variance and outliers in delay times.
2. Nonlinear relationships between predictors (e.g., carrier, route) and arrival delay.
3. Categorical encoding limitations — categorical flight features such as airline and airport cannot be effectively captured by a linear model.
4. Temporal factors (e.g., seasonality, weather patterns) were not modeled.
5. The linear approach was too simple to handle the complexity of flight delays.

## Threshold
Although regression models do not directly use a probability threshold, if converted to a classification task (e.g., predicting “delayed” vs “on-time”), I would recommend a threshold of 0.2 for the delay probability. This would slightly reduce precision but increase recall, capturing more truly delayed flights, which is more important for customer satisfaction and operations.

## Limitations
The primary limitation is the low predictive power (MAE ~183.75) and the linear model’s inability to capture complex relationships. Additionally, 
- The dataset is likely imbalanced, with many on-time flights compared to delayed ones.
- Important predictors such as weather, time of year, and airport congestion were not included.
- Feature scaling and encoding methods may have introduced noise.
- Outliers (extreme delays) heavily influenced the regression fit.

## False Positives and False Negatives
False Positives (FP): Flights predicted as delayed that actually arrive on time. These would cause unnecessary concern or operational adjustments but are less damaging.
False Negatives (FN): Flights predicted as on time that are actually delayed. These are more critical because they lead to operational disruptions and passenger dissatisfaction.
Thus, recall/minimizing false negatives should be prioritized over precision.

## Future Ideas
For better results in the future, 
1. Replace the linear regression with logistic regression to classify whether a flight will be delayed.
2. Experiment with tree-based models such as Boosted Trees or Random Forests via MODEL_TYPE='BOOSTED_TREE_REGRESSOR' or MODEL_TYPE='AUTOML'.
3. Engineer new features such as weather data, holiday indicators, or departure time categories.
4. Address class imbalance with resampling techniques or weighted loss functions.
5. Consider using deep learning or AutoML Tables for non-linear modeling and automated feature handling.
