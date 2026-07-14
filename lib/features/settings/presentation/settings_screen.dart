import 'package:dog_friend_manager/shared/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(
      text: 'http://192.168.11.14:8124/',
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('settings'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        Text('設定とスマホ連携', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 18),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('iPhoneで開く', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text(
                'PCとiPhoneを同じWi-Fiに接続して、下のQRコードを読み取ってください。',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'アクセスURL',
                  helperText: 'Wi-Fiが変わってPCのIPが変わったときはここを書き換えます。',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: QrImageView(
                    data: _urlController.text.trim(),
                    version: QrVersions.auto,
                    size: 220,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.circle,
                      color: Color(0xFF6F5F54),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: Color(0xFF6F5F54),
                    ),
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(40, 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SelectableText(
                _urlController.text.trim(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              const Text('開けないときは:'),
              const SizedBox(height: 6),
              const Text('・iPhoneとPCが同じWi-Fiか確認'),
              const Text('・PC側でサーバーが起動中か確認'),
              const Text('・URL先頭が http:// になっているか確認'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('通知'),
              SizedBox(height: 8),
              Text('・誕生日通知'),
              Text('・半年以上会っていない犬の通知'),
              Text('・イベント前日のチェックイン通知'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('バックアップ'),
              SizedBox(height: 8),
              Text('・クラウド保存'),
              Text('・CSV出力'),
              Text('・データエクスポート'),
              Text('・オフライン利用'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('拡張機能'),
              SizedBox(height: 8),
              Text('・QRコード交換'),
              Text('・名刺交換モード'),
              Text('・お気に入り写真スライドショー'),
              Text('・Face ID対応'),
              Text('・ホーム画面ウィジェット'),
            ],
          ),
        ),
      ],
    );
  }
}
