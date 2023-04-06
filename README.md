# Project Title

Beer Reviews Data Pipeline

## Project Description

The Beer Reviews Data Pipeline is a data engineering project that involves extracting, preprocessing, and storing beer review data from a Kaggle dataset in a Google Cloud Storage data lake. The data pipeline is built using Python, and Prefect, and includes a Metabase dashboard for data visualization.

## Technologies Used

- Python
- Prefect
- Docker
- Google Cloud Storage
- Metabase

## Prerequisites

Before running the Beer Reviews Data Pipeline, you must have the following installed:
- Python

For Metabase:
- Docker
- Docker Compose

Also needed:
- GCP Service Account 
- Kaggle API keys


## Usage

**Data Pipeline**
1. Clone the repository to your local machine.
2. Create a Google Cloud Storage bucket to store the data.
3. Add GCS credentials to ./app/creds.json
    - GCP Service Account needs GCS and BigQuery read/write permissions
4. Visit [kaggle.com](https://www.kaggle.com) and get api credentials save this to `./.kaggle/kaggle.json`
    - [Details - Visit kaggle docs](https://github.com/Kaggle/kaggle-api#api-credentials)
5. Run start.sh to activate venv, install python requirements, launch data pipeline, and create bigquery table
    ```
        ./start.sh
    ```

**Data Viz**

5. launch Metabase docker instance: (may need to use sudo)
    ```
    docker-compose up --build -d
    ```

6. Open a web browser and go to `http://localhost:3000` to access the Metabase dashboard.
7. Update the "Beer Reviews" database to use your GCP credentials. (see tip below)

## Folder Structure

```
beerreviewsproject/
├── .kaggle/
│ └── kaggle.json
├── app/
│ └── creds.json
├── config/
│ └── metabase_database.env
├── flows/
│ ├── download_flow.py
│ └── upload_flow.py
├── metabase-data/
│ ├── metabase.db/
│ ├── bqdb_firstrun.sh
│ ├── bqdb_update.sh
│ └── metabase_accounts.sh
├── .gitignore
├── app.py
├── bq_provision.py
├── docker-compose.yml
├── Dockerfile.pipeline-unused
├── requirements.txt
├── README.md
└── start.sh
```

- `.kaggle/.kaggle.json`: Required to download the dataset via api in this pipeline
- `app/creds.json`: JSON from Google Cloud IAM Service Account
- `config/metabase_database.env`: Settings used by the docker-compose building Metabase container
- `flows/`: Folder containing Prefect flow files for downloading and preprocessing the data.
- `metabase-data/`: Contains the database file used to run the Metabase dashboard. Also bash scripts for interacting with the metabase system API
   > [!tip]- Use the UI to update GCP credentials used for the preconfigured "Beer Reviews" database source, or execute `bqdb_update.sh` 
- `app.py`: Python script that defines the Prefect flow and tasks.
- `bq_provision.py`: Python script that creates a BigQuery external table from the uploaded parquet data
- `docker-compose.yml`: Defines the Docker service for the Metabase Dashboard.
- `README.md`: Markdown file containing project description, installation instructions, usage instructions, and folder structure.
- `requirements.txt`: File containing Python libraries required to run the project.
- `start.sh`: bash script to launch data pipeline

## Contributing

Contributions to the Beer Reviews Data Pipeline project are welcome. To contribute, please follow these steps:

1. Fork the repository: ``
2. Create a new branch: `git checkout -b feature/your-feature`
3. Make your changes and commit them: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Submit a pull request



--- More info

kaggle datasets download -d thedevastator/1-5-million-beer-reviews-from-beer-advocate





## Notes

- kaggle api CLI
    ```kaggle datasets download -d thedevastator/1-5-million-beer-reviews-from-beer-advocate```
- Metabase is configured to use Google BigQuery as the data source, which is accessed through the Parquet file stored in the Google Cloud Storage bucket.



## Acknowledgements
- DataTalksClub DE Zoomcamp Team
- Metabase: https://www.metabase.com/
- Prefect: https://www.prefect.io/
- The beer reviews data was obtained from Kaggle: https://www.kaggle.com/datasets/thedevastator/1-5-million-beer-reviews-from-beer-advocate
    https://www.kaggle.com/datasets/thedevastator/1-5-million-beer-reviews-from-beer-advocate/download?datasetVersionNumber=2

- Google Cloud Platform for providing the cloud storage and query resources