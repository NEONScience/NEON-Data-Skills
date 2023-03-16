---
syncID: fddd090696ff49c785de509b7637328e
title: "NEON Data Access via BigQuery: A Pilot Project"
description: "Explore NEON stream discharge and water chemistry data in the pilot project for BigQuery datasets."
dateCreated: 2023-03-16
authors: Claire K. Lunch
contributors: 
estimatedTime: 45 minutes
packagesLibraries: google-cloud-bigquery
topics: data-management, stream-discharge, water-chemistry
languageTool: Python
dataProduct: DP1.20093.001, DP4.00130.001
code1: 
tutorialSeries:
urlTitle: discharge-bq-demo

---

NEON is exploring opportunities to make data available via cloud providers. This includes Google Cloud Platform, in association with the move of NEON data storage to <a href="https://www.neonscience.org/data-samples/data-management/neon-google" target="_blank">Google Cloud Storage</a>. In the fall of 2022, NEON loaded two tabular data products to Google's BigQuery environment, as a pilot project to explore data access and interaction through BigQuery.

## Try out BigQuery

To demonstrate BigQuery data access, we developed a Jupyter notebook that queries both the pilot datasets and brings them together for a simple analysis. You can run this notebook in the Google Colab environment <a href="https://colab.research.google.com/github/NEONScience/NEON-Data-Skills/blob/main/tutorials/Python/GCP/NEON_discharge_BQ_demo.ipynb" target="_blank">here</a>.

If you prefer to use a different Jupyter environment, you can also access the notebook directly <a href="https://github.com/NEONScience/NEON-Data-Skills/blob/main/tutorials/Python/GCP/NEON_discharge_BQ_demo.ipynb" target="_blank">here</a>, and run it in the environment of your choice. In this case, consult the list of code libraries loaded in the first and second code chunks, and make sure you have them installed.

## Tips for success

* Section 1 of the notebook contains setup instructions. These are critical! You will need a Google Cloud account, and you will need to link the NEON datasets to a project in your account. The notebook will guide you through these steps.

* Do not simply open the notebook and run all! Some of the setup steps need to be carried out in Google Cloud, and three of the code chunks require you to enter your project ID.

## Future directions

Stay tuned for further developments in NEON's cloud compute support. This is an ongoing effort!

