import 'dart:io';

import 'package:bossa/app/pages/audio/style2_audio_page.dart';
import 'package:flutter/material.dart';
import 'package:bossa/app/components/app_tabs.dart';
import 'package:bossa/app/pages/audio/style1_audio_page.dart';

class SelectedScreen {
  static String style1 = 'Style1';
  static String style2 = 'Style2';
}

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  String selectedScreen = SelectedScreen.style2;
  List songs = [];

  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    // widget.songController.readData(context);
    //print("$fileExists ${widget.dir.path}/$fileName");
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget nextScreen(BuildContext buildContext, int index) {
    if (widget.selectedScreen == 'Style1') {
      return Style1AudioPage(songs: widget.songs, index: index);
    }

    return Style2AudioPage(
      songs: widget.songs,
      index: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).backgroundColor;
    Color widgetColor = Theme.of(context).cardColor;

    TextStyle headline3 = Theme.of(context).textTheme.headline3!;
    TextStyle headline2 = Theme.of(context).textTheme.headline2!;
    TextStyle headline4 = Theme.of(context).textTheme.headline4!;

    return Container(
        color: backgroundColor,
        child: SafeArea(
          child: Scaffold(
              backgroundColor: backgroundColor,
              body: Column(
                children: [
                  //
                  // Menu items
                  //
                  Container(
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.menu,
                          size: 30,
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, '/file');
                              },
                              icon: const Icon(
                                Icons.add,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, '/settings');
                              },
                              icon: const Icon(
                                Icons.settings,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  //
                  // Your Songs
                  //
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Text(
                          'Your Songs',
                          style: headline2,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  //
                  // Menu Buttons
                  //
                  Expanded(
                    child: NestedScrollView(
                      headerSliverBuilder:
                          (BuildContext context, bool isScroll) {
                        return [
                          SliverAppBar(
                            automaticallyImplyLeading: false,
                            pinned: true,
                            backgroundColor: backgroundColor,
                            bottom: PreferredSize(
                              preferredSize: const Size.fromHeight(50),
                              child: Container(
                                  margin: const EdgeInsets.only(bottom: 20.0),
                                  child: TabBar(
                                      indicatorPadding:
                                          const EdgeInsets.all(0.0),
                                      indicatorSize: TabBarIndicatorSize.label,
                                      labelPadding:
                                          const EdgeInsets.only(left: 10.0),
                                      controller: _tabController,
                                      isScrollable: true,
                                      indicator: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              blurRadius: 7,
                                              offset: const Offset(0, 0),
                                            )
                                          ]),
                                      tabs: const [
                                        AppTabs(
                                            backgroundColor: Colors.orange,
                                            text: 'Home'),
                                        AppTabs(
                                            backgroundColor: Colors.red,
                                            text: 'Playlists'),
                                        AppTabs(
                                            backgroundColor: Colors.blue,
                                            text: 'Radios'),
                                      ])),
                            ),
                          )
                        ];
                      },
                      controller: _scrollController,
                      body: TabBarView(
                        controller: _tabController,
                        children: [
                          ListView.builder(
                              itemCount: widget.songs.length,
                              itemBuilder: (_, i) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                (nextScreen(context, i))));
                                    //Navigator.popAndPushNamed(context, '/player');
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        top: 10,
                                        bottom: 10),
                                    child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: widgetColor,
                                            boxShadow: [
                                              BoxShadow(
                                                blurRadius: 2,
                                                offset: const Offset(0, 0),
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                              )
                                            ]),
                                        child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Row(
                                              children: [
                                                // Icon
                                                Container(
                                                  width: 90,
                                                  height: 120,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      image: DecorationImage(
                                                        image: FileImage(File(
                                                            widget.songs[i]
                                                                ['icon'])),
                                                        fit: BoxFit.cover,
                                                      )),
                                                ),
                                                const SizedBox(width: 10),
                                                // Infos
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Title
                                                    Text(
                                                      widget.songs[i]['title'],
                                                      style: headline3,
                                                    ),
                                                    Text(
                                                        widget.songs[i]
                                                            ['author'],
                                                        style: headline4),
                                                  ],
                                                )
                                              ],
                                            ))),
                                  ),
                                );
                              }),
                          const Material(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey,
                              ),
                              title: Text('WIP'),
                            ),
                          ),
                          const Material(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey,
                              ),
                              title: Text('WIP'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ));
  }
}
