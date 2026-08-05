import json
import os
import urllib.parse

import boto3

s3 = boto3.client("s3")


def handler(event, context):
    destination_bucket = os.environ["DESTINATION_BUCKET"]
    processed = []

    for record in event.get("Records", []):
        if record.get("eventSource") == "aws:s3":
            source_bucket = record["s3"]["bucket"]["name"]
            source_key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])
            destination_key = f"processed/{source_key}.json"
            body = json.dumps({
                "source_bucket": source_bucket,
                "source_key": source_key,
                "request_id": context.aws_request_id,
            })
            s3.put_object(Bucket=destination_bucket, Key=destination_key, Body=body.encode("utf-8"))
            processed.append(destination_key)

    return {"statusCode": 200, "processed": processed}
