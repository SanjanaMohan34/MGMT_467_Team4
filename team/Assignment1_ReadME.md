AI-Assisted Exploratory Data Analysis & BI Dashboard — Citi Bike NYC  
**MGMT 467 | Group 4 — Lily • Sanjana • Kundana • Anurag**

---

Project Overview
The New York City Department of Transportation (NYC DOT) partnered with our team to analyze public **Citi Bike** data to identify strategies that can improve **bike availability** and **rider engagement**.  
Our analysis combines **AI-assisted exploratory data analysis (EDA)** with **interactive business intelligence (BI)** visualization to help stakeholders make data-driven decisions.

We used **BigQuery**, **Gemini**, and **Looker Studio** to uncover trends in usage behavior, trip duration, and rider patterns — ultimately informing recommendations for system optimization and resource allocation.


Objective
To analyze historical Citi Bike usage data and produce an **executive-level dashboard** that reveals:
- How trip behavior differs between **subscriber types** (Annual vs Casual)  
- How **time of day** and **day of week** influence ridership  
- Where and when to **rebalance bikes** for maximum utilization  

---
Tools & Technologies
| Tool | Purpose |
|------|----------|
| **BigQuery (SQL)** | Data extraction, cleaning, transformation, and aggregation |
| **Gemini (AI-assisted EDA)** | Pattern identification and SQL generation |
| **Google Colab / Python** | Data validation, visualization testing, and distance computation |
| **Looker Studio (BI Dashboard)** | KPI visualization and stakeholder insights |

---

Research Questions
Although many exploratory questions were investigated during our AI-assisted EDA process, only the **most relevant and actionable** ones were included in the final dashboard. These include:

1. **Trip Duration by User Type and Period**  
   *How do average trip durations differ between subscriber types during peak vs. off-peak hours?*  
   - SQL Hint → Label trips as peak/off-peak in a CTE, compute average `tripduration` by `usertype` and `period`, use `LAG()` to find duration gaps.

2. **Average Distance per Trip**  
   *What is the average distance traveled per trip, and how does it vary by user type and time of day?*  
   - Derived from station coordinates using the Haversine formula or distance field if available.

3. **Weekday vs Weekend Patterns**  
   *Is there a difference in ridership patterns between weekdays and weekends?*  
   - Assessed trip counts and average durations segmented by `DAYOFWEEK(starttime)`.

---

Key KPIs Displayed on Dashboard
Each visualization aligns with one or more business questions.

| KPI | Description | Business Value |
|-----|--------------|----------------|
| **Avg Trip Duration (peak vs off-peak)** | Mean trip time segmented by rider type and period | Identifies engagement and commuting vs leisure behavior |
| **Avg Trip Distance per User Type** | Distance (miles/km) per ride | Reveals commute vs recreational patterns |
| **Weekend vs Weekday Trip Volume** | Total rides by day category | Helps plan bike redistribution for weekend surges |

---

Executive Dashboard Insights
The interactive Looker Studio dashboard summarizes the key findings:
- **Annual Subscribers** dominate morning/evening peaks, while **Casual Riders** prefer afternoons and weekends.  
- **Peak-hour trips** are shorter but more frequent, suggesting commuter intent.  
- **Average trip distance** increases outside rush hours — indicating leisure use.  
- **Weekend ridership spikes** require additional bike rebalancing across tourist-heavy stations.

---

Methodology Summary
1. **Data Extraction ( BigQuery )** → queried Citi Bike public dataset for target period ( e.g., Summer 2019 ).  
2. **Data Preprocessing** → filtered null stations, computed time bands, and derived distance metrics.  
3. **AI Assistance ( Gemini )** → generated SQL queries for EDA and hypothesis validation.  
4. **Visualization ( Looker Studio )** → built dashboard with dimension filters (user type, time of day, day of week).  

---

## 💼 Business Recommendations
- **Rebalance bikes** toward commuter stations during weekday mornings and afternoons.  
- **Increase dock availability** near parks and tourist zones on weekends.  
- **Promote subscription plans** targeting casual riders with weekend discounts or loyalty offers.  

---

## 📎 Notes
> This README summarizes only the major analyses and visualizations included in the final dashboard.  
> Additional EDA steps and exploratory queries were performed during development but excluded for brevity and clarity in presentation in the ReadME.  

---

## 📚 References
- NYC Open Data – [Citi Bike Trip History Data](https://www.citibikenyc.com/system-data)  
- Google BigQuery Public Datasets  
- Google Gemini – AI-Assisted SQL Generation  
- Looker Studio Documentation  

---

⭐ **Submitted for MGMT 467 — AI-Assisted Data Analysis & Visualization Assignment 1** 
