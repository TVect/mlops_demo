import numpy as np
import onnxruntime as ort
from scipy.special import softmax

from utils import timing
from transformers import AutoTokenizer


class ColaONNXPredictor:
    def __init__(self, model_path):
        self.ort_session = ort.InferenceSession(model_path)
        self.tokenizer = AutoTokenizer.from_pretrained("google/bert_uncased_L-2_H-128_A-2")
        self.labels = ["unacceptable", "acceptable"]

    @timing
    def predict(self, text):
        processed = self.tokenizer(text,
                                   truncation=True,
                                   padding="max_length",
                                   max_length=128)

        ort_inputs = {
            "input_ids": np.expand_dims(processed["input_ids"], axis=0),
            "attention_mask": np.expand_dims(processed["attention_mask"], axis=0),
        }
        ort_outs = self.ort_session.run(None, ort_inputs)
        scores = softmax(ort_outs[0])[0]
        max_score_id = np.argmax(scores)
        prediction ={}
        prediction['label'] = self.labels[max_score_id]
        prediction['score'] = round(float(scores[max_score_id]), 2)

        result = {}
        result['text'] = text
        result['prediction'] = prediction
        return result


if __name__ == "__main__":
    sentence = "The boy is sitting on a bench"
    predictor = ColaONNXPredictor("./models/model.onnx")
    print(predictor.predict(sentence))
    sentences = ["The boy is sitting on a bench"] * 10
    for sentence in sentences:
        predictor.predict(sentence)
