import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';

const int famiCurrentBuild = 3;
const String famiCurrentVersion = '0.3.0';

const String famiUpdateManifestUrl = String.fromEnvironment(
  'FAMI_UPDATE_MANIFEST_URL',
  defaultValue: '',
);

class UpdateInfo {
  const UpdateInfo({
    required this.build,
    required this.version,
    required this.apkUrl,
    required this.notes,
    required this.requiredUpdate,
    this.sha256,
  });

  final int build;
  final String version;
  final String apkUrl;
  final String notes;
  final bool requiredUpdate;
  final String? sha256;

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      build: (json['build'] as num?)?.toInt() ?? 0,
      version: json['version']?.toString() ?? 'Unknown',
      apkUrl: json['apkUrl']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      requiredUpdate: json['required'] == true,
      sha256: json['sha256']?.toString(),
    );
  }
}

class UpdateService {
  static Future<UpdateInfo?> checkForUpdate() async {
    if (famiUpdateManifestUrl.trim().isEmpty) return null;

    try {
      final response = await http
          .get(Uri.parse(famiUpdateManifestUrl))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;

      final info = UpdateInfo.fromJson(decoded);
      if (info.apkUrl.isEmpty || info.build <= famiCurrentBuild) return null;
      return info;
    } catch (_) {
      return null;
    }
  }
}

class UpdateManager {
  static bool _checkedThisSession = false;

  static Future<void> maybePrompt(BuildContext context) async {
    if (_checkedThisSession || !Platform.isAndroid) return;
    _checkedThisSession = true;

    final info = await UpdateService.checkForUpdate();
    if (info == null || !context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: !info.requiredUpdate,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Fami ${info.version} is ready'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A newer version of Fami is available.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              if (info.notes.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(info.notes),
              ],
              const SizedBox(height: 12),
              const Text(
                'The update downloads inside Fami, then Android asks you to confirm installation.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            if (!info.requiredUpdate)
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Later'),
              ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => UpdateCenterScreen(update: info),
                  ),
                );
              },
              child: const Text('Download Update'),
            ),
          ],
        );
      },
    );
  }
}

class UpdateCenterScreen extends StatefulWidget {
  const UpdateCenterScreen({super.key, this.update});

  final UpdateInfo? update;

  @override
  State<UpdateCenterScreen> createState() => _UpdateCenterScreenState();
}

class _UpdateCenterScreenState extends State<UpdateCenterScreen> {
  UpdateInfo? _update;
  bool _checking = false;
  bool _downloading = false;
  String _status = 'Ready';
  double? _progress;

  @override
  void initState() {
    super.initState();
    _update = widget.update;
    if (_update == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    }
  }

  Future<void> _check() async {
    setState(() {
      _checking = true;
      _status = 'Checking…';
    });

    final update = await UpdateService.checkForUpdate();
    if (!mounted) return;

    setState(() {
      _checking = false;
      _update = update;
      _status = update == null ? 'You are up to date' : 'Update available';
    });
  }

  Future<void> _download() async {
    final update = _update;
    if (update == null || !Platform.isAndroid || _downloading) return;

    setState(() {
      _downloading = true;
      _progress = 0;
      _status = 'Starting download…';
    });

    try {
      OtaUpdate()
          .execute(
            update.apkUrl,
            destinationFilename: 'Fami-${update.version}.apk',
            sha256checksum: update.sha256,
          )
          .listen(
        (event) {
          if (!mounted) return;
          final status = event.status.toString().split('.').last;
          final value = event.value;

          if (status == 'DOWNLOADING') {
            final parsed = double.tryParse(value ?? '');
            setState(() {
              _status = 'Downloading…';
              _progress = parsed == null ? null : parsed / 100;
            });
          } else if (status == 'INSTALLING') {
            setState(() {
              _status = 'Opening Android installer…';
              _progress = 1;
            });
          } else if (status.contains('ERROR')) {
            setState(() {
              _status = value?.isNotEmpty == true
                  ? 'Update failed: $value'
                  : 'Update failed';
              _downloading = false;
            });
          } else if (status == 'CANCELED') {
            setState(() {
              _status = 'Update canceled';
              _downloading = false;
            });
          }
        },
        onError: (Object error) {
          if (!mounted) return;
          setState(() {
            _status = 'Update failed';
            _downloading = false;
          });
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = 'Update failed';
        _downloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF98989D)
        : const Color(0xFF6E6E73);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Update'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          _UpdatePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fami',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Installed: v$famiCurrentVersion · build $famiCurrentBuild',
                  style: TextStyle(color: secondary),
                ),
                const SizedBox(height: 18),
                if (_update != null) ...[
                  Text(
                    'v${_update!.version} available',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                    ),
                  ),
                  if (_update!.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(_update!.notes, style: const TextStyle(height: 1.4)),
                  ],
                ] else
                  Text(
                    famiUpdateManifestUrl.isEmpty
                        ? 'Update server not configured yet'
                        : _status,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_downloading) ...[
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 8),
            Text(_status, style: TextStyle(color: secondary)),
            const SizedBox(height: 14),
          ],
          if (_update != null)
            FilledButton.icon(
              onPressed: _downloading ? null : _download,
              icon: const Icon(Icons.system_update_alt_rounded),
              label: Text(_downloading ? 'Downloading…' : 'Download & Install'),
            )
          else
            OutlinedButton.icon(
              onPressed: _checking ? null : _check,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(_checking ? 'Checking…' : 'Check for Updates'),
            ),
          const SizedBox(height: 18),
          Text(
            'Android does not allow a normal sideloaded app to silently replace itself. '
            'Fami can download the APK for you and open the installer directly, but Android still shows a confirmation screen. '
            'The APK must also be signed with the same permanent signing key as the installed version.',
            style: TextStyle(color: secondary, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _UpdatePanel extends StatelessWidget {
  const _UpdatePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: dark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E8EB),
        ),
      ),
      child: child,
    );
  }
}
