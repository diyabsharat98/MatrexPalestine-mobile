import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_controller.dart';
import '../../auth/application/auth_controller.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.moreLogoutConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.commonLogout)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authControllerProvider).user;
    final locale = ref.watch(localeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMore)),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(user?.name ?? ''),
            subtitle: Text(user?.roles.join(', ') ?? ''),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.moreLanguage),
            trailing: DropdownButton<String>(
              value: locale.languageCode,
              items: [
                DropdownMenuItem(value: 'ar', child: Text(l10n.moreLanguageArabic)),
                DropdownMenuItem(value: 'en', child: Text(l10n.moreLanguageEnglish)),
              ],
              onChanged: (value) {
                if (value != null) ref.read(localeControllerProvider.notifier).setLocale(value);
              },
            ),
          ),
          if (user?.can('reports.view') == true) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bar_chart_outlined),
              title: Text(l10n.moreReports),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/reports'),
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(l10n.commonLogout, style: const TextStyle(color: Colors.red)),
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }
}
