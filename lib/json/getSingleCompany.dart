
class SingleCompany {
  late num status;
  late String message;
  late Result? user;

  SingleCompany(
      {required this.status, required this.message, required this.user});

  SingleCompany.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'] ?? '';
    user = json['company_data'] != null ? new Result.fromJson(json['company_data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.user != null) {
      data['company_data'] = this.user?.toJson();
    }
    return data;
  }
}


class Result {
  final String seajobId;
  final String jobpostId;
  final String seajobCompId;
  final String seajobCompanyName;
  final String seajobCreated;
  final String seajobDesc;

  Result({
    required this.seajobId,
    required this.jobpostId,
    required this.seajobCompId,
    required this.seajobCompanyName,
    required this.seajobCreated,
    required this.seajobDesc,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      seajobId: json['seajob_id'],
      jobpostId: json['jobpost_id'],
      seajobCompId: json['seajob_comp_id'],
      seajobCompanyName: json['company_name'],
      seajobCreated: json['seajob_create_on'],
      seajobDesc: json['apply_rank'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seajob_id': seajobId,
      'jobpost_id': jobpostId,
      'seajob_comp_id': seajobCompId,
      'company_name': seajobCompanyName,
      'seajob_create_on': seajobCreated,
      'apply_rank': seajobDesc,
    };
  }
}