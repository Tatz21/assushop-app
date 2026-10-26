import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../state/app_state.dart';

class SyncDialog extends StatefulWidget {
  const SyncDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SyncDialog(),
    );
  }

  @override
  State<SyncDialog> createState() => _SyncDialogState();
}

class _SyncDialogState extends State<SyncDialog> {
  double _progress = 0.0;
  String _statusText = 'Connecting to FMCG Server...';
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _startSync();
  }

  void _startSync() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _progress = 0.3;
      _statusText = 'Uploading 2 Collections...';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _progress = 0.7;
      _statusText = 'Downloading 86 Outlets & Catalogs...';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.syncData();

    if (!mounted) return;
    setState(() {
      _progress = 1.0;
      _statusText = 'Sync Completed Successfully!';
      _isDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.blueLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.cloud_sync_rounded, color: AppColors.blue, size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            'Sync Data',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _statusText,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: AppColors.grayLight,
            valueColor: AlwaysStoppedAnimation<Color>(
              _isDone ? AppColors.green : AppColors.primaryRed,
            ),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(_progress * 100).toInt()}%',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (_isDone)
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
      ],
    );
  }
}
