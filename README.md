# NAS Net Plant Recognition App

A cross-platform mobile application for plant recognition using NASNetMobile architecture.

## Project Overview

This application allows users to identify plants by taking or uploading photos. It uses a deep learning model based on the NASNetMobile architecture, providing accurate plant recognition across different platforms (iOS, Android, and Web).

## Features

- Cross-platform support (iOS, Android, Web)
- Real-time plant recognition
- Camera integration for photo capture
- Gallery access for existing photos
- User-friendly interface
- Fast and accurate plant identification

## Technical Stack

- **Frontend**: Flutter/Dart
- **Machine Learning**: TensorFlow, NASNetMobile architecture
- **Backend**: Python (for model training and optimization)

## Project Structure

```
nas_net_plant/
├── plant_recognition_app/     # Flutter application
│   ├── lib/
│   │   ├── main.dart         # Application entry point
│   │   └── platform/         # Platform-specific implementations
│   │       ├── mobile_model.dart
│   │       └── web_model.dart
├── model/                    # Machine learning model files
│   ├── model.py             # Model definition
│   └── test_model.py        # Model testing
└── README.md
```

## Prerequisites

- Flutter SDK
- Dart SDK
- Python 3.11+
- TensorFlow
- iOS/Android development environment (for mobile deployment)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/Busrapehlivan/nas_net_plant.git
cd nas_net_plant
```

2. Install Flutter dependencies:
```bash
cd plant_recognition_app
flutter pub get
```

3. Install Python dependencies:
```bash
pip install -r requirements.txt
```

## Model Files

The model files are not included in the repository due to their size. You can:
- Download them from [release page] (coming soon)
- Generate them using the training scripts

## Running the Application

### Mobile
```bash
cd plant_recognition_app
flutter run
```

### Web
```bash
cd plant_recognition_app
flutter run -d chrome
```

## Development

- The application uses a platform-specific approach for model loading and inference
- Mobile and web implementations are separated for optimal performance
- The Flutter app provides a unified interface across platforms

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

Büşra Pehlivan - [@github](https://github.com/Busrapehlivan)

Project Link: [https://github.com/Busrapehlivan/nas_net_plant](https://github.com/Busrapehlivan/nas_net_plant)
