class SendToClientModel {
  String text;
  String title;

  SendToClientModel({required this.text, required this.title});

  factory SendToClientModel.fromJson(Map<String, dynamic> json) {
    return SendToClientModel(
      text: json['text'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'title': title,
      };
}
