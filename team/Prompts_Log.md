Kundana’s Prompts

You are an analytics co‑pilot. Propose 5 high‑value, testable business questions about the Citi Bike dataset (tripduration, stations, user types, time-of-day/week). Return as bullets with suggested SQL hints.
Give me an SQL query that explores the following question: How does trip duration vary by user type (customer vs. subscriber)? Why we're looking into this: Understanding the behavior of different user types can help tailor strategies for each group. SQL Hint: Use GROUP BY usertype and calculate the average tripduration
Help me implement CTEs and at least one window function into my hypothesis sql query
Give me an SQL query that explores the following question: What are the most popular start and end stations, and how does this change by time of day? Identifying high-traffic stations and peak times is crucial for managing bike distribution and availability. Use GROUP BY start_station_name, end_station_name and extract the hour from starttime
Give me an SQL query that explores the following question: Is there a difference in ridership patterns between weekdays and weekends? This can reveal commuter vs. leisure usage patterns, informing strategies for different days. Extract the day of the week from starttime and group by it to compare trip counts.
provide me an example chart to communicate the findings.
example chart to visualize hypothesis a in a new cell. I am looking to effectively implement the additional window function and CTE results into the visualization
Considering the contents of the dataset, help me dentify the top 3 growth KPIs for the business (e.g., 90-day revenue trend, repeat purchase rate, average order value) and elaborate on why these KPIs would be ideal for analysis and interpretation of the dataset
I would like to add the visualizations made within this file to looker studio in order to make a dashboard. Please guide me on that process
if the data was pulled in Collab by Gemini but is not in my big query? What approach would I use then?
now that all of the data has been loaded from the three hypothesis, I need some assistance understanding how to display my visualizations that I have created as a dashboard in looker studio using bigquery



Lily’s Prompts
use bigquery and the bigquery-public-data.new_york.citibike_trips to calculate the average trip duration
calculate average age from birth year
calculate the year-over-year growth in average trip duration. use bigquery magic commands.
calculate the growth or change in average number of trips per year
use bigquery magic commands to calculate the number of trips per month and net change in bikes at a station.
calculate net change in bikes at a station by summing the total number of ends at each station and subtracting the number of starts at the same station
calculate the 5 most popular routes by counting the number of matching stop_station_id and end_station_id combinations. use big query magic commands.
create distributions of age calculated from birth year for the 5 most popular routes
Generate a bar chart with the number of male and female riders.
How do you extract the year from the starttime column of trips_for_popular_routes_df? The values are formatted as timestamps.
Suggest alternative queries or counterexamples in SQL to cross-check two of the insights generated in this notebook. Insights include: average trip duration, year-over-year growth in average trip duration, change in average number of trips per year, number of trips per month, net change in bikes at a station, most popular routes, and more.
explain how to calculate median in SQL for a column of a table
Use the percentile_count(0.5) over() window function in this cell to calculate median
Create an interactive plotly chart to display the distribution of tripduration in minutes for a given route (unique combination of start_station_id and end_station_id). Use the bigquery-public-data.new_york.citibike_trips dataset.

Sanjana’s Prompts:

Give me a SQL query exploring the following question: Is there a difference in trip patterns between male and female riders? Key Suggestions:Why we're looking into this: This could reveal insights for targeted marketing or service adjustments. SQL Hint: Use COUNT(*) and GROUP BY gender and potentially include time-based grouping. Here's the FROM query we will use to access the data: FROM bigquery-public-data.new_york_citibike.citibike_trips
Give simple code for a validation for hypothesis A and explain it.
Give me a SQL query exploring the following question: What is the average distance traveled per trip, and how does it vary by user type and time of day?Arrange the average distance column in descending order. Use CTEs.Key Suggestions:Why we're exploring this question: This can provide insights into how the service is being used for commuting versus leisure. SQL Hint: You would need to calculate distance from station coordinates or use available distance data if present, then use AVG() and GROUP BY usertype, EXTRACT(HOUR FROM starttime). Here's the FROM query we will use to access the data: FROM bigquery-public-data.new_york_citibike.citibike_trips
Write a query to obtain two different tables, one for customers and another for subscribers. 
Give simple code for a validation for hypothesis B and explain it.
Give me a SQL query exploring the following question: Are there specific station pairs (start to end) that are significantly more popular than others? Key Suggestions:Why we're exploring this: This can highlight key routes and inform station capacity planning. SQL Hint: Use COUNT(*) and GROUP BY start_station_name, end_station_name and order by count. Use CTEs and at least one window function. Here's the FROM query we will use to access the data: FROM bigquery-public-data.new_york_citibike.citibike_trips
Give simple code for a validation for hypothesis C and explain it.
Create at least 3 charts that communicate your findings. Keep charts readable and labeled. Use matplotlib (no specific styles required). create one chart for hypothesis A, one for Hypothesis B and one for Hypothesis C. The code for each chart should be in a different cell
Create an interactive plotly graph for the same information as in graph 3.
List 5 KPIs that are important to analyse this dataset and explain them.


Anurag’s Prompts:
Act as my analytics co-pilot and give me 5 high-value business questions I can analyze using the Citi Bike dataset. Include SQL hints with CTEs and window functions.
Rewrite the SQL hints as short, easy-to-read paragraphs.
Write a SQL query to find which station pairs have the greatest imbalance between morning and evening rush-hour traffic.
Help me fix my SQL so that morning and evening periods are labeled correctly using CASE logic.
The query runs but the results have duplicate station names — how do I clean and group them properly?
Give me Matplotlib code to visualize the top 10 imbalanced station pairs clearly with labeled axes.
The chart text is overlapping — how can I rotate and format the x-axis labels for readability?
Write a query that compares average trip durations for Subscribers vs. Customers during peak and off-peak hours using a window function like LAG().
Create one of the visuals as an interactive Plotly figure so users can hover and explore trip durations by user type.
Give me a query that shows the busiest day and hour for each station using ROW_NUMBER() to isolate the top time block.
How do I build a Looker Studio dashboard using these three visualizations and connect it to my BigQuery data?
Show me how to add filters for user type and a date-range control so the dashboard is interactive.
What KPIs should I display for each of my three analysis questions to make this dashboard business-focused?
Provide BigQuery formulas for each KPI so I can calculate them directly from my dataset.
How do I upload my finished project to GitHub with a README.md file and make it public for viewing?





