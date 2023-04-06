from google.oauth2 import service_account
from google.cloud import bigquery

# Create credentials object from JSON file
creds = service_account.Credentials.from_service_account_file('./app/creds.json')

client = bigquery.Client(credentials=creds)

#https://storage.cloud.google.com/beer_reviews_bucket/processed_beer_reviews.parquet
dataset_id = 'my_beer_review_dataset'
table_id = 'beer_reviews'
bucket_name = 'beer_reviews_bucket'
file_path = 'processed_beer_reviews.parquet'

# Get the dataset object (returns None if the dataset does not exist)
dataset = client.get_dataset(dataset_id)

if dataset is None:
    print(f"The dataset {dataset_id} does not exist in your project. Creating dataset...")
    dataset = bigquery.Dataset(client.dataset(dataset_id))
    dataset.location = 'US'
    client.create_dataset(dataset)
else:
    print(f"The dataset {dataset_id} exists in your project.")


# Get the table object (returns None if the table does not exist)
table = client.get_table(dataset.table(table_id))

if table is None:
    print(f"The table {table_id} does not exist in dataset {dataset_id}. Creating BQ external table")
    external_config = bigquery.ExternalConfig("PARQUET")
    external_config.source_uris = [f"gs://{bucket_name}/{file_path}"]
    external_config.auto_detect = True

    table = bigquery.Table(f"{client.project}.{dataset_id}.{table_id}")
    table.external_data_configuration = external_config

    table = client.create_table(table)
else:
    print(f"The table {table_id} exists in dataset {dataset_id}.")


