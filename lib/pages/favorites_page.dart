import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/database_helper.dart';
import 'movie_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  final String username;

  const FavoritesPage({super.key, required this.username});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Movie> favoriteMovies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  _loadFavorites() async {
    try {
      setState(() => isLoading = true);
      favoriteMovies = await DatabaseHelper().getFavorites(widget.username);
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

  _removeFromFavorites(Movie movie) async {
    try {
      await DatabaseHelper().removeFromFavorites(movie.id, widget.username);
      _loadFavorites();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Movies'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : favoriteMovies.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No favorite movies yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: favoriteMovies.length,
                itemBuilder: (context, index) {
                  final movie = favoriteMovies[index];
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
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                width: 60,
                                height: 80,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.movie),
                              ),
                        ),
                      ),
                      title: Text(
                        movie.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () => _removeFromFavorites(movie),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => MovieDetailPage(
                                  movieId: movie.id,
                                  username: widget.username,
                                ),
                          ),
                        ).then((_) => _loadFavorites());
                      },
                    ),
                  );
                },
              ),
    );
  }
}
