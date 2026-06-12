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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
  children: [
    Assets.images.logo.svg(
      width: 120,
      height: 120,
    ),

    const Gap(12),

    Text(
      "DimLife",
      style: Theme.of(context).textTheme.headlineSmall,
    ),

    const Gap(4),

    Text(
      "Версия ${appInfo.presentVersion}",
    ),
const Gap(4),

const Text(
  "Xray + Sing-box",
  style: TextStyle(
    color: Colors.grey,
  ),
),
    const Gap(12),

    const Text(
      "Современный VPN-клиент",
      textAlign: TextAlign.center,
    ),

    SizedBox(height: 4),

    const Text(
      "Безопасный и свободный интернет“,
      textAlign: TextAlign.center,
    ),
  ],
),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
  ...conditionalTiles,
  if (conditionalTiles.isNotEmpty) const Divider(),

  ListTile(
    title: const Text("Telegram канал"),
    trailing: const Icon(FluentIcons.open_24_regular),
    onTap: () async {
      await UriUtils.tryLaunch(
        Uri.parse("https://t.me/dimliferu"),
      );
    },
  ),

  ListTile(
    title: const Text("Поддержка"),
    trailing: const Icon(FluentIcons.mail_24_regular),
    onTap: () async {
      await UriUtils.tryLaunch(
        Uri.parse("mailto:support@dimlife.ru"),
      );
    },
  ),
              const Divider(),

const Padding(
  padding: EdgeInsets.symmetric(
    vertical: 24,
  ),
  child: Center(
    child: Text(
      "© 2026 DimLife VPN",
      style: TextStyle(
  color: Colors.white38,
  fontSize: 12,
)
    ),
  ),
),
]),
          ),
        ],
      ),
    );
  }
}
