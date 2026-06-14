import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/directories/directories_provider.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/core/model/failures.dart';
import 'package:hiddify/core/router/dialog/dialog_notifier.dart';
import 'package:hiddify/core/widget/adaptive_icon.dart';
import 'package:hiddify/features/app_update/notifier/app_update_notifier.dart';
import 'package:hiddify/features/app_update/notifier/app_update_state.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AboutPage extends HookConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider).requireValue;
    final appInfo = ref.watch(appInfoProvider).requireValue;
    final appUpdate = ref.watch(appUpdateNotifierProvider);

    ref.listen(appUpdateNotifierProvider, (_, next) async {
      if (!context.mounted) return;
      switch (next) {
        case AppUpdateStateAvailable(:final versionInfo) || AppUpdateStateIgnored(:final versionInfo):
          return await ref
              .read(dialogNotifierProvider.notifier)
              .showNewVersion(currentVersion: appInfo.presentVersion, newVersion: versionInfo, canIgnore: false);
        case AppUpdateStateError(:final error):
          return CustomToast.error(t.presentShortError(error)).show(context);
        case AppUpdateStateNotAvailable():
          return CustomToast.success(t.pages.about.notAvailableMsg).show(context);
      }
    });

    final conditionalTiles = [
      if (appInfo.release.allowCustomUpdateChecker)
        ListTile(
          title: Text(t.pages.about.checkForUpdate),
          trailing: switch (appUpdate) {
            AppUpdateStateChecking() => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
            _ => const Icon(FluentIcons.arrow_sync_24_regular),
          },
          onTap: () async {
            await ref.read(appUpdateNotifierProvider.notifier).check();
          },
        ),
      if (PlatformUtils.isDesktop)
        ListTile(
          title: Text(t.pages.about.openWorkingDir),
          trailing: const Icon(FluentIcons.open_folder_24_regular),
          onTap: () async {
            final path = ref.watch(appDirectoriesProvider).requireValue.workingDir.uri;
            await UriUtils.tryLaunch(path);
          },
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("О DimLife"),
        actions: [
          PopupMenuButton(
            icon: Icon(AdaptiveIcon(context).more),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text(t.common.addToClipboard),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: appInfo.format()));
                  },
                ),
              ];
            },
          ),
          const Gap(8),
        ],
      ),
      body: Container(
  decoration: const BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/fon.png'),
      fit: BoxFit.cover,
    ),
  ),
  child: ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const SizedBox(height: 20),

      Center(
  child: Container(
    width: 170,
    height: 170,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.blue,
          blurRadius: 40,
          spreadRadius: 8,
        ),
      ],
    ),
    child: Image.asset(
      'assets/images/dimlife_logo.png',
      fit: BoxFit.contain,
    ),
  ),
),

      const Gap(24),

      Center(
        child: Text(
          "DimLife VPN",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),

      const Gap(8),

      Center(
        child: Text(
          "Версия ${appInfo.presentVersion}",
          style: const TextStyle(color: Colors.white60),
        ),
      ),

      const Gap(4),

      const Center(
        child: Text(
          "Xray • Sing-box",
          style: TextStyle(color: Colors.white38),
        ),
      ),

      const Gap(24),

      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Column(
          children: [
            Text(
              "Современный VPN-клиент",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Безопасный и свободный интернет без ограничений",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),

      const Gap(20),

      ListTile(
        leading: const Icon(FluentIcons.chat_24_regular),
        title: const Text("Telegram"),
        subtitle: const Text("@dimliferu"),
        trailing: const Icon(FluentIcons.open_24_regular),
        onTap: () async {
          await UriUtils.tryLaunch(
            Uri.parse("https://t.me/dimliferu"),
          );
        },
      ),

      ListTile(
        leading: const Icon(FluentIcons.mail_24_regular),
        title: const Text("Поддержка"),
        subtitle: const Text("support@dimlife.ru"),
        trailing: const Icon(FluentIcons.open_24_regular),
        onTap: () async {
          await UriUtils.tryLaunch(
            Uri.parse("mailto:support@dimlife.ru"),
          );
        },
      ),

      ListTile(
        leading: const Icon(FluentIcons.globe_24_regular),
        title: const Text("Сайт"),
        subtitle: const Text("dimlife.ru"),
        trailing: const Icon(FluentIcons.open_24_regular),
        onTap: () async {
          await UriUtils.tryLaunch(
            Uri.parse("https://dimlife.ru"),
          );
        },
      ),

      const SizedBox(height: 40),

const Center(
  child: Text(
    "© 2026 DimLife VPN",
    style: TextStyle(
      color: Colors.white38,
    ),
  ),
),

],
  ),
),
    );
  }
}
