enum StepStatus { pending, processing, completed, failed }

class AIStepModel {
  final String id;
  final String title;
  final String description;
  final StepStatus status;
  final int order;
  final String? errorMessage;

  AIStepModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.order,
    this.errorMessage,
  });

  AIStepModel copyWith({
    String? id,
    String? title,
    String? description,
    StepStatus? status,
    int? order,
    String? errorMessage,
  }) {
    return AIStepModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      order: order ?? this.order,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  static List<AIStepModel> getDefaultSteps() {
    return [
      AIStepModel(
        id: '1',
        title: 'Ingestion',
        description: 'File received and validated',
        status: StepStatus.pending,
        order: 1,
      ),
      AIStepModel(
        id: '2',
        title: 'OCR',
        description: 'Extracting text from document',
        status: StepStatus.pending,
        order: 2,
      ),
      AIStepModel(
        id: '3',
        title: 'Classification',
        description: 'Identifying document type',
        status: StepStatus.pending,
        order: 3,
      ),
      AIStepModel(
        id: '4',
        title: 'Fraud Detection',
        description: 'Checking for anomalies',
        status: StepStatus.pending,
        order: 4,
      ),
      AIStepModel(
        id: '5',
        title: 'Compliance',
        description: 'Validating tax and VAT rules',
        status: StepStatus.pending,
        order: 5,
      ),
    ];
  }
}