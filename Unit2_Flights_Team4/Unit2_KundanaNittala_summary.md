Unit 2 - MD Summary

By: Kundana Nittala

Insights

The linear regression model was trained using features such as departure delay, carrier, origin, destination and day of the week. The engineered logistic regression model created new features
such as route (combination of origin and destination) and departure delay buckets which contributed to an improved AUC. There was enhanced significance through using these variables and predicting
diversions. It is most important to ensure that the balance between precision and recall is maintained in order to ensure a smoother experience for both the passengers and airport operations.


Limitations/Model Failures

Utilized a baseline and logistic regression model to train the data queries. Both of the models (baseline and logistic) struggled greatly to identify the positive class which indicates 
a severe imbalance where the minority class is rare. The models achieved a very high accuracy (baseline: 0.997446, engineered: 0.997241) by largely predicting the majority class, leading 
to an inaccurate prediction of the minority class. The engineered logistic regression model had an improved AUC of 0.892322 compared to the baseline of 0.80085, a low recall of 0.017668, 
and a precision of 0.25 indicating that only a small amount of actual positive cases were identified.

Threshold

Testing thresholds 0.5 and 0.75 indicated that they were too high to capture accurate true positive rates. Based on this information, a potentially ideal threshold would be 0.2 since there 
is a higher potential to raise the true positive rate and in turn improve the model’s recall. This could lead to a more favorable outcome overall.
