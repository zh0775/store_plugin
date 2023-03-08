import 'package:store_plugin/EventBus.dart';
import 'package:store_plugin/app_color.dart';
import 'package:store_plugin/component/custom_button.dart';
import 'package:store_plugin/cxstore_config.dart';
import 'package:store_plugin/notify_default.dart';
import 'package:store_plugin/third/screenutil/flutter_screenutil.dart';
import 'package:universal_html/js.dart' as js;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tobias/tobias.dart' as tobias;

class CustomAlipay {
  CustomAlipay._internal() {
    init();
  }
  static final CustomAlipay _singleton = CustomAlipay._internal();
  factory CustomAlipay() => _singleton;
  late Dio dio;
  void init() {
    dio = Dio(BaseOptions(
        // headers: {"Access-Control-Allow-Origin": HttpConfig.baseUrl},
        ));
  }

  Future<Map> payAction(String? aliData, {Function()? payBack}) async {
    if (aliData == null || aliData.isEmpty) {
      return {};
    }
    if (kIsWeb) {
      // Response response = await dio.post(
      //   "https://openapi.alipay.com/gateway.do?$aliData",
      // );
      // launchUrl(Uri.parse("https://openapi.alipay.com/gateway.do?$aliData"),
      //     mode: LaunchMode.externalApplication);

      push(
          AlipayWebView(
            url: aliData,
            // url: response.data,
            payBack: payBack,
          ),
          null);

      return {};
    } else {
      return await tobias.aliPay(aliData);
    }
  }
}

class AlipayWebView extends StatefulWidget {
  final String url;
  final Function()? payBack;
  const AlipayWebView({
    Key? key,
    this.url = "",
    this.payBack,
  }) : super(key: key);

  @override
  State<AlipayWebView> createState() => _AlipayWebViewState();
}

class _AlipayWebViewState extends State<AlipayWebView> {
  // late WebViewController webCtrl;

  @override
  void initState() {
    if (kIsWeb) {
      Future.delayed(const Duration(milliseconds: 500), () {
        // bus.emit(NOTIFY_ALIPAY_ACTION, widget.url);
        js.context.callMethod('alipayAction', [widget.url]);
      });

      // WebView.platform = WebWebViewPlatform();
      // ignore: UNDEFINED_PREFIXED_NAME, avoid_dynamic_calls
      // ui.platformViewRegistry.registerViewFactory('AlipayWebView_web',
      //     (int viewId) {
      //   return html.IFrameElement()
      //     ..style.width = '100%'
      //     ..style.height = '100%'
      //     ..srcdoc = widget.url
      //     ..style.border = 'none';
      // });
      // js.context["alyPayNotify"] = (dynamic data) {
      //   print("data === $data");
      // };
      // ignore: UNDEFINED_PREFIXED_NAME, avoid_dynamic_calls
    } else {}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.payBack != null) {
          widget.payBack!();
        }
        return true;
      },
      child: Scaffold(
          appBar: getDefaultAppBar(context, "支付"),
          body: Center(
            child: CustomButton(
                onPressed: () {
                  if (widget.payBack != null) {
                    widget.payBack!();
                  }
                  Navigator.of(context).pop();
                },
                child: SizedBox(
                  width: 375.w,
                  height: 50.w,
                  child: Center(
                      child: getSimpleText("支付完成后点击返回", 20, AppColor.textGrey)),
                )),
          )

          // HtmlElementView(viewType: 'AlipayWebView_web'),
          ),
    );
  }
}
