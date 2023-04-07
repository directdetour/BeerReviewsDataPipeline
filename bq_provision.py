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

# # Get the dataset reference
# dataset_ref = client.dataset(dataset_id)
# # Get the dataset object (returns None if the dataset does not exist)
# dataset = client.get_dataset(dataset_ref)

# Check if the dataset already exists
dataset_ref = client.dataset(dataset_id)
dataset = None
try:
    dataset = client.get_dataset(dataset_ref)
    print(f"Dataset {dataset_id} already exists.")
except Exception as e:
    print(f"Dataset {dataset_id} does not exist. Creating it now...")

if dataset is None:
    dataset = bigquery.Dataset(dataset_ref)
    dataset.location = 'US'
    dataset = client.create_dataset(dataset)
else:
    print(f"The dataset {dataset_id} exists in your project.")



# Check table exists
# Get a reference to the table.
table_ref = dataset.table(table_id)
table = None    
try:
    print(f"Table {table_id} already exists.")
except Exception as e:
    print(f"Table {table_id} does not exist. Creating it now...")

if table is None:
    print(f"The table {table_id} does not exist in dataset {dataset_id}. Creating BQ external table")
    external_config = bigquery.ExternalConfig("PARQUET")
    external_config.source_uris = [f"gs://{bucket_name}/{file_path}"]
    external_config.auto_detect = True

    # table = bigquery.Table(f"{client.project}.{dataset_id}.{table_id}")
    table = bigquery.Table(table_ref)
    table.external_data_configuration = external_config
    table = client.create_table(table)
else:
    print(f"The table {table_id} exists in dataset {dataset_id}.")


