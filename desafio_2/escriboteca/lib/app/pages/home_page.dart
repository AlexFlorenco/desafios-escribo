import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/loader_spinner.dart';
import '../constants.dart';
import '../repositories/books_repository.dart';
import 'favorites_tab.dart';
import 'library_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Dio dio = Dio();

  late final BooksRepository booksRepository;

  Future<void> deleteAllBooks() async {
    Directory? appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    final dir = Directory(appDocDir!.path);

    if (dir.existsSync()) {
      dir.listSync().forEach((file) {
        if (file.path.endsWith('.epub')) {
          file.deleteSync();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    booksRepository = BooksRepository(dio: dio);
    booksRepository.getBooksAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              actions: [
                GestureDetector(
                    child: const Icon(Icons.delete),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      deleteAllBooks();
                      prefs.clear();
                    })
              ],
              title: const TabBar(
                tabs: [
                  Tab(
                    icon: Icon(Icons.book),
                    text: 'Biblioteca',
                  ),
                  Tab(
                    icon: Icon(Icons.bookmarks),
                    text: 'Favoritos',
                  ),
                ],
                indicatorColor: whiteText,
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: TabBarView(children: [
                booksRepository.isLoading.value
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LoaderSpinner(color: primaryColor),
                          SizedBox(height: 20),
                          Text('Carregando biblioteca...'),
                        ],
                      )
                    : LibraryTab(booksRepository: booksRepository),
                FavoriteTab(booksRepository: booksRepository),
              ]),
            ),
          )),
    );
  }
}
