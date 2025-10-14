import 'package:flutter/material.dart';
import 'package:bossa/src/ui/components/global_download_manager.dart';

/// Example of how to integrate the GlobalDownloadManager into your app
///
/// Wrap your main app widget with GlobalDownloadManager to show
/// download progress overlays across all screens
class DownloadIntegrationExample extends StatelessWidget {
  final Widget child;

  const DownloadIntegrationExample({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GlobalDownloadManager(
      child: child,
    );
  }
}

/// Usage example:
/// 
/// In your main.dart or app.dart:
/// 
/// ```dart
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: DownloadIntegrationExample(
///         child: YourMainScreen(),
///       ),
///     );
///   }
/// }
/// ```
/// 
/// Or wrap individual screens:
/// 
/// ```dart
/// class SomeScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return DownloadIntegrationExample(
///       child: Scaffold(
///         // your screen content
///       ),
///     );
///   }
/// }
/// ```