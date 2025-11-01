class TransactionModel {
  String id;
  String title;
  double amount;
  String category;
  String type; // 'income' or 'expense'
  DateTime date;
  String? note;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'type': type,
    'date': date.toIso8601String(),
    'note': note,
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'],
        title: json['title'],
        amount: json['amount'],
        category: json['category'],
        type: json['type'],
        date: DateTime.parse(json['date']),
        note: json['note'],
      );
}
