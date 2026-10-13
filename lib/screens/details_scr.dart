import 'package:flutter/material.dart';
import '../models/image_model.dart';

class DetailScreen extends StatefulWidget {


  final ImageModel image;
  final bool isFavorite;

  final VoidCallback onFavoriteTap;

  const DetailScreen(
    {
    super.key,
    required this.image,
    required this.isFavorite,
    required this.onFavoriteTap,
  }
  );

  @override
  State<DetailScreen> createState() => _DetailScreenState();


}

class _DetailScreenState extends State<DetailScreen> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Details'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });

              widget.onFavoriteTap();
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),

          ),
        ],


      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.image.imageUrl,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              
              'Tags: ${widget.image.description}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(

              children: [
                const Icon(Icons.thumb_up, color: Colors.blue),
                const SizedBox(width: 8),
                Text('${widget.image.likes} likes'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}