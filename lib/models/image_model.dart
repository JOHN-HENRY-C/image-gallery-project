
class ImageModel {

  int id;
  String imageUrl;
  String previewUrl;
  String description;
  int likes;

  ImageModel({

    required this.id,
    required this.imageUrl,
    required this.previewUrl,
    required this.description,
    required this.likes,

  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {

    return ImageModel(

      id: json['id'],
      imageUrl: json['largeImageURL'] ?? json['webURL'] ?? '',
      previewUrl: json['webURL'] ?? json['largeImageURL'] ?? '',
      description: json['tags'] ?? 'No description available',
      likes: json['likes'] ?? 0,
    );
    
  }
}
