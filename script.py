# -*- coding: utf-8 -*-
import os
import requests
import oss2  # pip install oss2

# 从环境变量中读取 OSS_AK 和 OSS_SK
access_key_id = os.getenv('OSS_AK')
access_key_secret = os.getenv('OSS_SK')
bucket_name = os.getenv('OSS_BUCKET_NAME')

if not access_key_id or not access_key_secret:
    raise ValueError("OSS_AK 或 OSS_SK 环境变量未设置")

# 填写Endpoint对应的Region信息，例如cn-hangzhou。注意，v4签名下，必须填写该参数
region = "oss-cn-beijing"
endpoint = "https://oss-cn-beijing.aliyuncs.com"

# 填写Bucket名称
if not bucket_name:
    bucket_name = 'ai-dataset-cyl'

# 创建Bucket对象
bucket = oss2.Bucket(oss2.Auth(access_key_id, access_key_secret), endpoint, bucket_name)

# 指定下载文件的URL
local_file_path = '/tmp/file.ext'  # 本地临时文件路径

download_url = 'https://github.com/kvcache-ai/ktransformers/releases/download/v0.2.1.post1/ktransformers-0.2.1.post1+cu121torch24avx2-cp311-cp311-linux_x86_64.whl'
object_name = '/github/download/ktransformers-0.2.1.post1+cu121torch24avx2-cp311-cp311-linux_x86_64.whl'  # OSS中的对象名称

# 下载文件到本地
response = requests.get(download_url)
if response.status_code == 200:
    with open(local_file_path, 'wb') as f:
        f.write(response.content)
    print(f"文件已下载到 {local_file_path}")
else:
    raise Exception(f"文件下载失败，状态码：{response.status_code}")

# 上传文件到OSS
with open(local_file_path, 'rb') as fileobj:
    bucket.put_object(object_name, fileobj)
    print(f"文件已上传到OSS，对象名称为：{object_name}")

# 清理本地临时文件
os.remove(local_file_path)
print("本地临时文件已清理")