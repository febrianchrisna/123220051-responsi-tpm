import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String baseUrl =
      'https://681388b3129f6313e2119693.mockapi.io/api/v1/movie';

  static Future<List<Movie>> getMovies() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('Parsed data length: ${data.length}');

        List<Movie> movies = [];
        for (var item in data) {
          try {
            movies.add(Movie.fromJson(item));
          } catch (e) {
            print('Error parsing movie: $e');
            print('Movie data: $item');
          }
        }
        return movies;
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      throw Exception('Error loading movies: $e');
    }
  }

  static Future<Movie> getMovieDetail(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      print('Detail API Response Status: ${response.statusCode}');
      print('Detail API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return Movie.fromJson(data);
      } else {
        throw Exception('Failed to load movie detail: ${response.statusCode}');
      }
    } catch (e) {
      print('Detail API Error: $e');
      throw Exception('Error loading movie detail: $e');
    }
  }
}
