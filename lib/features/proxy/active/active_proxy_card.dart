import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/router/dialog/dialog_notifier.dart';
import 'package:hiddify/features/connection/model/connection_status.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hiddify/features/proxy/active/active_proxy_notifier.dart';
import 'package:hiddify/features/proxy/active/ip_widget.dart';
import 'package:hiddify/hiddifycore/generated/v2/hcore/hcore.pb.dart';
import 'package:hiddify/utils/custom_loggers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ActiveProxyFooter extends ConsumerWidget with InfraLogger {
  const ActiveProxyFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(
      connectionNotifierProvider.select((value) => value.valueOrNull ?? const Disconnected()),
    );

    final activeProxy = ref.watch(activeProxyNotifierProvider.select((value) => value.valueOrNull));
    final t = ref.watch(translationsProvider).requireValue;

    // Early return if required data is not available
    if (connectionState != const Connected() || activeProxy == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    // Handle URL test in a way that won't trigger during build
    Future<void> handleUrlTest() async {
      try {
        if (!context.mounted) return;
        await ref.read(activeProxyNotifierProvider.notifier).urlTest("");
      } catch (e) {
        // Handle error here
        loggy.error("Error during URL test: $e");
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.background.withOpacity(1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: theme.colorScheme.secondary.withOpacity(.21), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: InkWell(
        onTap: () {
          context.goNamed('proxies');
        },
        child: Row(
          children: [
            InkWell(
              onTap: () async {
                await handleUrlTest();
                await ref.read(dialogNotifierProvider.notifier).showProxyInfo(outboundInfo: activeProxy);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IPCountryFlag(
                  countryCode: activeProxy.ipinfo.countryCode,
                  organization: activeProxy.ipinfo.org,
                  size: 48,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: t.pages.proxies.activeProxy,
                    child: Text(
                      // getRealOutboundTag(activeProxy),
                      activeProxy.tagDisplay,
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (activeProxy.ipinfo.ip.isNotEmpty)
                        IPText(ip: activeProxy.ipinfo.ip, onLongPress: handleUrlTest, constrained: true)
                      else
                        UnknownIPText(text: t.pages.proxies.unknownIp, onTap: handleUrlTest),
                      const Spacer(),
                      Text(
                        // getRealOutboundTag(activeProxy),
                        activeProxy.type,
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.arrow_forward_ios, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

String getRealOutboundTag(OutboundInfo group) {
  var tag = group.tagDisplay;
  if (group.groupSelectedTagDisplay != "" && group.groupSelectedTagDisplay != tag) {
    tag = "$tag → ${group.groupSelectedTagDisplay}";
  }
  return tag;
}
