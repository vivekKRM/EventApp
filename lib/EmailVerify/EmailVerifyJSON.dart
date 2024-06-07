import 'dart:ffi';

class Emailverifyjson {
  late int status;
  late int id;
  late String message;

  Emailverifyjson(
      {required this.status, required this.id, required this.message});

  Emailverifyjson.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    id = json['Id'] ?? '';
    message = json['message'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['Id'] = this.id;
    data['message'] = this.message;

    return data;
  }
}

class Result {
  late int id;
  late String message;
  late int status;

  Result({
    required this.status,
    required this.message,
    required this.id,
  });

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'] ?? 0;
    message = json['message'] ?? '';
    status = json['status'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = id;
    data['message'] = message;
    data['status'] = status;
    return data;
  }
}
