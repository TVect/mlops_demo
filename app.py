import os
from fastapi import FastAPI
from inference_onnx import ColaONNXPredictor
app = FastAPI(title="MLOps Basics App")

predictor = ColaONNXPredictor("./models/model.onnx")

base_uri = "/2016-08-15/proxy/mlops.LATEST/mlops_demo_inference/"
@app.get(base_uri)
async def home_page():
    return "<h2>Sample prediction API</h2>"


@app.get(os.path.join(base_uri, "predict/"))
async def get_prediction(text: str):
    result = predictor.predict(text)
    return result