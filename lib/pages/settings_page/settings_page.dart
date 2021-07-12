import 'package:flutter/material.dart';
import '../../core/utils.dart' as utils;

class Page extends StatefulWidget {
  const Page({Key? key}) : super(key: key);

  @override
  State<Page> createState() => PageState();
}

class PageState extends State<Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: utils.remToPx(1),
            horizontal: utils.remToPx(1.25),
          ),
          child: Column(
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: Theme.of(context).textTheme.headline6?.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
