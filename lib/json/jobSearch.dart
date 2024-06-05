class JobSearch {
  late num status;
  late String message;
  late List<SeaJob?> user;

  JobSearch(
      {required this.status, required this.message, required this.user});

  JobSearch.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'] ?? '';
    if (json['data'] != null) {
      user = <SeaJob?>[];
      json['data'].forEach((v) {
        user.add(SeaJob?.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
   if (this.user != null) {
      data['data'] = user.map((v) => v?.toJson()).toList();
    }
    return data;
  }
}

class SeaJob {
  final String seajobId;
  final String id;
  final String jobpostId;
  final String seajobCompId;
  final String seajobCompanyName;
  final String seajobCreated;
  final String seajobDesc;

  SeaJob({
    required this.seajobId,
    required this.id,
    required this.jobpostId,
    required this.seajobCompId,
    required this.seajobCompanyName,
    required this.seajobCreated,
    required this.seajobDesc,
  });

  factory SeaJob.fromJson(Map<String, dynamic> json) {
    return SeaJob(
      seajobId: json['seajob_id'],
      id: json['id'],
      jobpostId: json['jobpost_id'],
      seajobCompId: json['seajob_comp_id'],
      seajobCompanyName: json['seajob_company_name'],
      seajobCreated: json['seajob_create_on'],
      seajobDesc: json['seajob_job_description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seajob_id': seajobId,
      'id': id,
      'jobpost_id': jobpostId,
      'seajob_comp_id': seajobCompId,
      'seajob_company_name': seajobCompanyName,
      'seajob_create_on': seajobCreated,
      'seajob_job_description': seajobDesc,
    };
  }
}