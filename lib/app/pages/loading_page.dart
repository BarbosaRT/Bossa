import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  void pass() async {
    await getApplicationDocumentsDirectory().then((value) {
      Navigator.of(context).pushReplacementNamed('/');
    });
  }

  @override
  void initState() {
    pass();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).backgroundColor;
    return Scaffold(
      backgroundColor: backgroundColor,
    );
  }
}
