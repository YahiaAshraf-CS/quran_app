class GetSuwarModel {
  final List<Suwar>? suwar;

  GetSuwarModel({this.suwar});

  factory GetSuwarModel.fromJson(Map<String, dynamic> json) {
    final rawSuwar = json['suwar'];
    return GetSuwarModel(
      suwar: rawSuwar is List
          ? rawSuwar
              .map((v) => Suwar.fromJson(v as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class Suwar {
  final int? id;
  final String? name;
  final int? startPage;
  final int? endPage;
  final int? makkia;
  final int? type;

  Suwar({
    this.id,
    this.name,
    this.startPage,
    this.endPage,
    this.makkia,
    this.type,
  });

  factory Suwar.fromJson(Map<String, dynamic> json) {
    return Suwar(
      id: json['id'] as int?,
      name: json['name'] as String?,
      startPage: json['start_page'] as int?,
      endPage: json['end_page'] as int?,
      makkia: json['makkia'] as int?,
      type: json['type'] as int?,
    );
  }
}

