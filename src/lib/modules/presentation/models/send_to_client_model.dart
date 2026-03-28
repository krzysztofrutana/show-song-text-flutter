class SendToClientModel {
  factory SendToClientModel.fromJson(Map<String, dynamic> json) {
    return SendToClientModel(
      text: json['text'] as String,
      title: json['title'] as String,
    );
  }

  SendToClientModel({required this.text, required this.title});
  String text;
  String title;

  Map<String, dynamic> toJson() => {
        'text': text,
        'title': title,
      };
}
