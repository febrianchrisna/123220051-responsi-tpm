import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'movie_detail_page.dart';
import 'favorites_page.dart';
import 'login_page.dart';

class MovieListPage extends StatefulWidget {
  final String username;

  const MovieListPage({super.key, required this.username});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  List<Movie> movies = [];
  List<Movie> filteredMovies = [];
  List<String> genres = [];
  String selectedGenre = 'All';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      setState(() => isLoading = true);
      movies = await ApiService.getMovies();
      filteredMovies = movies;
      _extractGenres();
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  _extractGenres() {
    Set<String> genreSet = {'All'};
    for (var movie in movies) {
      genreSet.add(movie.genre);
    }
    genres = genreSet.toList();
  }

  _filterMovies(String genre) {
    setState(() {
      selectedGenre = genre;
      if (genre == 'All') {
        filteredMovies = movies;
      } else {
        filteredMovies = movies.where((movie) => movie.genre == genre).toList();
      }
    });
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, ${widget.username}'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FavoritesPage(username: widget.username),
                ),
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Filter by genre: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedGenre,
                    isExpanded: true,
                    items: genres.map((genre) {
                      return DropdownMenuItem(
                        value: genre,
                        child: Text(genre),
                      );
                    }).toList(),
                    onChanged: (value) => _filterMovies(value!),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadMovies,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredMovies.length,
                      itemBuilder: (context, index) {
                        final movie = filteredMovies[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                movie.image,
                                width: 60,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 60,
                                  height: 80,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.movie),
                                ),
                              ),
                            ),
                            title: Text(
                              movie.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Genre: ${movie.genre}'),
                                Text('Release: ${movie.releaseDate}'),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    Text(' ${movie.rating}/10'),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MovieDetailPage(
                                    movieId: movie.id,
                                    username: widget.username,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
