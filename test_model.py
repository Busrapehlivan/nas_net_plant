from model import PlantClassifier

def test_prediction(image_path):
    classifier = PlantClassifier()
    result = classifier.predict(image_path)
    print(f"Tahmin edilen bitki: {result['class_name']}")
    print(f"Güven oranı: {result['confidence']*100:.2f}%")

if __name__ == "__main__":
    # Test için bir görüntü yolu belirtin
    image_path = "bitki.png"  # Test etmek istediğiniz görüntünün yolunu buraya yazın
    test_prediction(image_path)
