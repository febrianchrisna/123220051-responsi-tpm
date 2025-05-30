class Movie {
  final String id;
  final String title;
  final String genre;
  final String releaseDate;
  final double rating;
  final String image;
  final String description;
  final String director;
  final String language;
  final String duration;
  final List<String> cast;

  Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.releaseDate,
    required this.rating,
    required this.image,
    required this.language,
    required this.duration,
    required this.description,
    required this.director,
    required this.cast,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    List<String> castList = [];

    var castData = json['cast'];
    if (castData != null) {
      if (castData is List) {
        castList = castData.map((item) => item.toString()).toList();
      } else if (castData is String) {
        if (castData.isNotEmpty) {
          castList = castData
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      }
    }

    String genreString = '';
    var genreData = json['genre'];
    if (genreData != null) {
      if (genreData is List) {
        genreString = genreData.join(', ');
      } else if (genreData is String) {
        genreString = genreData;
      }
    }

    return Movie(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      genre: genreString,
      releaseDate: json['release_date']?.toString() ??
          json['releaseDate']?.toString() ??
          '',
      rating: _parseDouble(json['rating']),
      image: json['imgUrl']?.toString() ?? json['image']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      director: json['director']?.toString() ?? '',
      cast: castList,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'genre': genre,
      'releaseDate': releaseDate,
      'rating': rating,
      'image': image,
      'description': description,
      'language': language,
      'duration': duration,
      'director': director,
      'cast': cast,
    };
  }
}
