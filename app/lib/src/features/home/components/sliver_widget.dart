import 'package:bossa/src/features/home/components/app_tabs.dart';
import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SliverAppWidget extends StatelessWidget {
  final TabController tabController;
  const SliverAppWidget({super.key, required this.tabController});


  @override
  Widget build(BuildContext context) {

    final themeController = context.watch<ThemeNotifier>();
    
    Color backgroundColor = themeController.themeData.backgroundColor;  

    return SliverAppBar(
        automaticallyImplyLeading: false,
        pinned: true,
        backgroundColor: backgroundColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              child: TabBar(
                  indicatorPadding:
                      const EdgeInsets.all(0.0),
                  indicatorSize: TabBarIndicatorSize.label,
                  labelPadding:
                      const EdgeInsets.only(left: 10.0),
                  controller: tabController,
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
                        text: 'Home'),
                    AppTabs(
                        text: 'Playlists'),
                    AppTabs(
                        text: 'Radios'),
                  ])),
        ),
      );
  }
}