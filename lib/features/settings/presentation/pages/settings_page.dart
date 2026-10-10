import 'package:cinemix_cert/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/locale_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.languageLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          _LanguageTile(title: l10n.languageSystem, locale: null),
          _LanguageTile(
            title: l10n.languageFrench,
            locale: const Locale('fr'),
          ),
          _LanguageTile(
            title: l10n.languageEnglish,
            locale: const Locale('en'),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.title, required this.locale});

  final String title;
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    final current = context.watch<LocaleCubit>().state;
    final isSelected = current?.languageCode == locale?.languageCode;

    return ListTile(
      title: Text(title),
      selected: isSelected,
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () => context.read<LocaleCubit>().select(locale),
    );
  }
}
