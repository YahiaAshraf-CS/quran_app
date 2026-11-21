class GetTelawaModel {
  final List<Reciters>? reciters;

  GetTelawaModel({this.reciters});

  factory GetTelawaModel.fromJson(Map<String, dynamic> json) {
    final rawReciters = json['reciters'];
    return GetTelawaModel(
      reciters: rawReciters is List
          ? rawReciters
                .map((v) => Reciters.fromJson(v as Map<String, dynamic>))
                .toList()
          : null,
    );
  }
}

class Reciters {
  final int? id;
  final String? name;
  final String? letter;
  final String? date;
  final List<Moshaf>? moshaf;

  Reciters({this.id, this.name, this.letter, this.date, this.moshaf});

  factory Reciters.fromJson(Map<String, dynamic> json) {
    final rawMoshaf = json['moshaf'];
    return Reciters(
      id: json['id'] as int?,
      name: json['name'] as String?,
      letter: json['letter'] as String?,
      date: json['date'] as String?,
      moshaf: rawMoshaf is List
          ? rawMoshaf
                .map((v) => Moshaf.fromJson(v as Map<String, dynamic>))
                .toList()
          : null,
    );
  }
}

class Moshaf {
  final int? id;
  final String? name;
  final int? rewayaId;
  final String? server;
  final int? surahTotal;
  final int? moshafType;
  final String? surahList;

  Moshaf({
    this.id,
    this.name,
    this.rewayaId,
    this.server,
    this.surahTotal,
    this.moshafType,
    this.surahList,
  });

  factory Moshaf.fromJson(Map<String, dynamic> json) {
    return Moshaf(
      id: json['id'] as int?,
      name: json['name'] as String?,
      rewayaId: json['rewaya_id'] as int?,
      server: json['server'] as String?,
      surahTotal: json['surah_total'] as int?,
      moshafType: json['moshaf_type'] as int?,
      surahList: json['surah_list'] as String?,
    );
  }
}
