FROM python:3.7-slim

COPY ./ /app
WORKDIR /app

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

# install requirements
RUN pip install "dvc[s3]"==2.8.3   # since s3 is the remote storage
RUN pip install onnxruntime fastapi uvicorn numpy scipy transformers==4.5.1

# initialise dvc
RUN dvc init --no-scm

# configuring remote server in dvc
RUN dvc remote add -d model-store s3://chin-models-dvc/trained_models/
# RUN cat .dvc/config

# pulling the trained model
RUN dvc pull dvcfiles/trained_model.dvc

EXPOSE 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
