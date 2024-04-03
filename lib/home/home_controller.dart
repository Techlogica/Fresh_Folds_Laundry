import 'dart:async';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as htmlDom;
import 'package:html/parser.dart' as htmlParser;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeController extends GetxController {
  late DateTime currentTime;
  late Rx<WebViewController> webController = Rx(WebViewController());
  final Completer<WebViewController> completerController =
      Completer<WebViewController>();

  final String replaceHtml = '</head>';
  final String replacedHtml =
      '<style type="text/css">footer {display: none;}.navbar-collapse '
      '{position: fixed;top: 70px;left: 0;padding-left: 15px;'
      'padding-right: 15px;padding-bottom: 15px;width: 75%;height: 100%;'
      'width: 90% !important; -webkit-transition: all 0.4s ease; '
      '-moz-transition: all 0.4s ease;transition: all 0.4s ease;}'
      '.navbar-collapse.collapsing {left: -75%;}.navbar-collapse.show '
      '{left: 0;}nav.navbar.bootsnav ul.nav>li>a {font-size: 18px;}'
      'nav.navbar.bootsnav .navbar-nav>li>a{padding: 25px 0 !important;'
      'border: 0 !important;}nav.navbar.bootsnav.no-full .navbar-collapse'
      '{max-height: none;overflow-y: hidden !important;}nav.navbar'
      '.navbar-default.navbar-regular.navbar-common.bootsnav.view-btn'
      '.on.no-full{position: fixed;}</style></head>';

  RxString changeUrl = ''.obs;

  static const String homeContent = 'homeContent';
  static const String servicesContent = 'servicesContent';
  static const String pricesContent = 'pricesContent';
  static const String reviewsContent = 'reviewsContent';
  static const String faqsContent = 'faqsContent';

  @override
  Future<void> onInit() async {
    super.onInit();
    //await loadLocalWebsite();
    //await downloadWebsiteContent();
    await checkForInternet();
    currentTime = DateTime.now();
    webController.value = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (url) async {
            if (url.url != 'about:blank') {
              webController.value.loadHtmlString(await loadLocalWebsite());
            }
          },
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            changeUrl.value = url;
            print('start url :::: $url');
          },
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(await loadLocalWebsite());
  }

  Future<String> loadLocalWebsite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? htmlContent;

    if (changeUrl.value.contains('/services')) {
      htmlContent = prefs.getString(servicesContent);
    } else if (changeUrl.value.contains('/prices')) {
      htmlContent = prefs.getString(pricesContent);
    } else if (changeUrl.value.contains('/reviews')) {
      htmlContent = prefs.getString(reviewsContent);
    } else if (changeUrl.value.contains('/faqs')) {
      htmlContent = prefs.getString(faqsContent);
    } else {
      htmlContent = prefs.getString(homeContent);
    }
    htmlContent = htmlContent!.replaceAll(replaceHtml, replacedHtml);
    return htmlContent ?? '';
  }

  Future<void> downloadAndStoreContent(String url, String contentKey) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Parse HTML content
      htmlDom.Document document = htmlParser.parse(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(contentKey, document.outerHtml);
    } else {
      throw Exception('Failed to load website content from $url');
    }
  }

  Future<void> downloadWebsiteContent() async {
    await downloadAndStoreContent('https://freshfolds.ae', homeContent);
    await downloadAndStoreContent(
        'https://freshfolds.ae/services/', servicesContent);
    await downloadAndStoreContent(
        'https://freshfolds.ae/prices/', pricesContent);
    await downloadAndStoreContent(
        'https://freshfolds.ae/reviews/', reviewsContent);
    await downloadAndStoreContent('https://freshfolds.ae/faqs/', faqsContent);
  }

  checkForInternet() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.wifi) ||
        connectivity.contains(ConnectivityResult.mobile)) {
      try {
        // Load live website content
        webController.value.loadRequest(Uri.parse('https://freshfolds.ae'));
        await downloadWebsiteContent();
      } catch (e) {
        // Handle download error
        print('Error downloading website content: $e');
        // Load local website content
        webController.value
            .loadRequest(Uri.dataFromString(await loadLocalWebsite()));
      }
    } else {
      // Load local website content
      print('Offline Data ::: ${await loadLocalWebsite()}');
      webController.value.loadHtmlString(await loadLocalWebsite());
    }
  }
}
