//модель класса ImgModel
class ImgModel {
  ImgModel({
    required this.previewURL,
    required this.likes,
    required this.views,
  });

  final String previewURL;
  final int likes;
  final int views;
}
