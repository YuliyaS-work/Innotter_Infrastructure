import os
import urllib.parse

import boto3
from PIL import Image
import io

def lambda_handler(event, context):
    endpoint_url = "http://172.17.0.1:4566"
    s3 = boto3.client("s3", endpoint_url=endpoint_url)

    source_bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    key = urllib.parse.unquote_plus(key)

    target_bucket ="avatars-processed"

    obj = s3.get_object(Bucket=source_bucket, Key=key)
    img_data = obj["Body"].read()

    img = Image.open(io.BytesIO(img_data))

    # Crop to square (center)
    width, height = img.size
    min_side = min(width, height)
    left = (width - min_side) // 2
    top = (height - min_side) // 2
    right = left + min_side
    bottom = top + min_side
    img = img.crop((left, top, right, bottom))

    # Resize to 256x256
    img = img.resize((256, 256), Image.LANCZOS)

    # Generate new key with .webp extension
    name, _ = os.path.splitext(key)
    new_key = f"{name}.webp"

    # Save as WEBP
    buffer = io.BytesIO()
    img.save(buffer, format="WEBP", quality=85)
    buffer.seek(0)

    s3.put_object(
        Bucket=target_bucket,
        Key=new_key,
        Body=buffer.getvalue(),
        ContentType="image/webp"
    )

    return {"key": new_key}
