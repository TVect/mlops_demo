FROM huggingface/transformers-pytorch-cpu:latest

COPY ./ /app
WORKDIR /app

ARG OSS_ACCESS_KEY_ID
ARG OSS_ACCESS_KEY_SECRET

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

#ENV OSS_ACCESS_KEY_ID=$OSS_ACCESS_KEY_ID \
#    OSS_ACCESS_KEY_SECRET=$OSS_ACCESS_KEY_SECRET \
#    OSS_ENDPOINT=$OSS_ENDPOINT

# install requirements
RUN pip install "dvc[oss]"   # since oss is the remote storage
RUN pip install -r requirements_inference.txt

# initialise dvc
RUN dvc init --no-scm

# configuring remote server in dvc
RUN dvc remote add -d model-store oss://models-dvc/trained_models
RUN dvc remote modify model-store oss_endpoint $OSS_ENDPOINT
RUN dvc remote modify --local model-store oss_key_id $OSS_ACCESS_KEY_ID
RUN dvc remote modify --local model-store oss_key_secret $OSS_ACCESS_KEY_SECRET
RUN cat .dvc/config

# pulling the trained model
RUN dvc pull dvcfiles/trained_model.dvc

EXPOSE 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
