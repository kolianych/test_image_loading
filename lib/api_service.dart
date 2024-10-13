import 'package:dio/dio.dart';
import 'package:test_image_loading/img_model.dart';

class ApiService {
  Future<List<dynamic>> gatCoinsList(perPage, page) async {
    // на сайте в документации по API указано что минимальное значение per_page (количество результатов на странице) равно 3
    if (perPage < 3) perPage = 3;
    final resronse = await Dio().get(
        //key - уникальный ключ зарегистрированного пользователя
        //page - номер страницы
        //per_page - количество картинок на стронице
        'https://pixabay.com/api/?key=46474883-c8425a791d2393d07fa9b4736&page=$page&per_page=$perPage');

    final dataResronse = resronse.data as Map<String, dynamic>;
    final data = dataResronse['hits'];

    /*из полученного ответа мы берем:
    previewURL - URL картинкиж
    likes - количество лайков картинки
    views - количество просмотров картинки*/
    final dataList = data
        .map((e) => ImgModel(
              previewURL: e['previewURL'],
              likes: e['likes'],
              views: e['views'],
            ))
        .toList();

    return dataList;
  }
}
