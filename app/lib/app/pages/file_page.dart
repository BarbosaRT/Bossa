import 'dart:io';

import 'package:bossa/app/components/app_tabs.dart';
import 'package:bossa/app/controllers/file_controller.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class FilePage extends StatefulWidget {
  Directory dir = Directory('');

  FilePage({Key? key}) : super(key: key);

  @override
  State<FilePage> createState() => _FilePageState();
}

class _FilePageState extends State<FilePage>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  late TextEditingController? _titleController;
  late TextEditingController? _authorController;
  String musicPath = '';
  String iconPath = '';

  bool isButtonDisabled = true;
  FileController fileController = FileController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
    _titleController = TextEditingController();
    _authorController = TextEditingController();
    if (widget.dir.path != '') {
      fileController.jsonFile = File("${widget.dir.path}/songs.json");
      fileController.fileExists = fileController.jsonFile.existsSync();
      fileController.dir = widget.dir;
    }
  }

  void onSelectingFile() async {
    final newFile = await fileController.selectFile(FileType.audio);
    if (newFile == null) {
      return;
    }
    setState(() {
      musicPath = newFile.path;
    });
    checkButton();
  }

  void onSelectingIcon() async {
    final newFile = await fileController.selectFile(FileType.image);
    if (newFile == null) {
      return;
    }
    setState(() {
      iconPath = newFile.path;
    });
    checkButton();
  }

  void onAddPressing() {
    checkButton();
    if (isButtonDisabled == false) {
      fileController.saveData(
          musicPath, _authorController!.text, _titleController!.text, iconPath);
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void checkButton() {
    if (musicPath != '' &&
        _titleController!.text != '' &&
        _authorController!.text != '') {
      setState(() {
        isButtonDisabled = false;
      });
    } else {
      setState(() {
        isButtonDisabled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    Color backgroundColor = Theme.of(context).backgroundColor;
    Color widgetColor = Theme.of(context).cardColor;

    TextStyle headline1 = Theme.of(context).textTheme.headline1!;
    TextStyle headline2 =
        Theme.of(context).textTheme.headline2!.copyWith(fontSize: 20);
    TextStyle headline4 = Theme.of(context).textTheme.headline4!;

    return SafeArea(
        child: Scaffold(
            backgroundColor: backgroundColor,
            body: SizedBox(
                height: screenHeight,
                width: screenWidth,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: screenHeight * 0.07,
                        margin: EdgeInsets.only(right: screenWidth * 0.85),
                        child: IconButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/');
                            },
                            icon: const Icon(Icons.arrow_back_ios)),
                      ),
                      // Menu Buttons
                      Expanded(
                        child: NestedScrollView(
                          headerSliverBuilder:
                              (BuildContext context, bool isScroll) {
                            return [
                              SliverAppBar(
                                pinned: true,
                                backgroundColor: backgroundColor,
                                bottom: PreferredSize(
                                  preferredSize: const Size.fromHeight(20),
                                  child: Container(
                                      margin:
                                          const EdgeInsets.only(bottom: 20.0),
                                      child: TabBar(
                                          indicatorPadding:
                                              const EdgeInsets.all(0.0),
                                          indicatorSize:
                                              TabBarIndicatorSize.label,
                                          labelPadding:
                                              const EdgeInsets.only(left: 20.0),
                                          controller: _tabController,
                                          isScrollable: true,
                                          indicator: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  blurRadius: 7,
                                                  offset: const Offset(0, 0),
                                                )
                                              ]),
                                          tabs: const [
                                            AppTabs(
                                                backgroundColor: Colors.blue,
                                                text: 'File'),
                                            AppTabs(
                                                backgroundColor:
                                                    Colors.blueAccent,
                                                text: 'Info'),
                                          ])),
                                ),
                              )
                            ];
                          },
                          controller: _scrollController,
                          body: TabBarView(
                            controller: _tabController,
                            children: [
                              //
                              // File Screen
                              //
                              Scaffold(
                                backgroundColor: backgroundColor,
                                body: SingleChildScrollView(
                                  child: Column(
                                    children: <Widget>[
                                      const SizedBox(
                                        height: 50,
                                      ),
                                      Text(
                                        'Upload your file',
                                        style: headline2,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      GestureDetector(
                                        onTap: onSelectingFile,
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 40.0,
                                                vertical: 20.0),
                                            child: DottedBorder(
                                              borderType: BorderType.RRect,
                                              radius: const Radius.circular(10),
                                              dashPattern: const [10, 10],
                                              strokeCap: StrokeCap.round,
                                              color: Colors.blue.shade400,
                                              child: Container(
                                                width: double.infinity,
                                                height: 150,
                                                decoration: BoxDecoration(
                                                    color: widgetColor
                                                        .withOpacity(.7),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.file_open,
                                                      color: Colors.blue,
                                                      size: 40,
                                                    ),
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                    Text(
                                                      'Select your file',
                                                      style: headline4,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                      ),
                                      Text(
                                        musicPath.split('/')[
                                            musicPath.split('/').length - 1],
                                        style: const TextStyle(
                                            fontSize: 20, fontFamily: 'Avenir'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              //
                              // Info Screen
                              //
                              Scaffold(
                                backgroundColor: backgroundColor,
                                body: ListView(
                                    //crossAxisAlignment: CrossAxisAlignment.center,
                                    //mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      //
                                      // Icon
                                      //
                                      GestureDetector(
                                        onTap: onSelectingIcon,
                                        child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: widgetColor,
                                            ),
                                            height: screenHeight * 0.4,
                                            width: screenHeight * 0.4,
                                            margin: EdgeInsets.symmetric(
                                                horizontal:
                                                    screenHeight * 0.05),
                                            child: ((iconPath == '')
                                                ? Icon(
                                                    Icons.music_note,
                                                    size: screenHeight * 0.3,
                                                  )
                                                : Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        image: DecorationImage(
                                                            image: FileImage(File(
                                                                iconPath))))))),
                                      ),
                                      SizedBox(
                                        height: screenHeight * .03,
                                      ),
                                      //
                                      // Title
                                      //
                                      TextField(
                                        controller: _titleController,
                                        textAlign: TextAlign.center,
                                        textAlignVertical:
                                            TextAlignVertical.bottom,
                                        decoration: const InputDecoration(
                                            // border: OutlineInputBorder(),
                                            border: InputBorder.none,
                                            hintText: "Title",
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: -5)),
                                        style: headline1,
                                        onChanged: (v) {
                                          checkButton();
                                        },
                                      ),
                                      //
                                      // Author
                                      //
                                      TextField(
                                        controller: _authorController,
                                        textAlign: TextAlign.center,
                                        textAlignVertical:
                                            TextAlignVertical.top,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Author",
                                        ),
                                        style: headline2,
                                        onChanged: (v) {
                                          checkButton();
                                        },
                                      ),
                                    ]),
                                floatingActionButton: FloatingActionButton(
                                  backgroundColor: isButtonDisabled
                                      ? Colors.grey.shade400
                                      : Colors.blue,
                                  onPressed:
                                      isButtonDisabled ? null : onAddPressing,
                                  child: const Icon(Icons.add),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]))));
  }
}
