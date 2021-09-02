class Media {
  Media({
    required final this.id,
    required final this.idMal,
    required final this.titleUserPreferred,
    required final this.type,
    required final this.episodes,
    required final this.coverImageMedium,
    required final this.genres,
    required final this.meanScore,
    required final this.siteUrl,
  });

  factory Media.fromJson(final Map<dynamic, dynamic> json) => Media(
        id: json['id'] as int,
        idMal: json['idMal'] as int,
        titleUserPreferred: json['titleUserPreferred'] as String,
        type: json['type'] as String,
        episodes: json['episodes'] as int,
        coverImageMedium: json['coverImageMedium'] as String,
        genres: json['genres'] as List<String>,
        meanScore: json['meanScore'] as int,
        siteUrl: json['siteUrl'] as String,
      );

  final int id;
  final int idMal;
  final String titleUserPreferred;
  final String type;
  final int? episodes;
  final String coverImageMedium;
  final List<String> genres;
  final int meanScore;
  final String siteUrl;
}
