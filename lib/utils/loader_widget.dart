import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoaderWidget extends StatelessWidget {
  final Color? color;
  const LoaderWidget({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: Center(
        child: kIsWeb || Platform.isIOS
            ? CupertinoActivityIndicator(
                color: color ?? Theme.of(context).primaryColor)
            : CircularProgressIndicator(
                strokeWidth: 2,
                backgroundColor: color ?? Theme.of(context).primaryColor,
              ),
      ),
    );
  }
}
