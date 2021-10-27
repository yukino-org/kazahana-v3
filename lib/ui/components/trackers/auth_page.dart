import 'dart:async';
import 'package:flutter/material.dart';
import '../../../modules/helpers/logger.dart';
import '../../../modules/helpers/stateful_holder.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/translator/translator.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    required final this.title,
    required final this.logo,
    required final this.authenticate,
    required final this.logger,
    final Key? key,
  }) : super(key: key);

  final String title;
  final String logo;
  final Future<void> Function() authenticate;
  final Logger logger;

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with DidLoadStater {
  final StatefulHolder<List<InlineSpan>> status =
      StatefulHolder<List<InlineSpan>>(<InlineSpan>[
    TextSpan(text: Translator.t.authenticating()),
  ]);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    doLoadStateIfHasnt();
  }

  @override
  Future<void> load() async {
    try {
      await widget.authenticate();

      if (mounted) {
        setState(() {
          status.resolve(<InlineSpan>[
            TextSpan(text: Translator.t.successfullyAuthenticated()),
          ]);
        });

        Future<void>.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (err, stack) {
      widget.logger.error('Authentication failed: $err', stack);

      if (mounted) {
        setState(() {
          status.fail(
            <InlineSpan>[
              TextSpan(text: Translator.t.authenticationFailed()),
              TextSpan(
                text: '\n${err.toString()}',
                style: TextStyle(
                  color: Theme.of(context).textTheme.caption?.color,
                ),
              ),
            ],
          );
        });
      }
    }
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: remToPx(1),
              horizontal: remToPx(1.25),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(remToPx(1)),
                      child: Image.asset(
                        widget.logo,
                        width: MediaQuery.of(context).size.width >
                                ResponsiveSizes.md
                            ? remToPx(7)
                            : remToPx(5),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: remToPx(2),
                  ),
                  if (!status.hasEnded) ...<Widget>[
                    const CircularProgressIndicator(),
                    SizedBox(
                      height: remToPx(1),
                    ),
                  ],
                  RichText(
                    text: TextSpan(
                      children: status.value,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: remToPx(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
