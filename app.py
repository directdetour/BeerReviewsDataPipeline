# import required libraries
import pandas as pd
from google.cloud import storage
from prefect import flow, task
from prefect.task_runners import SequentialTaskRunner

# import Prefect flows
from flows.download_flow import download_flow
from flows.upload_flow import upload_flow

# define Prefect flow

@flow(task_runner=SequentialTaskRunner)
def flowkickoff():
    data = download_flow()
    processed_data = upload_flow(data)


# run Prefect flow
if __name__ == '__main__':    
    flowkickoff()