class EventResponse {
  late num status;
  late String message;
  late String token;
  late List<Result?> event_data;

  EventResponse(
      {required this.status, required this.message, required this.event_data});

  EventResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'] ?? '';
    token = json['token'] ?? '';
    if (json['Event_data'] != null) {
      event_data = <Result?>[];
      json['Event_data'].forEach((v) {
        event_data.add(Result?.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['token'] = this.token;
    if (this.event_data != null) {
      data['Event_data'] = event_data.map((v) => v?.toJson()).toList();
    }
    return data;
  }
}

class Result {
  late int id;
  late String logo;
  late String banner;
  late String name;
  late String sub_title;
  late String month_name;
  late String start_month;
  late String start_date;
  late String privacy_settings;
  late int access_code;
  late String end_date;
  late String year;

  Result({
    required this.id,
    required this.logo,
    required this.banner,
    required this.name,
    required this.sub_title,
    required this.month_name,
    required this.start_month,
    required this.start_date,
    required this.privacy_settings,
    required this.access_code,
    required this.end_date,
    required this.year,
  });

  Result.fromJson(Map<String, dynamic> json) {
  id = json['id'] ?? 0;
  logo = json['logo'] ?? '';
  banner = json['Banner'] ?? '';
  name = json['name'] ?? '';
  sub_title = json['sub_title'] ?? '';
  month_name = json['month_name'] ?? '';
  start_month = json['start_month'] ?? '';
  start_date = json['start_date'] ?? '';
  privacy_settings = json['privacy_settings'] ?? '';
  access_code = json['access_code'] ?? 0;
  end_date = json['end_date'] ?? '';
  year = json['year'] ?? '';
}

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['logo'] = this.logo;
    data['Banner'] = this.banner;
    data['name'] = this.name;
    data['sub_title'] = this.sub_title;
    data['month_name'] = this.month_name;
    data['start_month'] = this.start_month;
    data['start_date'] = this.start_date;
    data['privacy_settings'] = this.privacy_settings;
    data['access_code'] = this.access_code;
    data['end_date'] = this.end_date;
    data['year'] = this.year;

    return data;
  }
}
