import 'package:auto_size_text/auto_size_text.dart';
import 'package:encoder/encoder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:pomocnik_wokalisty/ads/interstitial_ads_mixin.dart';
import 'package:pomocnik_wokalisty/helpers/local_storage.dart';
import 'package:pomocnik_wokalisty/helpers/localization_manager.dart';
import 'package:pomocnik_wokalisty/modules/client_screen_mode/cubic/client_screen_mode_cubic.dart';
import 'package:pomocnik_wokalisty/socket_connection/cubic/client_cubic/client_cubit.dart';

class ClientScreenMode extends StatefulWidget {
  const ClientScreenMode({super.key});

  @override
  State<ClientScreenMode> createState() => _ClientScreenModeState();
}

class _ClientScreenModeState extends State<ClientScreenMode>
    with InterstitialAds {
  @override
  void initState() {
    super.initState();

    FullScreen.setFullScreen(true);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _checkInitialData(key.currentContext!);
    });

    initializeInterstitialMobileAdsSDK();
  }

  @override
  void deactivate() {
    context.read<ClientCubit>().stop();
    super.deactivate();
  }

  @override
  void dispose() {
    FullScreen.setFullScreen(false);
    interstitialAd?.dispose();
    super.dispose();
  }

  final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClientCubit, ClientState>(
      listener: (context, state) {
        if (state.client.connectionError == true) {
          _showSetIpDialog(
              context,
              LocalizationManager.instance.appLocalization.connectionFailed,
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
            body: _getBody(state)),
      ),
    );
  }

  Widget _getBody(ClientState state) {
    if (state.client.isConnected) {
      var fontSize = LocalStorage.instance.getInt('fontSize') ?? 15;

      return BlocBuilder<ClientScreenModeCubic, ClientScreenModeState>(
        builder: (context, state) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: AutoSizeText(
            state.text,
            style: TextStyle(
                fontSize: fontSize.toDouble(),
                color: Colors.black,
                decoration: TextDecoration.none),
          ),
        ),
      );
    } else {
      return Center(
        child: state.connectionStarted
            ? Text(LocalizationManager.instance.appLocalization.connecting)
            : Text(LocalizationManager.instance.appLocalization.noConnection),
      );
    }
  }

  void _onDataRecived(Uint8List data) {
    var text = String.fromCharCodes(data);
    context.read<ClientScreenModeCubic>().setText(Encoder.decodeString(text));
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
      context: parentContext,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            LocalizationManager.instance.appLocalization.connectionToTheServer,
            style: TextStyle(fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  LocalizationManager
                      .instance.appLocalization.theAddressOfTheLastServerUsedIs,
                  textAlign: TextAlign.center,
                ),
                Text(
                  parentContext.read<ClientCubit>().state.ip,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(LocalizationManager
                    .instance.appLocalization.reuseThisAddress),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(LocalizationManager.instance.appLocalization.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(LocalizationManager.instance.appLocalization.yes),
              onPressed: () {
                try {
                  parentContext.read<ClientCubit>().startConnection(
                      _onDataRecived, _showConnectionErrorToast);
                  Navigator.of(context).pop();
                } catch (e) {
                  _showSetIpDialog(
                      parentContext,
                      LocalizationManager.instance.appLocalization
                          .connectionFailedPleaseReenterIp,
                      parentContext.read<ClientCubit>().state.ip);
                  Navigator.of(context).pop();
                }
              },
            )
          ],
        );
      },
    );
  }

  Future<void> _showSetIpDialog(
      BuildContext parentContext, String? previousError, String? lastIp) {
    return showDialog<void>(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocalizationManager
              .instance.appLocalization.connectionToTheServer),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ListBody(
                  children: <Widget>[
                    TextFormField(
                        initialValue: lastIp,
                        decoration: InputDecoration(
                          hintText: LocalizationManager.instance.appLocalization
                              .enterTheIpFromTheServerSettings,
                          labelText: 'IP',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return LocalizationManager
                                .instance.appLocalization.ipIsRequired;
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
              child: Text(LocalizationManager.instance.appLocalization.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(LocalizationManager.instance.appLocalization.yes),
              onPressed: () {
                try {
                  showInterstitialAds();
                  parentContext.read<ClientCubit>().startConnection(
                      _onDataRecived, _showConnectionErrorToast);

                  FullScreen.setFullScreen(true);

                  Navigator.of(context).pop();
                } catch (e) {
                  _showSetIpDialog(
                      parentContext,
                      LocalizationManager
                          .instance.appLocalization.connectionFailedCheckIp,
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

  void _showConnectionErrorToast(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          LocalizationManager.instance.appLocalization.connectionError(error)),
    ));
  }
}
