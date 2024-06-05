class LoginResponse {
  late int status;
  late String message;
  late String? token;
  late Result? data;

  LoginResponse(
      {required this.status,
      required this.message,
      required this.token,
      required this.data});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'] ?? '';
    json['token'] != null ? token = json['token'] : null;
    data = json['data'] != null ? new Result.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.token != null) {
      data['token'] = this.token;
    }
    if (this.data != null) {
      data['data'] = this.data?.toJson();
    }
    return data;
  }
}

class Result {
  late int id;
  late String name;
  late String token;

  Result({
    required this.id,
    required this.name,
    required this.token,
  });

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'] ?? 0;
    // oldid = json['oldid'] ?? '';
    name = json['name'] ?? '';
    token = json['token'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = id;
    data['name'] = name;
    data['token'] = token;

    return data;
  }
}
