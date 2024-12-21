import boto3
import pymysql
import os

def read_from_s3(bucket_name, file_key):
    s3 = boto3.client('s3')
    obj = s3.get_object(Bucket=bucket_name, Key=file_key)
    data = obj['Body'].read().decode('utf-8')
    return data

def write_to_rds(data, rds_config):
    try:
        connection = pymysql.connect(
            host=rds_config['host'],
            user=rds_config['user'],
            password=rds_config['password'],
            database=rds_config['database']
        )
        with connection.cursor() as cursor:
            cursor.execute("INSERT INTO data_table (data) VALUES (%s)", (data,))
        connection.commit()
    except Exception as e:
        print(f"RDS error: {e}")
        return False
    return True

def write_to_glue(data, database_name, table_name):
    glue = boto3.client('glue')
    print(f"Data written to Glue: {data}")

if __name__ == "__main__":
    bucket = os.getenv("S3_BUCKET")
    key = os.getenv("S3_KEY")
    data = read_from_s3(bucket, key)

    rds_config = {
        "host": os.getenv("RDS_HOST"),
        "user": os.getenv("RDS_USER"),
        "password": os.getenv("RDS_PASSWORD"),
        "database": os.getenv("RDS_DATABASE"),
    }

    if not write_to_rds(data, rds_config):
        write_to_glue(data, "glue_database", "data_table")
