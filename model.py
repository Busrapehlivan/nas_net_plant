import tensorflow as tf
from tensorflow.keras.preprocessing import image
import numpy as np

class PlantClassifier:
    def __init__(self):
        self.class_names = [
            'Linum_tenuifolium',
            'Medicago_sativa',
            'Ophrys_mammosa',
            'Orchis_pallens',
            'Vaccaria_hispanica'
        ]
        self.img_size = 224
        self.model = self._load_model()

    def _load_model(self):
        try:
            # Doğrudan eğitilmiş modeli yükle
            model = tf.keras.models.load_model('NasNetMobile_model.keras')
            return model
        except Exception as e:
            print(f"Model yüklenirken hata oluştu: {e}")
            raise

    def preprocess_image(self, img_path):
        img = image.load_img(img_path, target_size=(self.img_size, self.img_size))
        img_array = image.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0)
        img_array = tf.keras.applications.nasnet.preprocess_input(img_array)
        return img_array

    def predict(self, img_path):
        processed_image = self.preprocess_image(img_path)
        predictions = self.model.predict(processed_image)
        predicted_class_index = np.argmax(predictions[0])
        confidence = predictions[0][predicted_class_index]
        
        return {
            'class_name': self.class_names[predicted_class_index],
            'confidence': float(confidence)
        }
