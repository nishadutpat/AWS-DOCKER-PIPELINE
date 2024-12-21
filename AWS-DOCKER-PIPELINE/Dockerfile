# Dockerfile
FROM python:3.9-slim

# Install dependencies
RUN pip install boto3 pymysql

# Add the Python script
COPY scripts/script.py /app/script.py

# Set working directory
WORKDIR /app

# Environment variables (can be overridden during deployment)
ENV S3_BUCKET my-bucket-name
ENV S3_KEY data-file.txt
ENV RDS_HOST my-rds-host
ENV RDS_USER admin
ENV RDS_PASSWORD password
ENV RDS_DATABASE mydb

# Command to run the script
CMD ["python", "script.py"]
