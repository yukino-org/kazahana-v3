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
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: utils.remToPx(1),
            horizontal: utils.remToPx(1.25),
          ),
          child: Column(
            children: [
              Text(
                "Search",
                style: TextStyle(
                  color: utils.Palette.indigo[500],
                  fontSize: utils.remToPx(1),
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
