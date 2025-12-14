## DIVE Journal – End-to-End Project Reflection

### D — Define the Problem
The objective of this project was to design and validate an **end-to-end analytics pipeline** that combines **historical batch data** with **real-time streaming data** to support near real-time analytics and machine learning. The core question was whether a cloud-native architecture using Google Cloud services could ingest, process, model, and visualize live data in a reproducible and explainable way suitable for business decision-making.

---

### I — Initial Approach
The initial approach focused on building the required technical components independently:
- Batch ingestion of historical data into BigQuery
- Streaming ingestion from a public API into BigQuery
- Training a BigQuery ML model on the available data

Early iterations treated these components separately. While batch ingestion and streaming ingestion worked independently, the initial modeling attempts did not meaningfully incorporate **both batch and streaming features** together. Additionally, early model outputs lacked clear explainability and validation tied to real-time behavior.

---

### V — Validation and Iteration
Through iterative refinement, the approach was improved to explicitly address these gaps:
- Batch and streaming data were joined using time-aware logic to ensure relevance.
- Explicit NULL handling and data quality checks were added to stabilize model training.
- A combined **batch + streaming BQML regression model** was created to satisfy project requirements.
- Model evaluation was standardized using `ML.EVALUATE`.
- Model explainability was incorporated using `ML.EXPLAIN_PREDICT` to understand feature contributions.
- Validation focused on proving near real-time ingestion using BigQuery timestamps and confirming that predictions updated as new streaming data arrived.

This iteration ensured the pipeline was not only functional, but also robust, interpretable, and aligned with real-world analytics practices.

---

### E — Evaluate Outcomes
The final solution successfully demonstrated:
- A working batch + streaming pipeline in Google Cloud
- Near real-time data ingestion validated via BigQuery timestamps
- A combined BQML model trained on both historical and live features
- Explainable machine learning results using `ML.EXPLAIN_PREDICT`
- An interactive dashboard visualizing real-time predictions

Overall, the project met all technical and analytical requirements while reinforcing the importance of iterative validation, prompt refinement, and explainability when deploying machine learning models on live data.


## Individual Contribution Summary

My individual contribution to this project is fully captured in the notebook:

**`SFinal_project_lab3.ipynb`**

In this notebook, I was responsible for the **analytics and modeling layer** of the pipeline. Specifically, my contributions included:

- Designing and implementing a **BigQuery ML regression model** that combines historical batch features with real-time streaming features
- Creating explicit **data quality checks** to validate batch and streaming inputs prior to model training
- Evaluating model performance using **`ML.EVALUATE`**
- Interpreting model behavior using **`ML.EXPLAIN_PREDICT`** to identify the most influential batch and streaming features
- Generating real-time predictions on streaming data
- Building an **interactive Plotly dashboard** to visualize actual versus predicted values over time
- Validating that model outputs and visualizations update as new streaming data is ingested

This work demonstrates my ability to apply analytics engineering and machine learning concepts to a real-time, cloud-based data pipeline while maintaining a focus on interpretability and business relevance.

## Reflection

This project reinforced the complexity and value of building analytics systems that operate beyond static, offline data. While batch analytics provided a strong historical foundation, integrating real-time streaming data introduced new challenges related to data freshness, schema stability, and timing alignment. Addressing these challenges required careful design choices around ingestion, validation, and feature engineering.

One of the most important takeaways was the importance of **robust data quality checks and NULL handling** when working with live data. Unlike batch pipelines, streaming data is inherently unpredictable, and even small gaps or inconsistencies can break downstream modeling. Explicit validation logic significantly improved model stability and confidence in the results.

The project also highlighted the importance of **model explainability** in real-time analytics. Using `ML.EXPLAIN_PREDICT` provided insight into how both historical and streaming features influenced predictions, which is critical when deploying machine learning models in business contexts where transparency and trust matter. This shifted my focus from purely optimizing model performance to ensuring interpretability and decision relevance.

Overall, this project strengthened my understanding of cloud-native analytics pipelines, BigQuery ML, and the practical considerations required to deploy machine learning on live data. It demonstrated how batch and streaming analytics can be combined to deliver timely, explainable insights, and it reinforced the importance of iterative validation when working with real-world data systems.

