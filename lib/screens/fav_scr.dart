
import 'package:flutter/material.dart';
import '../models/image_model.dart';
import 'details_scr.dart';

class FavoritesScreen extends StatefulWidget

 {
  final List<ImageModel> images;
  final Set<int> favoriteIds;


  final Function(int) onFavoriteTap;

  const FavoritesScreen(
    {


    super.key,
    required this.images,
    required this.favoriteIds,
    required this.onFavoriteTap,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();


}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Set<int> favoriteIds;

  @override
  void initState() {


    super.initState();
    favoriteIds = Set<int>.from(widget.favoriteIds);

  }

  @override
  Widget build(BuildContext context) {


    final favoriteImages = widget.images
        .where((image) => favoriteIds.contains(image.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: favoriteImages.isEmpty
          ? const Center(
              child: Text('No favorite images yet'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: favoriteImages.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final image = favoriteImages[index];

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                              image: image,
                              isFavorite: true,
                              onFavoriteTap: () {
                                widget.onFavoriteTap(image.id);

                                setState(() {
                                  favoriteIds.remove(image.id);
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: Image.network(


                        image.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        onPressed: () {
                          widget.onFavoriteTap(image.id);

                          setState(() {
                            favoriteIds.remove(image.id);
                          });
                        },
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            
    );
  }
}
