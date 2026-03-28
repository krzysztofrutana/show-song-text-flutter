import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/presentation_settings/cubit/presentation_settings_cubit.dart';
import 'package:pomocnik_wokalisty/modules/presentation_settings/helpers/presentation_settings_validator.dart';
import 'package:pomocnik_wokalisty/socket_connection/cubit/server_cubit/server_cubit.dart';

class PresentationSettings extends StatefulWidget
    with PresentationSettingsValidator {
  PresentationSettings({super.key});

  @override
  State<PresentationSettings> createState() => _PresentationSettingsState();
}

class _PresentationSettingsState extends State<PresentationSettings>
    with PresentationSettingsValidator {
  final PresentationSettingsCubit _presentationSettingsCubit =
      PresentationSettingsCubit()..initSettings();

  @override
  void initState() {
    super.initState();
    context.read<ServerCubit>().refreshIp();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            getFormSection(context),
            const SizedBox(height: 20.0),
            getServerSection(context)
          ],
        ));
  }

  InputDecorator getFormSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return InputDecorator(
        decoration: InputDecoration(
            labelText: localizations.presentationScreen,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            contentPadding:
                const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 50)),
        child: BlocSelector<PresentationSettingsCubit,
            PresentationSettingsStateBase, AutovalidateMode>(
          bloc: _presentationSettingsCubit,
          selector: (state) => state.autovalidateMode,
          builder: (context, AutovalidateMode autovalidateMode) {
            return Form(
              key: _formKey,
              autovalidateMode: autovalidateMode,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: _presentationSettingsCubit.state.fontSize,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) => validateFontSize(value, localizations),
                    onChanged: (value) => _onFontSizeChange(value, context),
                    decoration: InputDecoration(
                      labelText: localizations.fontSize,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  BlocBuilder<PresentationSettingsCubit,
                      PresentationSettingsStateBase>(
                    bloc: _presentationSettingsCubit,
                    buildWhen: (previous, current) =>
                        double.tryParse(current.fontSize) != null,
                    builder: (context, state) => Text(
                      localizations.thisWillBeTheFontSize,
                      style: TextStyle(
                          fontSize: double.parse(
                              _presentationSettingsCubit.state.fontSize)),
                    ),
                  )
                ],
              ),
            );
          },
        ));
  }

  Widget getServerSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocBuilder<ServerCubit, ServerState>(
      builder: (context, state) => InputDecorator(
        decoration: InputDecoration(
            labelText: localizations.serverSettings,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            contentPadding:
                const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 30)),
        child: Column(children: [
          Text(localizations.currentIP),
          Text(
            state.ip ?? localizations.wifiHotspotDisabled,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10.0),
          state.serverStarted
              ? Text(localizations
                  .numberOfConnectedDevices(state.activeClientsCount))
              : Text(localizations.serverDown),
          state.serverStarted
              ? IconButton(
                  iconSize: 40,
                  color: Colors.red,
                  onPressed: () => context.read<ServerCubit>().stop(),
                  icon: const Icon(Icons.stop_circle_outlined))
              : IconButton(
                  iconSize: 40,
                  color: Colors.green,
                  onPressed: () => context.read<ServerCubit>().start(),
                  icon: const Icon(Icons.play_arrow_outlined)),
        ]),
      ),
    );
  }

  void _onFontSizeChange(String value, BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _presentationSettingsCubit.setFontSize(value);
      _showConfirmSaveToast(context);
    } else {
      _presentationSettingsCubit
          .updateAutovalidateMode(AutovalidateMode.always);
    }
  }

  void _showConfirmSaveToast(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(localizations.settingsHaveBeenSaved),
    ));
  }
}
