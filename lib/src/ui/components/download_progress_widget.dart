import 'package:flutter/material.dart';
import 'package:bossa/src/services/download_state_manager.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';

class DownloadProgressWidget extends StatefulWidget {
  final String downloadId;
  final String title;
  final VoidCallback? onCancel;

  const DownloadProgressWidget({
    super.key,
    required this.downloadId,
    required this.title,
    this.onCancel,
  });

  @override
  State<DownloadProgressWidget> createState() => _DownloadProgressWidgetState();
}

class _DownloadProgressWidgetState extends State<DownloadProgressWidget> {
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
    final colorController = Modular.get<ColorController>();
    final accentColor = colorController.currentTheme.accentColor;
    final contrastColor = colorController.currentTheme.contrastColor;
    final backgroundAccent = colorController.currentTheme.backgroundAccent;

    final downloadState = _downloadManager.getDownloadState(widget.downloadId);

    if (downloadState == null || downloadState.status == DownloadStatus.idle) {
      return const SizedBox.shrink();
    }

    final progress = downloadState.progress;
    final status = downloadState.status;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style:
                      TextStyles().boldHeadline2.copyWith(color: contrastColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (status == DownloadStatus.downloading &&
                  widget.onCancel != null)
                IconButton(
                  onPressed: () {
                    _downloadManager.cancelDownload(widget.downloadId);
                    widget.onCancel?.call();
                  },
                  icon: Icon(
                    Icons.close,
                    color: contrastColor,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatusWidget(status, progress, contrastColor, accentColor),
        ],
      ),
    );
  }

  Widget _buildStatusWidget(
    DownloadStatus status,
    double progress,
    Color contrastColor,
    Color accentColor,
  ) {
    switch (status) {
      case DownloadStatus.downloading:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${'downloading'.i18n()}: ${progress.toStringAsFixed(1)}%',
              style: TextStyles().headline2.copyWith(color: contrastColor),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress / 100.0,
              backgroundColor: contrastColor.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ],
        );

      case DownloadStatus.completed:
        return Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'download-complete'.i18n(),
              style: TextStyles().headline2.copyWith(color: Colors.green),
            ),
          ],
        );

      case DownloadStatus.failed:
        return Row(
          children: [
            Icon(
              Icons.error,
              color: Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'download-failed'.i18n(),
                style: TextStyles().headline2.copyWith(color: Colors.red),
              ),
            ),
          ],
        );

      case DownloadStatus.cancelled:
        return Row(
          children: [
            Icon(
              Icons.cancel,
              color: Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'download-cancelled'.i18n(),
              style: TextStyles().headline2.copyWith(color: Colors.orange),
            ),
          ],
        );

      case DownloadStatus.idle:
      default:
        return const SizedBox.shrink();
    }
  }
}
