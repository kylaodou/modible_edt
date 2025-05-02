class SeanceFaiteDto {
  final String? commentaire;

  SeanceFaiteDto({this.commentaire});

  Map<String, dynamic> toJson() {
    return {
      'commentaire': commentaire,
    };
  }

  factory SeanceFaiteDto.fromJson(Map<String, dynamic> json) {
    return SeanceFaiteDto(
      commentaire: json['commentaire'],
    );
  }
}
