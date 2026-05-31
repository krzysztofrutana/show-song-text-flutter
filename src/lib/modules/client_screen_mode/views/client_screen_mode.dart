import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:encoder/encoder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pomocnik_wokalisty/ads/interstitial_ads_mixin.dart';
import 'package:pomocnik_wokalisty/injection_container.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';
import 'package:pomocnik_wokalisty/modules/client_screen_mode/cubit/client_screen_mode_cubit.dart';
import 'package:pomocnik_wokalisty/modules/presentation/models/send_to_client_model.dart';
import 'package:pomocnik_wokalisty/socket_connection/cubit/client_cubit/client_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientScreenMode extends StatefulWidget {
  const ClientScreenMode({super.key});

  @override
  State<ClientScreenMode> createState() => _ClientScreenModeState();
}

class _ClientScreenModeState extends State<ClientScreenMode>
    with InterstitialAds {
  String _title = "";
  String _clientTextScrollMode = 'horizontal';
  StreamSubscription? _dataSubscription;

  @override
  void initState() {
    super.initState();

    _clientTextScrollMode =
        sl<SharedPreferences>().getString('textScrollMode') ?? 'horizontal';

    FullScreen.setFullScreen(true);

    _dataSubscription = context.read<ClientCubit>().dataStream.listen(
      (data) => _onDataRecived(data as String),
      onError: _showConnectionErrorToast,
    );

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
    _dataSubscription?.cancel();
    FullScreen.setFullScreen(false);
    interstitialAd?.dispose();
    super.dispose();
  }

  final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocListener<ClientCubit, ClientState>(
      listener: (context, state) {
        if (state.connectionError == true) {
          _showSetIpDialog(
            context,
            localizations.connectionFailed,
            context.read<ClientCubit>().state.ip,
          );
        }
      },
      child: BlocBuilder<ClientCubit, ClientState>(
        builder:
            (context, state) => Scaffold(
              key: key,
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              body: _getBody(state, localizations),
            ),
      ),
    );
  }

  Widget _getBody(ClientState state, AppLocalizations localizations) {
    if (state.isConnected) {
      final fontSize = sl<SharedPreferences>().getInt('fontSize') ?? 15;

      return BlocBuilder<ClientScreenModeCubit, ClientScreenModeState>(
        builder:
            (context, state) => Column(
              children: [
                Expanded(
                  child: SizedBox.expand(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: _clientTextScrollMode == 'vertical'
                          ? SingleChildScrollView(
                              child: Text(
                                state.text.isEmpty
                                    ? localizations.noTextToDisplay
                                    : state.text,
                                style: TextStyle(
                                  fontSize: fontSize.toDouble(),
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            )
                          : AutoSizeText(
                              state.text.isEmpty
                                  ? localizations.noTextToDisplay
                                  : state.text,
                              style: TextStyle(
                                fontSize: fontSize.toDouble(),
                                color:
                                    Theme.of(context).textTheme.bodyLarge?.color,
                                decoration: TextDecoration.none,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
      );
    } else {
      return Center(
        child:
            state.connectionStarted
                ? Text(localizations.connecting)
                : Text(localizations.noConnection),
      );
    }
  }

  void _onDataRecived(String data) {
    try {
      final decodedString = Encoder.decodeString(data);
      final Map<String, dynamic> jsonMap = jsonDecode(decodedString);
      final model = SendToClientModel.fromJson(jsonMap);
      context.read<ClientScreenModeCubit>().setText(model.text);

      setState(() {
        _title = model.title;
      });
    } catch (e) {
      debugPrint('Error decoding data: $e');
    }
  }

  Future<void> _checkInitialData(BuildContext context) async {
    if (context.read<ClientCubit>().state.ip != '') {
      return _showReconectDialog(context);
    } else {
      return _showSetIpDialog(context, null, null);
    }
  }

  Future<void> _showReconectDialog(BuildContext parentContext) {
    final localizations = AppLocalizations.of(parentContext)!;
    return showDialog<void>(
      context: parentContext,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            localizations.connectionToTheServer,
            style: const TextStyle(fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  localizations.theAddressOfTheLastServerUsedIs,
                  textAlign: TextAlign.center,
                ),
                Text(
                  parentContext.read<ClientCubit>().state.ip,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(localizations.reuseThisAddress),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(localizations.yes),
              onPressed: () {
                try {
                  parentContext.read<ClientCubit>().startConnection();
                  Navigator.of(context).pop();
                } catch (e) {
                  _showSetIpDialog(
                    parentContext,
                    localizations.connectionFailedPleaseReenterIp,
                    parentContext.read<ClientCubit>().state.ip,
                  );
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
    BuildContext parentContext,
    String? previousError,
    String? lastIp,
  ) {
    final localizations = AppLocalizations.of(parentContext)!;
    return showDialog<void>(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.connectionToTheServer),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ListBody(
                  children: <Widget>[
                    TextFormField(
                      initialValue: lastIp,
                      decoration: InputDecoration(
                        hintText: localizations.enterTheIpFromTheServerSettings,
                        labelText: 'IP',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: () => _showScannerDialog(context),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.ipIsRequired;
                        }
                        return null;
                      },
                      onChanged:
                          (value) =>
                              parentContext.read<ClientCubit>().setIp(value),
                    ),
                    const SizedBox(height: 10.0),
                    DropdownButtonFormField<String>(
                      initialValue: _clientTextScrollMode,
                      decoration: InputDecoration(
                        labelText: localizations.textScrollMode,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'horizontal',
                          child: Text(localizations.textScrollModeHorizontal),
                        ),
                        DropdownMenuItem(
                          value: 'vertical',
                          child: Text(localizations.textScrollModeVertical),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _clientTextScrollMode = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10.0),
                    Visibility(
                      visible: previousError != null,
                      child: Text(
                        previousError ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(localizations.yes),
              onPressed: () {
                try {
                  showInterstitialAds();
                  parentContext.read<ClientCubit>().startConnection();

                  FullScreen.setFullScreen(true);

                  Navigator.of(context).pop();
                } catch (e) {
                  _showSetIpDialog(
                    parentContext,
                    localizations.connectionFailedCheckIp,
                    parentContext.read<ClientCubit>().state.ip,
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showScannerDialog(BuildContext ipDialogContext) {
    showDialog(
      context: ipDialogContext,
      builder:
          (scannerDialogContext) => AlertDialog(
            content: SizedBox(
              width: 300,
              height: 300,
              child: MobileScanner(
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    final code = barcode.rawValue;
                    if (code != null) {
                      context.read<ClientCubit>().setIp(code);
                      Navigator.of(
                        scannerDialogContext,
                      ).pop(); // Zamknij skaner
                      Navigator.of(
                        ipDialogContext,
                      ).pop(); // Zamknij dialog z IP

                      // Automatyczne zatwierdzenie
                      try {
                        showInterstitialAds();
                        context.read<ClientCubit>().startConnection();
                        FullScreen.setFullScreen(true);
                      } catch (e) {
                        _showSetIpDialog(
                          context,
                          AppLocalizations.of(context)!.connectionFailedCheckIp,
                          code,
                        );
                      }
                      break;
                    }
                  }
                },
              ),
            ),
          ),
    );
  }

  void _showConnectionErrorToast(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.connectionError(error)),
      ),
    );
  }
}
