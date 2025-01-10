from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, IntegerType
from pyspark.sql.functions import col, try_add
import pandas as pd
import numpy as np
import pdb
import time
import os

num_rows = 100000
num_cols = 20000
SPARK_MASTER_IP = "172.22.0.7"

print(f"Creating Spark Session.")
os.environ['PYSPARK_PYTHON'] = "./venv/bin/python"   
# Initialize SparkSession
spark = SparkSession.builder \
    .appName("ScaleTest") \
    .master(f"spark://{SPARK_MASTER_IP}:7077") \
    .config("spark.driver.bindAddress","localhost") \
    .getOrCreate()
    # .config("spark.archives", "../data/test_venv.tar.gz") \

def regular_df():
    columns = [str(val) for val in range(num_cols)]
    df0 = pd.DataFrame(np.random.randint(1,10, size=(num_rows, num_cols)), columns=columns)
    for ind, _ in enumerate(columns[:-1]):
        val = df0[columns[ind]] + df0[columns[ind+1]] 
    
#---------------------------------
def spark_df(spark):
    columns = [str(val) for val in range(num_cols)]
    coltype = []
    for column in columns:
        coltype.append(StructField(column, IntegerType(), True))
    schema = StructType(coltype)

    sdf0 = spark.createDataFrame(np.random.randint(1, 10, size=(num_rows, num_cols)), schema)
    for ind, _ in enumerate(columns[:-1]):
        # pdb.set_trace()
        val = sdf0.select(try_add(columns[ind], columns[ind+1]))

if __name__ == "__main__":
    print(f"Running Calculation on regular dataframe.")
    start_time = time.perf_counter()
    # regular_df()
    elapsed_time = time.perf_counter() - start_time
    print(f"Time taken: {elapsed_time:.6f} seconds")

    ## TODO
    # This is not running correctly. the app is not registering both executors, tabs on UI are empty.
    print(f"Running Calculation on Spark dataframe.")
    spark_df(spark)
    elapsed_time = time.perf_counter() - (start_time + elapsed_time)
    print(f"Time taken: {elapsed_time:.6f} seconds")