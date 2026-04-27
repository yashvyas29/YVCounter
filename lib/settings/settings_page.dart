import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yv_counter/common/notification_service.dart';
import 'package:yv_counter/common/snackbar_dialog.dart';
import 'package:yv_counter/data_model/settings_model.dart';
import 'package:yv_counter/l10n/app_localizations.dart';
import 'package:yv_counter/common/google_drive.dart';
import 'package:yv_counter/data_model/user.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _primaryController;
  late TextEditingController _secondaryController;
  late TextEditingController _japsPerMalaController;
  late TextEditingController _dailyTargetController;
  User? _user;
  late GoogleDrive _googleDrive;
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsModel>(context, listen: false);
    _primaryController = TextEditingController(text: settings.primaryLabel);
    _secondaryController = TextEditingController(text: settings.secondaryLabel);
    _japsPerMalaController = TextEditingController(
      text: settings.japsPerMala.toString(),
    );
    _dailyTargetController = TextEditingController(
      text: settings.dailyMalaTarget == 0
          ? ''
          : settings.dailyMalaTarget.toString(),
    );
    GoogleDrive.createFromPlatform().then((gd) {
      _googleDrive = gd;
      _googleDrive.signInSilently().then((_) async {
        final user = await _googleDrive.getUser();
        if (mounted) {
          setState(() {
            _user = user;
          });
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update controllers with localized defaults after context is available
    final settings = Provider.of<SettingsModel>(context, listen: false);
    final localizations = AppLocalizations.of(context);

    if (settings.isPrimaryLabelDefault) {
      _primaryController.text = localizations.mala;
    }
    if (settings.isSecondaryLabelDefault) {
      _secondaryController.text = localizations.jap;
    }
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    _japsPerMalaController.dispose();
    _dailyTargetController.dispose();
    super.dispose();
  }

  Future<void> _toggleGoogleSignIn() async {
    final ctx = context;
    setState(() {
      _isSigningIn = true;
    });

    User? updatedUser;
    try {
      if (_user == null) {
        await _googleDrive.signIn();
      } else {
        await _googleDrive.signOut();
      }
      updatedUser = await _googleDrive.getUser();
    } catch (error) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        showSnackBar(ctx, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
          _user = updatedUser;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.settings)),
      body: Consumer<SettingsModel>(
        builder: (context, settings, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.theme,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(localizations.themeSystem),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(localizations.themeLight),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(localizations.themeDark),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      settings.themeMode = value;
                    }
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  localizations.familyCardColor,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _colorPicker(
                  selected: settings.familyCardColor,
                  onChanged: (color) => settings.familyCardColor = color,
                ),
                const SizedBox(height: 16),
                // Preview how the chosen card color will affect text contrast.
                Builder(
                  builder: (context) {
                    final selectedCard =
                        settings.familyCardColor ?? Theme.of(context).cardColor;
                    final computedText =
                        ThemeData.estimateBrightnessForColor(selectedCard) ==
                            Brightness.dark
                        ? Colors.white
                        : Colors.black;
                    final previewCardColor = settings.familyCardTextSwap
                        ? computedText
                        : selectedCard;
                    final previewTextColor = settings.familyCardTextSwap
                        ? selectedCard
                        : computedText;
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: previewCardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              localizations.familyCardColor,
                              style: TextStyle(color: previewTextColor),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(localizations.reverseCardTextColors),
                  subtitle: Text(
                    localizations.reverseCardTextColorsDescription,
                  ),
                  value: settings.familyCardTextSwap,
                  onChanged: (value) => settings.familyCardTextSwap = value,
                ),
                const SizedBox(height: 24),
                Text(localizations.dailyTarget),
                const SizedBox(height: 8),
                TextField(
                  controller: _dailyTargetController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: localizations.dailyTargetHint,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    settings.dailyMalaTarget = parsed ?? 0;
                  },
                ),
                const SizedBox(height: 24),
                /*
                Text(
                  localizations.reminderEnabled,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                */
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.reminderEnabled),
                  subtitle: Text(localizations.reminderEnabledDescription),
                  value: settings.reminderEnabled,
                  onChanged: (enabled) async {
                    if (enabled) {
                      final granted =
                          await NotificationService.requestPermission();
                      if (!granted) return;
                      settings.reminderEnabled = true;
                      if (!context.mounted) return;
                      final localizations = AppLocalizations.of(context);
                      await NotificationService.scheduleDaily(
                        time: settings.reminderTime,
                        title: localizations.reminderNotificationTitle,
                        body: localizations.reminderNotificationBody,
                      );
                    } else {
                      settings.reminderEnabled = false;
                      await NotificationService.cancel();
                    }
                  },
                ),
                if (settings.reminderEnabled)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(localizations.reminderTime),
                    trailing: TextButton(
                      child: Text(
                        settings.reminderTime.format(context),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: settings.reminderTime,
                        );
                        if (picked == null) return;
                        settings.setReminderTime(picked);
                        if (!context.mounted) return;
                        final localizations = AppLocalizations.of(context);
                        await NotificationService.scheduleDaily(
                          time: picked,
                          title: localizations.reminderNotificationTitle,
                          body: localizations.reminderNotificationBody,
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                Text(localizations.counterLabelPrimary),
                const SizedBox(height: 8),
                TextField(
                  controller: _primaryController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: localizations.mala,
                  ),
                  onChanged: (value) => settings.primaryLabel = value,
                ),
                const SizedBox(height: 16),
                Text(localizations.counterLabelSecondary),
                const SizedBox(height: 8),
                TextField(
                  controller: _secondaryController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: localizations.jap,
                  ),
                  onChanged: (value) => settings.secondaryLabel = value,
                ),
                const SizedBox(height: 16),
                Text(localizations.counterJapsPerMala),
                const SizedBox(height: 8),
                TextField(
                  controller: _japsPerMalaController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: settings.japsPerMala.toString(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null) settings.japsPerMala = parsed;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  localizations.signInToGoogleDrive,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (_user != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(localizations.signedInAs(email: _user!.email)),
                  ),
                ElevatedButton(
                  onPressed: _isSigningIn ? null : _toggleGoogleSignIn,
                  child: Text(
                    _user == null
                        ? localizations.signInToGoogleDrive
                        : AppLocalizations.of(context).signOutFromGD,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'After Sign In you can backup/restore your data from the app menu.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _colorPicker({
    required Color? selected,
    required void Function(Color?) onChanged,
  }) {
    final colors = <Color?>[
      null,
      Colors.white,
      Colors.grey.shade50,
      Colors.blue.shade50,
      Colors.green.shade50,
      Colors.amber.shade50,
      Colors.red.shade50,
      Colors.purple.shade50,
      Colors.yellow.shade50,
      Colors.cyan.shade50,
      Colors.orange.shade50,
      Colors.pink.shade50,
      Colors.brown.shade50,
      Colors.teal.shade50,
      Colors.lime.shade50,
      Colors.indigo.shade50,
      Colors.deepPurple.shade50,
      Colors.deepOrange.shade50,
      Colors.blueGrey.shade50,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        final isSelected = selected == color;
        return GestureDetector(
          onTap: () => onChanged(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color ?? Colors.transparent,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: color == null
                ? const Center(child: Icon(Icons.close, size: 18))
                : null,
          ),
        );
      }).toList(),
    );
  }
}
