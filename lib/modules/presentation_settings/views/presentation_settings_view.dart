import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/helpers/EventsHub.dart';
import 'package:pomocnik_wokalisty/modules/presentation_settings/cubic/presentation_settings_cubic.dart';
import 'package:pomocnik_wokalisty/modules/presentation_settings/helpers/PresentationSettingsValidator.dart';
import 'package:pomocnik_wokalisty/socket_connection/cubic/server_cubic/server_cubit.dart';

class PresentationSettings extends StatefulWidget
    with PresentationSettingsValidator {
  PresentationSettings({super.key});

  @override
  State<PresentationSettings> createState() => _PresentationSettingsState();
}

class _PresentationSettingsState extends State<PresentationSettings>
    with PresentationSettingsValidator {
  final PresentationSettingsCubic _presentationSettingsCubic =
      PresentationSettingsCubic()..initSettings();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    EventsHub.instance.on('client_connected',
        (String ip) => context.read<ServerCubit>().clientConnected());

    EventsHub.instance.on('client_disconnected',
        (String ip) => context.read<ServerCubit>().clientDisconnected());
  }

  @override
  void deactivate() {
    EventsHub.instance.off<String>(type: 'client_connected');
    EventsHub.instance.off<String>(type: 'client_disconnected');
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            getFormSection(),
            const SizedBox(height: 20.0),
            getServerSection()
          ],
        ));
  }

  InputDecorator getFormSection() {
    return InputDecorator(
        decoration: InputDecoration(
            labelText: "Ekran prezentacji",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            contentPadding:
                EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 50)),
        child: BlocSelector<PresentationSettingsCubic,
            PresentationSettingsStateBase, AutovalidateMode>(
          bloc: _presentationSettingsCubic,
          selector: (state) => state.autovalidateMode,
          builder: (context, AutovalidateMode autovalidateMode) {
            return Form(
              key: _formKey,
              autovalidateMode: autovalidateMode,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: _presentationSettingsCubic.state.fontSize,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) => validateFontSize(value),
                    onChanged: (value) => _onFontSizeChange(value, context),
                    decoration: const InputDecoration(
                      labelText: 'Wielkość czcionki',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  BlocBuilder<PresentationSettingsCubic,
                      PresentationSettingsStateBase>(
                    bloc: _presentationSettingsCubic,
                    buildWhen: (previous, current) =>
                        double.tryParse(current.fontSize) != null,
                    builder: (context, state) => Text(
                      "Taka będzie wielkość czcionki",
                      style: TextStyle(
                          fontSize: double.parse(
                              _presentationSettingsCubic.state.fontSize)),
                    ),
                  )
                ],
              ),
            );
          },
        ));
  }

  BlocBuilder<ServerCubit, ServerStateBase> getServerSection() {
    return BlocBuilder<ServerCubit, ServerStateBase>(
      builder: (context, state) => InputDecorator(
        decoration: InputDecoration(
            labelText: "Ustawienia serwera",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            contentPadding:
                EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 30)),
        child: FutureBuilder(
            future: state.server.init(),
            builder: (context, snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                child = Column(children: [
                  Text("Aktualne IP:"),
                  Text(
                    state.server.ip ?? 'Hotspot Wifi wyłączony',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10.0),
                  state.server.serverStarted
                      ? Text(
                          'Liczba podłączonych urządzeń: ${state.server.activeClienst.length}')
                      : Text("Serwer wyłączony"),
                  state.server.serverStarted
                      ? IconButton(
                          iconSize: 40,
                          color: Colors.red,
                          onPressed: context.read<ServerCubit>().stop,
                          icon: Icon(Icons.stop_circle_outlined))
                      : IconButton(
                          iconSize: 40,
                          color: Colors.green,
                          onPressed: context.read<ServerCubit>().start,
                          icon: Icon(Icons.play_arrow_outlined)),
                ]);
              } else if (snapshot.hasError) {
                child = Text('Error: ${snapshot.error}');
              } else {
                child = Text('Ładowanie...');
              }
              return child;
            }),
      ),
    );
  }

  void _onFontSizeChange(String value, BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _presentationSettingsCubic.setFontSize(value);
      _showConfirmSaveToast(context);
    } else {
      _presentationSettingsCubic
          .updateAutovalidateMode(AutovalidateMode.always);
    }
  }

  void _showConfirmSaveToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Ustawienia zostały zapisane'),
    ));
  }
}
