import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class MovieDetailPage extends StatefulWidget {
  final String movieId;
  final String username;

  const MovieDetailPage({
    super.key,
    required this.movieId,
    required this.username,
  });

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  Movie? movie;
  bool isLoading = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadMovieDetail();
  }

  _loadMovieDetail() async {
    try {
      setState(() => isLoading = true);
      movie = await ApiService.getMovieDetail(widget.movieId);
      isFavorite = await DatabaseHelper().isFavorite(
        widget.movieId,
        widget.username,
      );
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

  _toggleFavorite() async {
    if (movie == null) return;

    try {
      if (isFavorite) {
        await DatabaseHelper().removeFromFavorites(
          widget.movieId,
          widget.username,
        );
        setState(() => isFavorite = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from favorites'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        await DatabaseHelper().addToFavorites(movie!, widget.username);
        setState(() => isFavorite = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to favorites'),
              backgroundColor: Colors.green,
            ),
          );
        }
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
        title: Text(movie?.title ?? 'Movie Detail'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : movie == null
              ? const Center(child: Text('Movie not found'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 300,
                        width: double.infinity,
                        child: Image.network(
                          movie!.image,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('Image loading error: $error');
                            print('Image URL: ${movie!.image}');
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.movie,
                                      size: 100, color: Colors.grey),
                                  Text('Image not available',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie!.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber),
                                    Text(' ${movie!.rating}/10'),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(movie!.genre),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(movie!.duration),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow('Release Date', movie!.releaseDate),
                            _buildInfoRow('Director', movie!.director),
                            _buildInfoRow('Language', movie!.language),
                            const SizedBox(height: 16),
                            const Text(
                              'Cast',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: movie!.cast.map((actor) {
                                return Chip(label: Text(actor));
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              movie!.description,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
