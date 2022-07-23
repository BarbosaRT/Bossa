import 'dart:io';

import 'package:bossa/src/features/files/components/file_widget.dart';
import 'package:bossa/src/features/files/components/info_widget.dart';
import 'package:bossa/src/features/home/components/app_tabs.dart';
import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  bool isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
  }  

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    final themeController = context.watch<ThemeNotifier>();
    
    Color backgroundColor = themeController.themeData.backgroundColor; 
    Color? iconColor = themeController.textTheme.headline2!.color;  

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
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: iconColor,
                              )),
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
                                                text: 'File'),
                                            AppTabs(
                                                text: 'Info'),
                                          ])),
                                ),
                              )
                            ];
                          },
                          controller: _scrollController,
                          body: TabBarView(
                            controller: _tabController,
                            children: const [
                              FileWidget(),
                              InfoWidget(),
                            ],
                          ),
                        ),
                      ),
                    ]))));
  }
}
