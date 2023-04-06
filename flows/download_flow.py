# import required libraries
import pandas as pd
from prefect import flow, task
import os
import zipfile
from kaggle.api.kaggle_api_extended import KaggleApi

# Set up the Kaggle API client
api = KaggleApi()
api.authenticate()

@task
def download_and_preprocess_data():
    # Download the beer reviews data from Kaggle
    api.dataset_download_files('thedevastator/1-5-million-beer-reviews-from-beer-advocate', path='.')
    with zipfile.ZipFile('./1-5-million-beer-reviews-from-beer-advocate.zip', 'r') as zip:
        zip.extractall('.')

    # load data into DataFrame
    df = pd.read_csv("beer_reviews.csv")
    
    # preprocess data (e.g. remove null values, normalize data, etc.)
    df = df.dropna()
    df["beer_abv"] = df["beer_abv"].apply(lambda x: x / 100 if x > 1 else x)
    
    return df

@flow()
def download_flow():    
    data = download_and_preprocess_data()            
    return data