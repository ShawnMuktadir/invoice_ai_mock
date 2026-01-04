# Invoice AI - Mobile Platform MVP

A cross-platform Flutter application built for the Invoice AI platform. This app demonstrates a complete end-to-end journey for managing invoices using a simulated Multi-Agent AI pipeline.

## 🚀 Features implemented
- **Google Authentication**: Secure onboarding and session persistence.
- **Smart Upload**: Support for Camera, Gallery, and File System (PDF/Images).
- **Multi-Agent AI Pipeline**: Visual representation of Ingestion, OCR, Classification, Fraud Detection, and Compliance stages.
- **Interactive AI Chat**: Context-aware chatbot for querying invoice data.
- **Token-Based Economy**: Simulated platform logic with daily free token usage limits.
- **Dynamic UI**: Real-time reports, history tracking, and Theme Management (Light/Dark mode).

## 🛠 Tech Stack
- **Framework**: Flutter (Stable)
- **State Management**: Riverpod
- **Storage**: Local persistence for history and mock session data.
- **Packages**: `google_sign_in`, `image_picker`, `file_picker`, `fl_chart` (if used for reports).

## 🏗 Architecture
The project follows a **Clean Architecture** pattern to ensure scalability and maintainability:
- **Data Layer**: Handles API/Mock responses and data models.
- **Domain Layer**: Contains the business logic for token consumption and AI processing states.
- **Presentation Layer**: UI components and state-driven widgets.

## ⚙️ How to Run
1. Clone the repository: `git clone [Your-Repo-URL]`
2. Install dependencies: `flutter pub get`
3. Run the app: `flutter run`
*Note: Google Sign-in is currently configured for the debug SHA-1 key.*

## 📝 Design Decisions
- **AI Simulation**: AI agents are simulated via logic-based mocks that mirror the real-world Invoice AI roadmap.
- **UX/UI**: Focused on a "non-technical end user" experience with clear progress indicators and intuitive navigation.
