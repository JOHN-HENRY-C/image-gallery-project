
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/image_model.dart';

class PixabayService {

  
  String apiKey = '58019261-13c004635d5a86f533fbb5304';

  Future<List<ImageModel>> fetchImages(int page) async {
    String url =
        'https://pixabay.com/api/?key=$apiKey&page=$page&per_page=20&image_type=photo';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final hits = data['hits'];

      if (hits is! List || hits.isEmpty) {
        throw Exception('No images returned from API');
      }

      List<ImageModel> imageList = [];

      for (var image in hits) {
        imageList.add(ImageModel.fromJson(image));
      }

      return imageList;
    } else {
      throw Exception(
        'Failed to load images (HTTP ${response.statusCode})',
      );
    }
  }
}
