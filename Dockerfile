FROM amazon/aws-lambda-python

COPY ./ /app
WORKDIR /app

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

ENV TRANSFORMERS_CACHE=./models \
    TRANSFORMERS_VERBOSITY=error

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

ENV PYTHONPATH="${PYTHONPATH}:./"

RUN yum install git -y && yum -y install gcc-c++
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

RUN python lambda_handler.py
RUN chmod -R 0755 ./models
CMD [ "lambda_handler.lambda_handler"]