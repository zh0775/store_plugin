library cx_store;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:store_plugin/EventBus.dart';
import 'package:store_plugin/notify_default.dart';
import 'package:store_plugin/third/get/get.dart';
import 'package:store_plugin/cxstore_config.dart';
import 'package:store_plugin/page/store_main.dart';
import 'package:store_plugin/service/user_default.dart';
import 'package:store_plugin/third/pull_refresh/pull_to_refresh.dart';
import 'package:store_plugin/third/screenutil/flutter_screenutil.dart';

class GLObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
  }
}

class CXStore extends StatefulWidget {
  final Map appData;
  final String title;
  final bool needChangeTheme;
  final bool selectContact;
  final Function(dynamic getCtrl)? toAddressPage;
  final Function(dynamic getCtrl, int deliveryType)? toAddressOrContactPage;
  final Function()? alertPayWarn;
  final Function()? backAction;
  final Function(String? aliData)? alipayAction;
  final Function(Map? data)? appUpdate;
  final Function(dynamic errorCode)? toErrorPage;
  final bool hideFilter;
  final int levelType;
  const CXStore({
    super.key,
    this.title = "VIP礼包",
    this.appData = const {},
    this.toAddressPage,
    this.toAddressOrContactPage,
    this.alertPayWarn,
    this.backAction,
    this.alipayAction,
    this.needChangeTheme = true,
    this.selectContact = false,
    this.appUpdate,
    this.hideFilter = false,
    this.toErrorPage,
    this.levelType = 1,
  });

  @override
  State<CXStore> createState() => _CXStoreState();
}

class _CXStoreState extends State<CXStore> {
  @override
  void initState() {
    ScreenUtil.ensureScreenSize();
    CXStoreConfig cxStoreConfig = CXStoreConfig();
    cxStoreConfig.homeData = widget.appData["homeData"];
    cxStoreConfig.publicHomeData = widget.appData["publicHomeData"];
    cxStoreConfig.token = widget.appData["token"];
    cxStoreConfig.version = widget.appData["version"];
    cxStoreConfig.deviceId = widget.appData["deviceId"];
    cxStoreConfig.imageUrl = widget.appData["imageUrl"];
    cxStoreConfig.baseUrl = widget.appData["baseUrl"];
    cxStoreConfig.needChangeTheme = widget.needChangeTheme;
    cxStoreConfig.setThemeColorList();
    // cxStoreConfig.lotteryUrl = widget.appData["lotteryUrl"];
    // cxStoreConfig.privacyUrls = widget.appData["privacyUrls"];
    UserDefault.saveStr(USER_TOKEN, cxStoreConfig.token);
    bus.on(NOTIFY_ALIPAY_ACTION, alipayActionNotify);
    bus.on(NOTIFY_APP_UPDATE, appUpdateNotity);
    bus.on(NOTIFY_TO_ERROR_PAGE, toErrorPageNotify);
    super.initState();
  }

  alipayActionNotify(arg) {
    if (widget.alipayAction != null &&
        arg != null &&
        arg is String &&
        arg.isNotEmpty) {
      widget.alipayAction!(arg);
    }
  }

  appUpdateNotity(arg) {
    if (widget.appUpdate != null) {
      widget.appUpdate!(arg);
    }
  }

  toErrorPageNotify(arg) {
    if (widget.toErrorPage != null) {
      widget.toAddressPage!(arg);
    }
  }

  @override
  void didUpdateWidget(covariant CXStore oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    bus.off(NOTIFY_ALIPAY_ACTION, alipayActionNotify);
    bus.off(NOTIFY_APP_UPDATE, appUpdateNotity);
    bus.off(NOTIFY_TO_ERROR_PAGE, toErrorPageNotify);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      useInheritedMediaQuery: false,
      minTextAdapt: true,
      builder: (context, child) {
        return pullRefresh(
            child: GetMaterialApp(
          key: const ValueKey("_CXStoreState"),

          theme: ThemeData(
            // splashFactory: NoSplashFactory(),
            primarySwatch: Colors.blue,
            splashColor: Colors.transparent,
            scaffoldBackgroundColor: CXStoreConfig.pageBackgroundColor,
            textTheme: TextTheme(bodyText2: TextStyle(fontSize: 15.sp)),
          ),
          navigatorKey: CXStoreConfig.navigatorKey,
          initialRoute: "/store_main",
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.rightToLeft,
          getPages: [
            GetPage(
              name: "/store_main",
              page: () => StoreMain(
                  hideFilter: widget.hideFilter,
                  toAddressOrContactPage: widget.toAddressOrContactPage,
                  title: widget.title,
                  selectContact: widget.selectContact,
                  levelType: widget.levelType,
                  backAction: widget.backAction,
                  toAddressPage: widget.toAddressPage,
                  alertPayWarn: widget.alertPayWarn),
              binding: StoreMainBinding(),
            ),
          ],
          // initialBinding: StoreMainBinding(),
          useInheritedMediaQuery: false,
          enableLog: true,
          title: CXStoreConfig.projectName,
          // home: MainPage(),
          localizationsDelegates: const [
            RefreshLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          supportedLocales: const [Locale("en"), Locale("zh")],

          builder: (context, materialAppChild) {
            return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                    textScaleFactor: kIsWeb ? 1.3 : 1.0, boldText: false),
                child: materialAppChild!);
          },
          navigatorObservers: [GLObserver()],
        ));
      },
    );
  }

  Widget pullRefresh({required Widget child}) {
    return RefreshConfiguration(
      headerBuilder: () =>
          const WaterDropHeader(), // 配置默认头部指示器,假如你每个页面的头部指示器都一样的话,你需要设置这个
      footerBuilder: () => const ClassicFooter(), // 配置默认底部指示器
      headerTriggerDistance: 80.0.w, // 头部触发刷新的越界距离
      springDescription: SpringDescription(
          stiffness: 170.w,
          damping: 16,
          mass: 1.9), // 自定义回弹动画,三个属性值意义请查询flutter api
      maxOverScrollExtent: 100, //头部最大可以拖动的范围,如果发生冲出视图范围区域,请设置这个属性
      maxUnderScrollExtent: 0, // 底部最大可以拖动的范围
      enableScrollWhenRefreshCompleted:
          true, //这个属性不兼容PageView和TabBarView,如果你特别需要TabBarView左右滑动,你需要把它设置为true
      enableLoadingWhenFailed: true, //在加载失败的状态下,用户仍然可以通过手势上拉来触发加载更多
      hideFooterWhenNotFull: false, // Viewport不满一屏时,禁用上拉加载更多功能
      enableBallisticLoad: true, // 可以通过惯性滑动触发加载更多
      child: child,
    );
  }
}
