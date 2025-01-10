import kagglehub
import boto3
import glob
import pdb
import os

dataset = "iamsouravbanerjee/customer-shopping-trends-dataset"

path = kagglehub.dataset_download(dataset)

print("Path to dataset files:", path)

files = files = glob.glob(path + '/*.csv') 
## Push to SageMaker S3 Data Lake Bucket
s3_client = boto3.client('s3')
bucket_name = [buck['Name'] for buck in s3_client.list_buckets()['Buckets'] if 'sagemaker' in buck['Name']][0]
               

# Upload the file
s3_client = boto3.client('s3')

for file in files:
    response = s3_client.upload_file(
                file, 
                bucket_name, 
                f"/dzd_dk1y743kqggmsn/afmkrtr8iqplbb/dev/{os.path.basename(file)}"
        )