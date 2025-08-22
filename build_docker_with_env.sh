#!/bin/sh

unamestr=$(uname)
if [ "$unamestr" = 'Linux' ]; then

  export $(grep -v '^#' .env | xargs -d '\n')

else

  export $(grep -v '^#' .env | xargs -0)

fi

docker build -f docker/Dockerfile \
    --build-arg CUDA_VERSION=12.4.0 \
    --build-arg PYTHON_VERSION=3.12 \
    --build-arg PYTORCH_CUDA_INDEX_BASE_URL=https://download.pytorch.org/whl \
    --build-arg nvcc_threads=1 --build-arg max_jobs=1 \
    --build-arg USE_SCCACHE=1 \
    --secret id=sccache_s3_no_credentials,env=SCCACHE_S3_NO_CREDENTIALS \
    --secret id=aws_access_key_id,env=AWS_ACCESS_KEY_ID \
    --secret id=aws_secret_access_key,env=AWS_SECRET_ACCESS_KEY \
    --secret id=sccache_s3_use_ssl,env=SCCACHE_S3_USE_SSL \
    --secret id=sccache_endpoint,env=SCCACHE_ENDPOINT \
    -t vllm/vllm-openai:v0.10.1.1 .
