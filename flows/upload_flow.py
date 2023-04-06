# import required libraries
import io
import pandas as pd
from google.cloud import storage
from prefect import flow, task

# Set up the Google Cloud Storage client
client = storage.Client.from_service_account_json('./app/creds.json')
bucket_name = 'beer_reviews_bucket'
bucket = client.bucket(bucket_name)



@task
def configure_bucket_exists():
    
    # Check if the bucket already exists
    if not bucket.exists():
        # Create the bucket
        bucket.create()
        print(f"Bucket {bucket_name} created.")


@task
def upload_processed_data(df):
    # create a BytesIO object
    buffer = io.BytesIO()
    
    # save processed data to parquet file
    df.to_parquet(buffer)
    
    # upload data to Google Cloud Storage
    blob = bucket.blob("processed_beer_reviews.parquet")
    blob.upload_from_string(buffer.getvalue())
    
    return "Data upload complete."

@flow()
def upload_flow(data):
    configure_bucket_exists()
    processed_data = upload_processed_data(data)        
    return processed_data
