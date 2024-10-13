import 'package:flutter/material.dart';
import 'package:test_image_loading/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ImageList(),
    );
  }
}

class ImageList extends StatefulWidget {
  const ImageList({super.key});

  @override
  ImageListState createState() => ImageListState();
}

class ImageListState extends State<ImageList> {
  final ScrollController _scrollController = ScrollController();
  final double heightImg = 300; //задается высота картинки
  final double widthImg = 300; // задается ширина картинки
  List<dynamic> imagesList = []; // отображаемый список картинок
  List<dynamic>? imagesGet; // получаемый список картинок
  //perPage -количество картинок на стронице *3-минимальное зачение (согласно документации по API pixabay.com)
  int perPage = 3;
  //page - номер страницы *1- минимальное зачение (согласно документации по API pixabay.com)
  int page = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll); // Инициализация контроллера
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sizeMediaQeury = MediaQuery.of(context).size;
      /* 
      получае размеры области для отображения картнок (в виде сетки)
      полученные размеры делим на размер кртинки и коругляем в нужную сторону
      для width в меньшую сторону, для вместимости картинок по горизонтали
      для height в большу сторону, для вместимости картинок по вертикали
      после чего произведением получаем количество картинок, необходимое для заполнения экрана
      */
      setState(() {
        perPage = ((sizeMediaQeury.width.toInt() / widthImg).floor() *
            /* округляем в меньшую сторону: .floor() */
            (sizeMediaQeury.height.toInt() / heightImg).ceil());
        /* округляем в большую сторону: .ceil() */
        _startApi(); //стартовый зыпуск ApiService
      });
    });
  }

  void _loadImages() {
    //Подсчитываем количество картинок, которое необходимо получить через API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        perPage =
            ((MediaQuery.of(context).size.width.toInt() / widthImg).floor());
        _startApi(); // зыпуск ApiService
      });
    });
  }

  void _startApi() async {
    //делаем запрос на нужное количество картинок perPage, указываем номер страницы page
    imagesGet = await ApiService().gatCoinsList(perPage, page);
    imagesList.addAll(
        imagesGet!); //добавляем полученный список в отображаемый список картинок
    setState(() {
      page++; //каждый раз при вызове startApi() мы будем  добалять к числу страниц единицу
    });
  }

  void _onScroll() {
    //проверка положения скролла, когда упираемся в конец страницы, вызываем _loadImages(); для получения следующего списка картинок
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: List.generate(
                imagesList.length,
                (index) {
                  final url = imagesList[index].previewURL;
                  final likes = imagesList[index].likes;
                  final views = imagesList[index].views;
                  return Column(
                    children: [
                      SizedBox(
                        width: heightImg,
                        height: widthImg,
                        child: Image.network(
                          url.toString(),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        width: heightImg,
                        height: heightImg / 7,
                        color: Colors.grey,
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 16, right: 5),
                              child: Icon(Icons.favorite_border_outlined),
                            ),
                            Text(
                              likes.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  decoration: TextDecoration.none),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 16, right: 5),
                              child: Icon(Icons.remove_red_eye_outlined),
                            ),
                            Text(
                              views.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  decoration: TextDecoration.none),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
