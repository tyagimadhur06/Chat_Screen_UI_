class Message {
  final int id;
  final String note;
  final String createdAt;

  Message({
    required this.id,
    required this.note,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      note: json['note'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
