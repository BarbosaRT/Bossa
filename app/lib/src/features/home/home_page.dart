import 'package:bossa/src/features/audio/audio_controller.dart';
import 'package:bossa/src/features/home/components/menu_items.dart';
import 'package:bossa/src/features/home/components/music_container.dart';
import 'package:bossa/src/features/home/components/sliver_widget.dart';
import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeNotifier>();
    final audioController = context.watch<AudioNotifier>();

    audioController.load();
    Color backgroundColor = themeController.themeData.backgroundColor;
    TextStyle? headline2 = themeController.textTheme.headline2;

    return Container(
        color: backgroundColor,
        child: SafeArea(
          child: Scaffold(
              backgroundColor: backgroundColor,
              body: Column(
                children: [
                  const MenuItems(),
                  const SizedBox(height: 10),
                  // Your Songs
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
                  const SizedBox(height: 1),
                  //
                  // Menu Buttons
                  //
                  Expanded(
                    child: NestedScrollView(
                      headerSliverBuilder:
                          (BuildContext context, bool isScroll) {
                        return [
                          SliverAppWidget(tabController: _tabController)
                        ];
                      },
                      controller: _scrollController,
                      body: TabBarView(
                        controller: _tabController,
                        children: const [
                          MusicContainer(),
                          Material(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey,
                              ),
                              title: Text('WIP'),
                            ),
                          ),
                          Material(
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
