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
    --build-arg torch_cuda_arch_list="8.0 9.0"\
    --build-arg FLASHINFER_AOT_COMPILE=true \
    --build-arg PYTORCH_CUDA_INDEX_BASE_URL=https://download.pytorch.org/whl/ \
    --build-arg nvcc_threads=1 --build-arg max_jobs=1 \
    --build-arg USE_SCCACHE=1 \
    --build-arg BUILD_PYTORCH_FROM_SOURCE=1 \
    --build-arg PYTORCH_VERSION=v2.8.0 \
    --secret id=sccache_s3_no_credentials,env=SCCACHE_S3_NO_CREDENTIALS \
    --secret id=aws_access_key_id,env=AWS_ACCESS_KEY_ID \
    --secret id=aws_secret_access_key,env=AWS_SECRET_ACCESS_KEY \
    --secret id=sccache_s3_use_ssl,env=SCCACHE_S3_USE_SSL \
    --secret id=sccache_endpoint,env=SCCACHE_ENDPOINT \
    --target vllm-openai \
    -t vllm/vllm-openai:v0.10.2-aot .
