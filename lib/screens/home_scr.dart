import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/image_model.dart';
import '../services/services.dart';
import 'details_scr.dart';
import 'fav_scr.dart';
import '../widgets/card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();


}

class _HomeScreenState extends State<HomeScreen> 
{

  final PixabayService service = PixabayService();
  final ScrollController controller = ScrollController();

  List<ImageModel> images = [];
  Set<int> favorites = {};

  int page = 1;
  bool loading = true;
  bool loadingMore = false;
  bool hasMore = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    loadFavorites();
    fetchImages();

    controller.addListener(() {
      if (controller.position.pixels >=
              controller.position.maxScrollExtent - 200 &&
          !loading &&
          !loadingMore &&
          hasMore &&
          error.isEmpty) {
        loadMoreImages();
      }
    });
  }

  Future<void> _refresh() async {
    await fetchImages();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorite_ids') ?? [];

    if (!mounted) return;

    setState(() {
      favorites = ids.map((id) => int.parse(id)).toSet();
    });
  }

  Future<void> toggleFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      if (favorites.contains(id)) {
        favorites.remove(id);
      } else {
        favorites.add(id);
      }
    });

    await prefs.setStringList(
      'favorite_ids',
      favorites.map((id) => id.toString()).toList(),
    );
  }

  Future<void> fetchImages() async {
    try {
      final result = await service.fetchImages(1);

      if (!mounted) return;

      setState(() {
        images = result;
        page = 1;
        loading = false;
        error = '';
        hasMore = result.isNotEmpty;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = 'Failed to load images';
      });
    }
  }

  Future<void> loadMoreImages() async {
    setState(() => loadingMore = true);

    try {
      final nextPage = page + 1;
      final result = await service.fetchImages(nextPage);

      if (!mounted) return;

      setState(() {
        images.addAll(result);
        page = nextPage;
        loadingMore = false;
        hasMore = result.isNotEmpty;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loadingMore = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to load more images'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: loadMoreImages,
          ),
        ),
      );
    }
  }

  void openFavorites() {


    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(
          images: images,
          favoriteIds: favorites,
          onFavoriteTap: toggleFavorite,
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pixabay Gallery'),
        actions: [
          IconButton(
            onPressed: openFavorites,
            icon: const Icon(Icons.favorite),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(error),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            loading = true;
                            error = '';
                          });
                          fetchImages();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : images.isEmpty
                  ? const Center(child: Text('No images found'))
                  : RefreshIndicator(
        onRefresh: _refresh,
        child: GridView.builder(
          controller: controller,
          padding: const EdgeInsets.all(8),
          itemCount: images.length + (loadingMore ? 1 : 0),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,

            childAspectRatio: 1,
          ),


itemBuilder: (context, index) {
            if (index >= images.length) {
              return const SizedBox(
                height: 60,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final image = images[index];
            final isFavorite = favorites.contains(image.id);

            return Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen
                        (

                          image: image,
                          isFavorite: isFavorite,
                          onFavoriteTap: () =>
                              toggleFavorite(image.id),
                        ),
                      ),
                    );
                  },
                  child: CachedNetworkImage(
                    imageUrl: image.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, error, retry) =>
                        const Icon(Icons.broken_image),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    onPressed: () => toggleFavorite(image.id),
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.red,
                    ),

                  ),
                ),

              ],
            );
          },
        ),
        
      ),);
  }
}