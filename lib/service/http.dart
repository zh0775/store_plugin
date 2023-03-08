import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:store_plugin/EventBus.dart';
import 'package:store_plugin/cxstore_config.dart';
import 'package:store_plugin/notify_default.dart';
import 'package:store_plugin/service/http_config.dart';
import 'package:store_plugin/service/urls.dart';
import 'package:store_plugin/service/user_default.dart';
// import 'package:cxhighversion2/login/user_login.dart';
// import 'package:cxhighversion2/service/http_config.dart';

// import 'package:cxhighversion2/util/app_default.dart';
// import 'package:cxhighversion2/util/storage_default.dart';
// import 'package:cxhighversion2/service/urls.dart';

typedef Success = void Function(dynamic json);
typedef Fail = void Function(String reason, int code, dynamic json);
typedef After = void Function();

_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

class Http {
  Dio dio = Dio();
  static Http? _instance;
  factory Http() => _instance ?? Http._init();
  static bool updateAlertExist = false;
  Http._init() {
    (dio.transformer as DefaultTransformer).jsonDecodeCallback = parseJson;
    dio.options = BaseOptions(
      baseUrl: CXStoreConfig().baseUrl,
      // baseUrl: HttpConfig.baseUrl,
      connectTimeout: HttpConfig.connectTimeout,
      receiveTimeout: HttpConfig.receiveTimeout,
    );

    dio.interceptors.add(InterceptorsWrapper(onRequest: (
      RequestOptions options,
      RequestInterceptorHandler handler,
    ) async {
      if (options.path != Urls.sendCode &&
          options.path != Urls.registStep1 &&
          options.path != Urls.registStep2 &&
          options.path != Urls.registLastStep &&
          options.path != Urls.findPwd &&
          options.path != Urls.login) {
        final appDefault = CXStoreConfig();
        if (appDefault.loginStatus) {
          if (appDefault.token.isNotEmpty) {
            options.headers["token"] = appDefault.token;
          } else {
            options.headers["token"] = await UserDefault.get(USER_TOKEN) ?? "";
            appDefault.token = options.headers["token"];
          }
        } else {
          options.headers["token"] = "";
        }
        if (appDefault.version.isNotEmpty) {
          options.headers["version"] = appDefault.version;
        }
        // options.headers["version"] = "0.0.1";
        // if (AppDefault().versionOrigin != 0) {
        // options.headers["versionOrigin"] = 1;
        options.headers["versionOrigin"] = appDefault.versionOrigin;
        // }
      }

      return handler.next(options);
    }, onResponse: (Response response, ResponseInterceptorHandler handler) {
      if (response.statusCode == 401) {
        ShowToast.normal(response.data["messages"]);
      }
      return handler.next(response);
    }, onError: (DioError e, ErrorInterceptorHandler handler) async {
      if (e.response?.statusCode == 401) {
        int? statusCode = int.tryParse(e.response?.data["value"]);
        if (e.response?.data["value"] == "201") {
          //token验证失败
          // String? token = await UserDefault.get(USER_TOKEN);
          // if (token != null && token.isNotEmpty) {
          //   ShowToast.normal("身份验证失败，请重新登录");
          // }
          // setUserDataFormat(false, {}, {}, {}).then((value) => toLogin());
          bus.emit(NOTIFY_TO_ERROR_PAGE, statusCode);
        } else if (e.response?.data["value"] == "202") {
          //token已经过期
          // ShowToast.normal("身份信息已经过期，请重新登录");
          // setUserDataFormat(false, {}, {}, {}).then((value) => toLogin());
          bus.emit(NOTIFY_TO_ERROR_PAGE, statusCode);
        } else if (e.response?.data["value"] == "203") {
          //您的账号已在其他设备登录
          // ShowToast.normal("您的账号已在其他设备登录");
          // setUserDataFormat(false, {}, {}, {}).then((value) => toLogin());
          bus.emit(NOTIFY_TO_ERROR_PAGE, statusCode);
        } else if (e.response?.data["value"] == "403") {
          // showAppUpdateAlert(e.response?.data);
          // if (e.response != null && e.response?.data["data"] != null) {
          //   await showUpdate(e.response?.data["data"]);
          // }
          //需要更新
          // ShowToast.normal("您的账号已在其他设备登录");
          // setUserDataFormat(false, {}, {}, {}).then((value) => toLogin());
          bus.emit(NOTIFY_APP_UPDATE,
              e.response != null ? e.response!.data["data"] ?? {} : {});
        }
      } else if (e.response?.statusCode == 403) {
        // showAppUpdateAlert(e.response?.data);
        //需要更新
        // if (e.response != null && e.response?.data["data"] != null) {
        //   await showUpdate(e.response?.data["data"]);
        // }

        bus.emit(NOTIFY_APP_UPDATE,
            e.response != null ? e.response!.data["data"] ?? {} : {});
      }
      return handler.next(e);
    }));

    log();
  }

  Future<void> showUpdate(Map? data) async {
    // if (isLoginRoute()) {
    //   return;
    // }
    // if (!updateAlertExist) {
    //   updateAlertExist = true;
    //   showAppUpdateAlert(
    //     data ?? {},
    //     close: () {
    //       updateAlertExist = false;
    //     },
    //   );
    // }
  }

  Future<void> doGet(String url, var params,
      {Success? success, Fail? fail, After? after}) async {
    try {
      await dio.get(url, queryParameters: params).then((response) {
        if (response.statusCode == 200) {
          Map<dynamic, dynamic> data = response.data;
          if (data["success"] != null && data["success"]) {
            if (success != null) {
              success(response.data);
            }
          } else {
            if (fail != null) {
              fail(data["messages"], response.statusCode!, data);
            }
            ShowToast.normal(data["messages"]);
          }
        } else {
          if (fail != null) {
            fail(response.statusMessage!, response.statusCode!,
                response.data ?? {});
          }
          // if (data["messg"]) {

          // }
        }
        if (after != null) {
          after();
        }
      });
    } on DioError catch (e) {
      if (fail != null) {
        if (e.response != null && e.response?.data != null) {
          fail(e.response?.data["messages"],
              int.parse(e.response?.data["value"]), e.response?.data);
        }
      }
    }
  }

  Future<void> getImage(String url, var params,
      {Success? success, Fail? fail, After? after}) async {
    try {
      await dio.get(url, queryParameters: params).then((response) {
        if (response.statusCode == 200) {
          dynamic data = response.data;
          if (success != null) {
            success(data);
          }
        } else {
          if (fail != null) {
            fail(response.statusMessage!, response.statusCode!,
                response.data ?? {});
          }
        }
        if (after != null) {
          after();
        }
      });
    } on DioError catch (e) {
      if (fail != null) {
        if (e.response != null && e.response?.data != null) {
          fail(e.response!.statusMessage!, e.response!.statusCode!,
              e.response!.data ?? {});
        }
      }
    }
  }

  Future<void> doDelete(String url, dynamic data,
      {Success? success, Fail? fail, After? after}) async {
    try {
      await dio.delete(url).then((response) {
        if (response.statusCode == 200) {
          Map<String, dynamic> data = response.data;

          // if (data['code'] != 200) {
          //   if (data['msg'] != null) {
          //     // ShowToast.normal(data['msg']);
          //   }
          // }
          // if (success != null) {
          //   success(response.data);
          // }
          if (data["success"] != null && data["success"]) {
            if (success != null) {
              success(response.data);
            }
          } else {
            if (fail != null) {
              fail(data["messages"], response.statusCode!, data);
            }
            ShowToast.normal(data["messages"]);
          }
        } else {
          if (fail != null) {
            fail(response.statusMessage!, response.statusCode!,
                response.data ?? {});
          }
        }
        if (after != null) {
          after();
        }
      });
    } on DioError catch (e) {
      if (fail != null) {
        if (e.response != null && e.response?.data != null) {
          fail(e.response?.data["messages"],
              int.parse(e.response?.data["value"]), e.response?.data);
        }
      }
    }
  }

  Future<void> doPost(String url, Map<String, dynamic> params,
      {Success? success,
      Fail? fail,
      After? after,
      CancelToken? cancelToken,
      dynamic otherData}) async {
    try {
      await dio
          .post(url,
              data: json.encode(otherData ?? params), cancelToken: cancelToken)
          .then((response) {
        if (response.statusCode == 200) {
          Map<String, dynamic> data = response.data;
          if (data["success"] != null && data["success"]) {
            if (success != null) {
              success(response.data);
            }
          } else {
            if (fail != null) {
              fail(data["messages"] ?? "", response.statusCode!, data);
            }
            ShowToast.normal(data["messages"] ?? "");
          }
        } else {
          if (fail != null) {
            fail(response.statusMessage!, response.statusCode!,
                response.data ?? {});
          }
        }
        if (after != null) {
          after();
        }
      });
    } on DioError catch (e) {
      if (after != null) {
        after();
      }
      if (fail != null) {
        if (e.response != null &&
            e.response!.data != null &&
            e.response!.data is Map &&
            e.response!.data["messages"] != null) {
          fail(e.response?.data["messages"], e.response?.statusCode ?? 500,
              e.response?.data);
        } else {
          fail(e.message, -1, e.message);
          if (e.type == DioErrorType.connectTimeout) {
            ShowToast.normal("网络连接超时");
          } else {
            ShowToast.normal(e.message);
          }
        }
      }
    }
  }

  Future<void> custom(String url, Map<String, dynamic> params,
      {Success? success,
      Fail? fail,
      After? after,
      int? timeOut,
      method}) async {
    try {
      await dio.get(url).then((response) {
        if (response.statusCode == 200) {
          if (success != null) {
            success(response.data);
          }
        } else {
          if (fail != null) {
            fail(response.statusMessage!, response.statusCode!,
                response.data ?? {});
          }
        }
        if (after != null) {
          after();
        }
      });
    } on DioError catch (e) {
      handleError(e);

      if (fail != null) {
        if (e.response != null && e.response?.data != null) {
          fail(e.response!.statusMessage ?? '', e.response!.statusCode ?? 0,
              e.response?.data);
        }
      }
    }
  }

  Future<void> downImg(String url, Map<String, dynamic> params,
      {Success? success,
      Fail? fail,
      After? after,
      int? timeOut,
      method}) async {
    try {
      await dio
          .get(url, options: Options(responseType: ResponseType.bytes))
          .then((response) {
        if (response.statusCode == 200) {
          dynamic data = response.data;
          if (success != null) {
            success(response.data);
          }
        } else {
          if (fail != null) {
            fail(response.statusMessage!, response.statusCode!,
                response.data ?? {});
          }
        }
        if (after != null) {
          after();
        }
      });
    } on DioError catch (e) {
      if (fail != null) {
        if (e.response != null && e.response?.data != null) {
          fail(e.response!.statusMessage ?? '', e.response!.statusCode ?? 0,
              e.response?.data);
        }
      }
    }
  }

  // Future<void> uploadImages(List images,
  //     {Function(bool success, List jsons)? resList,
  //     Success? success,
  //     Fail? fail,
  //     After? after}) async {
  //   List<Future> imagesFuture = [];
  //   if (images.length == 1) {
  //     XFile asset = images[0];
  //     // if (userBg) {
  //     //   asset.readAsBytes();
  //     //  byteData = await File(asset.path).readAsBytes();

  //     //   byteData = await asset. getThumbByteData(
  //     //       (asset.originalWidth * 0.3).round(),
  //     //       (asset.originalHeight * 0.3).round(),
  //     //       quality: 30);
  //     // } else {
  //     //   byteData = await asset.getByteData();
  //     // }
  //     // ByteData byteData = await asset.getByteData();
  //     // ByteData byteData = await asset.getThumbByteData(
  //     //     (asset.originalWidth * 0.3).round(),
  //     //     (asset.originalHeight * 0.3).round(),
  //     //     quality: 30);
  //     List<int> imageData = await asset.readAsBytes();

  //     // byteData.buffer.asUint8List();
  //     MultipartFile multipartFile = MultipartFile.fromBytes(
  //       imageData,
  //       filename: asset.name,
  //       // contentType: MediaType.parse('application/octet-stream'),
  //     );
  //     FormData formData = FormData.fromMap({"uploadFile": multipartFile});
  //     // RequestOptions options = RequestOptions();
  //     // options.headers['content-type'] = 'multipart/form-data';

  //     try {
  //       await post(
  //         Urls.uploadUrl,
  //         data: formData,
  //         onSendProgress: (count, total) {
  //           // print("当前进度是 $count 总进度是 $total ---- ${count / total * 100}%");
  //         },
  //       ).then((res) {
  //         if (res.statusCode == 200) {
  //           Map<String, dynamic> data = res.data;
  //           // if (data['success']) {
  //           //   if (data['msg'] != null) {
  //           //     // ShowToast.normal(data['msg']);
  //           //   }
  //           //   if (success != null) {
  //           //     success(response.data);
  //           //   }
  //           // } else {
  //           //   ShowToast.normal(data["messgae"]);
  //           //   if (fail != null) {
  //           //     // fail(data["messgae"]);
  //           //   }
  //           // }
  //           if (data["code"] != null && data["code"] == "0") {
  //             if (success != null) {
  //               success(res.data);
  //             }
  //           } else {
  //             if (fail != null) {
  //               fail(data["msg"], res.statusCode!, data);
  //             }
  //             ShowToast.normal(data["msg"]);
  //           }
  //         } else {
  //           if (fail != null) {
  //             fail(res.statusMessage!, res.statusCode!, res.data ?? {});
  //           }
  //         }
  //         if (after != null) {
  //           after();
  //         }
  //         // if (res.statusCode == 200 && (res.data)['code'] == 200) {
  //         //   // resList([res]);
  //         // }
  //       });
  //     } on DioError catch (e) {
  //       if (fail != null) {
  //         if (e.response != null && e.response?.data != null) {
  //           fail(
  //               e.response?.data["msg"],
  //               e.response != null && e.response!.statusCode != null
  //                   ? e.response!.statusCode!
  //                   : 400,
  //               e.response?.data);
  //         }
  //       }
  //     }
  //   } else {
  //     for (int i = 0; i < images.length; i++) {
  //       XFile asset = images[i];
  //       // ByteData byteData = await asset.getByteData();
  //       // ByteData byteData = await asset.getThumbByteData(
  //       //     (asset.originalWidth * 0.3).round(),
  //       //     (asset.originalHeight * 0.3).round());
  //       // List<int> imageData = byteData.buffer.asUint8List();
  //       List<int> imageData = await asset.readAsBytes();
  //       MultipartFile multipartFile = MultipartFile.fromBytes(
  //         imageData,
  //         filename: asset.name,
  //         // contentType: MediaType.parse('application/octet-stream'),
  //       );
  //       FormData formData = FormData.fromMap({"uploadFile": multipartFile});
  //       imagesFuture.add(post(Urls.uploadUrl, data: formData));
  //     }
  //     try {
  //       Future.wait(imagesFuture).then((values) {
  //         if (resList != null) {
  //           resList(true, values);
  //         }

  //         // print('images---value--- ====$value');
  //       });
  //     } on DioError catch (e) {
  //       handleError(e);
  //       if (resList != null) {
  //         resList(false, []);
  //       }
  //       // print('e ===== $e');
  //     }
  //   }

  //   // try {
  //   //   await _dio
  //   //       .post(Urls.imgUpload, data: json.encode(params))
  //   //       .then((response) {
  //   //     if (response.statusCode == 200) {
  //   //       Map<String, dynamic> data = response.data;
  //   //       if (data['code'] != 200) {
  //   //         ShowToast.normal(data['msg']);
  //   //       }
  //   //       if (success != null) {
  //   //         success(response.data);
  //   //       }
  //   //     } else {
  //   //       if (fail != null) {
  //   //         fail(response.statusMessage, response.statusCode);
  //   //       }
  //   //     }
  //   //     if (after != null) {
  //   //       after();
  //   //     }
  //   //   });
  //   // } catch (e) {
  //   //   if (fail != null) {
  //   //     fail('网络发生错误', -1);
  //   //   }
  //   // }
  // }

  void handleError(DioError e) {}

  void log() {
    dio.interceptors.add(InterceptorsWrapper(onRequest: (
      RequestOptions options,
      RequestInterceptorHandler handler,
    ) {
      if (CXStoreConfig.isDebug) {
        print(
            "\n================================= 请求数据 =================================");
        print("method = ${options.method.toString()}");
        print("url = ${options.uri.toString()}");
        print("headers = ${options.headers}");
        print("params = ${options.queryParameters}");
        print("data = ${options.data}");
      }

      return handler.next(options);
    }, onResponse: (Response response, ResponseInterceptorHandler handler) {
      if (CXStoreConfig.isDebug) {
        print(
            "\n================================= 响应数据开始 =================================");
        print("code = ${response.statusCode}");
        print("data = ${response.data}");
        print("data = ${response.realUri}");
        print(
            "================================= 响应数据结束 =================================\n");
      }

      return handler.next(response);
    }, onError: (DioError e, ErrorInterceptorHandler handler) {
      if (CXStoreConfig.isDebug) {
        print(
            "\n=================================错误响应数据 =================================");
        print("type = ${e.type}");
        print("message = ${e.message}");

        print("url = ${e.requestOptions.uri}");
        // print("stackTrace = ${e.}");
        // print("\n");
      }
      return handler.next(e);
    }));
  }
}

// class OptionInterceptor extends InterceptorsWrapper {
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     // options.headers["token"] = "";
//     options.contentType = Headers.formUrlEncodedContentType;
//     super.onRequest(options, handler);
//     return handler.next(options);
//   }
// }

