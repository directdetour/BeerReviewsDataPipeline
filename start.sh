#!/bin/bash

#set and activate venv
python -m venv venv
source venv/bin/activate

# load python dependencies
pip install -r requirements.txt


# Start the Prefect agent in the background
# prefect agent start -q beer-reviews &

# Wait for the agent to start up
sleep 5

# Start the data download/upload automations Python script
python app.py

# waiting 5s 
sleep 5

# Create Big Query table from the uploaded parquet file
python bq_provision.py