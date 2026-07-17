import 'package:flutter/material.dart';
import 'package:bossa/src/services/download_state_manager.dart';
import 'package:bossa/src/ui/components/download_progress_widget.dart';

class GlobalDownloadManager extends StatefulWidget {
  final Widget child;

  const GlobalDownloadManager({
    super.key,
    required this.child,
  });

  @override
  State<GlobalDownloadManager> createState() => _GlobalDownloadManagerState();
}

class _GlobalDownloadManagerState extends State<GlobalDownloadManager> {
  late DownloadStateManager _downloadManager;

  @override
  void initState() {
    super.initState();
    _downloadManager = DownloadStateManager();
    _downloadManager.addListener(_onDownloadStateChanged);
  }

  @override
  void dispose() {
    _downloadManager.removeListener(_onDownloadStateChanged);
    super.dispose();
  }

  void _onDownloadStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeDownloads = _downloadManager.allDownloads.values
        .where((download) =>
            download.status == DownloadStatus.downloading ||
            download.status == DownloadStatus.completed ||
            download.status == DownloadStatus.failed)
        .toList();

    return Stack(
      children: [
        widget.child,
        if (activeDownloads.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: activeDownloads.map((download) {
                  return DownloadProgressWidget(
                    downloadId: download.id,
                    title: 'Download ${download.id}',
                    onCancel: () {
                      _downloadManager.cancelDownload(download.id);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}
