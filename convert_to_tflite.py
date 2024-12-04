import tensorflow as tf
import numpy as np
import os

def convert_to_tflite():
    # Create assets directory if it doesn't exist
    assets_dir = 'plant_recognition_app/assets'
    os.makedirs(assets_dir, exist_ok=True)
    
    # Keras modelini yükle
    model = tf.keras.models.load_model('NasNetMobile_model.keras', compile=False)
    
    # Modeli optimize et
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    
    # Optimizasyon ayarları
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    # Post-training quantization
    def representative_dataset_gen():
        for _ in range(100):
            # Rastgele örnek veri oluştur
            data = np.random.rand(1, 224, 224, 3) * 255
            data = data.astype(np.float32)
            yield [data]
    
    converter.representative_dataset = representative_dataset_gen
    converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
    converter.inference_input_type = tf.uint8
    converter.inference_output_type = tf.uint8
    converter.experimental_new_quantizer = True
    
    # Modeli dönüştür
    tflite_model = converter.convert()
    
    # Optimize edilmiş modeli kaydet
    model_path = os.path.join(assets_dir, 'plant_classifier_optimized.tflite')
    with open(model_path, 'wb') as f:
        f.write(tflite_model)
    
    # Model boyutunu kontrol et
    print(f'Optimize edilmiş model boyutu: {len(tflite_model) / 1024 / 1024:.2f} MB')
    print(f'Model kaydedildi: {model_path}')
    
    # Etiketleri kaydet
    labels = [
        'Medicago_sativa (Yonca)',
        'Linum_tenuifolium (İnce Yapraklı Keten)',
        'Ophrys_mammosa (Arı Orkidesi)',
        'Orchis_pallens (Solgun Orkide)',
        'Vaccaria_hispanica (Çoban Çantası)'
    ]
    
    labels_path = os.path.join(assets_dir, 'labels.txt')
    with open(labels_path, 'w') as f:
        f.write('\n'.join(labels))
    print(f'Etiketler kaydedildi: {labels_path}')

if __name__ == '__main__':
    convert_to_tflite()
    print("Model başarıyla optimize edildi ve dönüştürüldü!")
