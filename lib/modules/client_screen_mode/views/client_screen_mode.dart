import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomocnik_wokalisty/modules/client_screen_mode/cubic/client_screen_mode_cubic.dart';
import 'package:pomocnik_wokalisty/socket_connection/cubic/client_cubic/client_cubit.dart';

class ClientScreenMode extends StatefulWidget {
  const ClientScreenMode({super.key});

  @override
  State<ClientScreenMode> createState() => _ClientScreenModeState();
}

class _ClientScreenModeState extends State<ClientScreenMode> {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _checkInitialData(key.currentContext!);
    });
  }

  @override
  void deactivate() {
    context.read<ClientCubit>().stop();
    super.deactivate();
  }

  final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientCubit, ClientState>(
      builder: (context, state) => state.client.isConnected
          ? BlocBuilder<ClientScreenModeCubic, ClientScreenModeState>(
              builder: (context, state) => PopScope<Object>(
                onPopInvokedWithResult: (didPop, result) {
                  context.read<ClientCubit>().stop();
                  _checkInitialData(context);
                },
                child: Focus(
                  onKeyEvent: (node, event) {
                    if (event.logicalKey == LogicalKeyboardKey.escape) {
                      context.read<ClientCubit>().stop();
                      _checkInitialData(context);
                      return KeyEventResult.handled;
                    }

                    return KeyEventResult.ignored;
                  },
                  child: SafeArea(
                    child: Scaffold(
                      key: key,
                      // appBar: AppBar(
                      //   leading: IconButton(
                      //     icon: const Icon(Icons.arrow_back, color: Colors.black),
                      //     onPressed: () => Navigator.of(context).pop(),
                      //   ),
                      // ),
                      body: AutoSizeText(
                        state.text,
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            decoration: TextDecoration.none),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : BlocListener<ClientCubit, ClientState>(
              listener: (context, state) {
                if (state.client.connectionError == true) {
                  _showSetIpDialog(context, 'Połączenie nieudane',
                      context.read<ClientCubit>().state.ip);
                }
              },
              child: BlocBuilder<ClientCubit, ClientState>(
                builder: (context, state) => Scaffold(
                  key: key,
                  appBar: AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  body: Center(
                    child: state.connectionStarted
                        ? Text("Trwa łączenie")
                        : Text("Brak połączenia"),
                  ),
                ),
              ),
            ),
    );
  }

  void _onDataRecived(Uint8List data) {
    var text = String.fromCharCodes(data);
    context.read<ClientScreenModeCubic>().setText(text);
  }

  Future<void> _checkInitialData(BuildContext context) async {
    if (context.read<ClientCubit>().state.ip != '') {
      return _showReconectDialog(context);
    } else {
      return _showSetIpDialog(context, null, null);
    }
  }

  Future<void> _showReconectDialog(BuildContext parentContext) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Podłączenie do serwera',
            style: TextStyle(fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Adres ostatnio użytego serwera to:',
                  textAlign: TextAlign.center,
                ),
                Text(
                  parentContext.read<ClientCubit>().state.ip,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Czy ponownie użyć tego adresu?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tak'),
              onPressed: () {
                try {
                  parentContext
                      .read<ClientCubit>()
                      .startConnection(_onDataRecived);
                  Navigator.of(context).pop();
                } catch (e) {
                  _showSetIpDialog(
                      parentContext,
                      'Połączenie nieudane, wprowadź ponownie IP',
                      parentContext.read<ClientCubit>().state.ip);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSetIpDialog(
      BuildContext parentContext, String? previousError, String? lastIp) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Łączenie do serwera'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ListBody(
                  children: <Widget>[
                    TextFormField(
                        initialValue: lastIp,
                        decoration: const InputDecoration(
                          hintText: 'Wprowadź IP z ustawień serwera',
                          labelText: 'Nazwa',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'IP jest wymagane';
                          }
                          return null;
                        },
                        onChanged: (value) =>
                            parentContext.read<ClientCubit>().setIp(value)),
                    const SizedBox(height: 10.0),
                    Visibility(
                        visible: previousError != null,
                        child: Text(previousError ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red)))
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Anuluj'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Tak'),
              onPressed: () {
                try {
                  parentContext
                      .read<ClientCubit>()
                      .startConnection(_onDataRecived);
                  Navigator.of(context).pop();
                } catch (e) {
                  _showSetIpDialog(
                      parentContext,
                      'Połączenie nieudane, sprawdź IP',
                      parentContext.read<ClientCubit>().state.ip);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
