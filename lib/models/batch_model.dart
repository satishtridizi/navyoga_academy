class BatchModel {
  final String id;
  final String name;

  BatchModel({required this.id, required this.name});

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(id: json["id"] ?? "", name: json["name"] ?? "");
  }
}
