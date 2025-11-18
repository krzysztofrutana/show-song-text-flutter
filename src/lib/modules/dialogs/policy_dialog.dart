import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pomocnik_wokalisty/helpers/localization_manager.dart';

class PolicyDialog extends StatelessWidget {
  const PolicyDialog({super.key, this.radius = 8, required this.mdFileName});

  final double radius;
  final String mdFileName;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<String>(
              future: Future.delayed(Duration(milliseconds: 150)).then((value) {
                return rootBundle.loadString('assets/markdown/$mdFileName');
              }),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Markdown(data: snapshot.data!);
                }

                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
          MaterialButton(
            padding: EdgeInsets.all(0),
            color: Colors.red,
            onPressed: () => Navigator.of(context).pop(),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(radius),
                    bottomRight: Radius.circular(radius))),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(radius),
                      bottomRight: Radius.circular(radius))),
              alignment: Alignment.center,
              height: 50,
              width: double.infinity,
              child: Text(
                LocalizationManager.instance.appLocalization.ok,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
