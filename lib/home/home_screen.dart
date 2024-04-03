import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freshfolds_laundry/home/home_controller.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        /*appBar: AppBar(
          actions: [
            const SizedBox(width: 10),
            _actionButtonWidget(
                onTap: () {
                  controller.goBack();
                },
                icon: Icons.arrow_back_outlined),
            const Spacer(),
            _actionButtonWidget(
                onTap: () {
                  controller.reload();
                },
                icon: Icons.refresh_outlined),
            const Spacer(),
            _actionButtonWidget(
                onTap: () {
                  controller.goForward();
                },
                icon: Icons.arrow_forward_outlined),
            const SizedBox(width: 10),
          ],
        ),*/
        body: SafeArea(
          child: Obx(() => WebViewWidget(
                controller: controller.webController.value,
              )),
        ),
      ),
    );
  }

  Widget _actionButtonWidget(
      {required Function() onTap, required IconData icon}) {
    return InkWell(
        onTap: onTap,
        child: Icon(
          icon,
          size: 35,
          color: Colors.black54,
        ));
  }

  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();
    if (now.difference(controller.currentTime) > const Duration(seconds: 2)) {
      // Add duration of press gap
      controller.currentTime = now;
      Fluttertoast.showToast(msg: 'Tap again to exit');
      return false;
    } else {
      SystemNavigator.pop();
      exit(0);
    }
  }
}
