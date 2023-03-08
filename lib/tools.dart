import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:store_plugin/app_color.dart';
import 'package:store_plugin/cxstore_config.dart';
import 'package:store_plugin/third/screenutil/flutter_screenutil.dart';

/// 手机号正则表达式->true匹配
bool isMobilePhoneNumber(String value) {
  RegExp mobile = RegExp(r"(0|86|17951)?(1[0-9][0-9])[0-9]{8}");
  if (value.length == 11) {
    return true;
  } else {
    return false;
  }
  // return mobile.hasMatch(value);
}

// 是否为数字
bool isNumber(String value) {
  RegExp number = new RegExp(r"^[0-9]*[1-9][0-9]*$");
  return number.hasMatch(value);
}

///验证网页URl
bool isUrl(String value) {
  RegExp url = new RegExp(r"^((https|http|ftp|rtsp|mms)?:\/\/)[^\s]+");

  return url.hasMatch(value);
}

///校验身份证
bool isIdCard(String value) {
  RegExp identity = new RegExp(r"\d{17}[\d|x]|\d{15}");

  return identity.hasMatch(value);
}

///正浮点数
bool isMoney(String value) {
  RegExp identity = RegExp(
      r"^(([0-9]+\.[0-9]*[1-9][0-9]*)|([0-9]*[1-9][0-9]*\.[0-9]+)|([0-9]*[1-9][0-9]*))$");
  return identity.hasMatch(value);
}

///校验中文
bool isChinese(String value) {
  RegExp identity = RegExp(r"[\u4e00-\u9fa5]");

  return identity.hasMatch(value);
}

///校验支付宝名称
bool isAliPayName(String value) {
  RegExp identity = RegExp(r"[\u4e00-\u9fa5_a-zA-Z]");

  return identity.hasMatch(value);
}

/// 字符串不为空
bool strNoEmpty(String value) {
  if (value == null) return false;

  return value.trim().isNotEmpty;
}

/// 字符串不为空
bool mapNoEmpty(Map value) {
  if (value == null) return false;
  return value.isNotEmpty;
}

///判断List是否为空
bool listNoEmpty(List list) {
  if (list == null) return false;

  if (list.length == 0) return false;

  return true;
}

/// 判断是否网络
bool isNetWorkImg(String img) {
  return img.startsWith('http') || img.startsWith('https');
}

/// 判断是否资源图片
bool isAssetsImg(String img) {
  return img.startsWith('asset') || img.startsWith('assets');
}

// double getMemoryImageCashe() {
//   return PaintingBinding.instance.imageCache.maximumSize / 1000;
// }

// void clearMemoryImageCache() {
//   PaintingBinding.instance.imageCache.clear();
// }

String stringAsFixed(value, num) {
  double v = double.parse(value.toString());
  String str = ((v * 100).floor() / 100).toStringAsFixed(2);
  return str;
}

String hiddenPhone(String phone) {
  String result = '';

  if (phone != null && phone.length >= 11) {
    String sub = phone.substring(0, 3);
    String end = phone.substring(7, 11);
    result = '$sub****$end';
  }

  return result;
}

String stringTrim(String string) {
  // String str = string.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
  // print('phone === $str');
  return string != null && string.length > 0
      ? string.replaceAll(RegExp(r'\D'), '')
      : '';
}

///去除后面的0
String stringDisposeWithDouble(v, [fix = 2]) {
  double b = double.parse(v.toString());
  String vStr = b.toStringAsFixed(fix);
  int len = vStr.length;
  for (int i = 0; i < len; i++) {
    if (vStr.contains('.') && vStr.endsWith('0')) {
      vStr = vStr.substring(0, vStr.length - 1);
    } else {
      break;
    }
  }

  if (vStr.endsWith('.')) {
    vStr = vStr.substring(0, vStr.length - 1);
  }

  return vStr;
}

///去除小数点
String removeDot(v) {
  String vStr = v.toString().replaceAll('.', '');

  return vStr;
}

class DateTimeForMater {
  static String full = "yyyy-MM-dd HH:mm:ss";

  static String formatDateV(DateTime dateTime, {bool? isUtc, String? format}) {
    if (dateTime == null) return "";
    format = format ?? full;
    if (format.contains("yy")) {
      String year = dateTime.year.toString();
      if (format.contains("yyyy")) {
        format = format.replaceAll("yyyy", year);
      } else {
        format = format.replaceAll(
            "yy", year.substring(year.length - 2, year.length));
      }
    }

    format = _comFormat(dateTime.month, format, 'M', 'MM');
    format = _comFormat(dateTime.day, format, 'd', 'dd');
    format = _comFormat(dateTime.hour, format, 'H', 'HH');
    format = _comFormat(dateTime.minute, format, 'm', 'mm');
    format = _comFormat(dateTime.second, format, 's', 'ss');
    format = _comFormat(dateTime.millisecond, format, 'S', 'SSS');

    return format;
  }

  static String _comFormat(
      int value, String format, String single, String full) {
    if (format.contains(single)) {
      if (format.contains(full)) {
        format =
            format.replaceAll(full, value < 10 ? '0$value' : value.toString());
      } else {
        format = format.replaceAll(single, value.toString());
      }
    }
    return format;
  }
}

String formatTimeStampToString(timestamp, [format]) {
  assert(timestamp != null);

  int time = 0;

  if (timestamp is int) {
    time = timestamp;
  } else {
    time = int.parse(timestamp.toString());
  }

  if (format == null) {
    format = 'yyyy-MM-dd HH:mm:ss';
  }

  DateFormat dateFormat = DateFormat(format);

  var date = new DateTime.fromMillisecondsSinceEpoch(time * 1000);

  return dateFormat.format(date);
}

String timeHandle(int time) {
  double createTimeDouble = strNoEmpty('$time') ? time / 1000 : 0;
  int createTime = int.parse(stringDisposeWithDouble(createTimeDouble));
  return formatTimeStampToString(createTime);
}

String timeToYMD(String dateStr) {
  var date = DateTime.parse(dateStr);
  var formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(date);
}

String getStatusString(int status) {
  switch (status) {
    case 0:
      return '报备';
      break;
    case 5:
      return '接收';
      break;
    case 10:
      return '已带看';
      break;
    case 20:
      return '带看资料';
      break;
    case 22:
      return '预约审核资料';
      break;
    case 24:
      return '成交审核资料';
      break;
    case 21:
      return '预约资料';
      break;
    case 30:
      return '成交资料';
      break;
    case 40:
      return '签约资料';
      break;
    case 50:
      return '结款';
      break;
    case 60:
      return '结佣';
      break;
    case 63:
      return '争议单资料';
      break;
    case 70:
      return '失效';
      break;
    case 80:
      return '退单';
      break;
    default:
      return '其他';
      break;
  }
}

// NumberFormat('0,000').format(widget.data['amount'] ?? 0)
String numberFormat(dynamic number) {
  if (number == null) return '0.00';
  if (number is int || number is double) {
    if (number < 1000) {
      List l2 = number.toString().split('.');
      if (l2.length > 1) {
        return number.toString() + (l2[1].length < 2 ? '0' : '');
      } else {
        return number.toString() + '.00';
      }
    }
    List l = number.toString().split('.');
    if (l.length > 1) {
      String decimals = l[1];
      if (decimals.length < 2) {
        decimals += '0';
      }

      return NumberFormat('0,000').format(int.parse(l[0])).toString() +
          '.' +
          decimals;
    } else {
      return NumberFormat('0,000').format(number) + '.00';
    }
    // List l = number.
  }
  return '0.00';
}

Size calculateTextSize(String value, double fontSize, FontWeight fontWeight,
    double maxWidth, int maxLines, BuildContext context,
    {Color? color}) {
//过滤文本
// value = filterText(value);
//TextPainter

  TextPainter painter = TextPainter(
    ///AUTO：华为手机如果不指定locale的时候，该方法算出来的文字高度是比系统计算偏小的。
    locale: Localizations.localeOf(context),
    // locale: Localizations.localeOf(Global.navigatorKey.currentContext!),
    maxLines: maxLines,
    // textDirection: TextDirection.ltr,
    textDirection: ui.TextDirection.ltr,
    text: TextSpan(
      text: value,
      style: TextStyle(
          fontWeight: fontWeight,
          fontSize: fontSize.sp,
          color: color ?? AppColor.textBlack),
    ),
  );
//设置layout
  painter.layout(maxWidth: maxWidth);
//文字的Size
  return Size(painter.width, painter.height);
}

String formatNum(double num, int postion) {
  if ((num.toString().length - num.toString().lastIndexOf(".") - 1) <=
      postion) {
    //小数点后有几位小数
    // return (num.toStringAsFixed(postion)
    //     .substring(0, num.toString().lastIndexOf(".") + postion + 1)
    //     .toString());
    return num.toString();
  } else {
    return (num.toString()
        .substring(0, num.toString().lastIndexOf(".") + postion + 1)
        .toString());
  }
}

double calculateTextHeight(String value, double fontSize, FontWeight fontWeight,
    double maxWidth, int maxLines, BuildContext context,
    {TextAlign textAlign = TextAlign.center, Color? color}) {
  // value = ui.filterText(value);
  TextPainter painter = TextPainter(

      ///AUTO：华为手机如果不指定locale的时候，该方法算出来的文字高度是比系统计算偏小的。
      locale: Localizations.localeOf(
          // Global.navigatorKey.currentContext!,
          context),
      maxLines: maxLines,
      textAlign: textAlign,
      textDirection: ui.TextDirection.ltr,
      text: TextSpan(
        text: value,
        style: TextStyle(
            fontWeight: fontWeight,
            fontSize: fontSize.sp,
            color: color ?? AppColor.textBlack),
      ));
  painter.layout(maxWidth: maxWidth);

  ///文字的宽度:painter.width
  return painter.height;
}

String copyString(Map reportData) {
  String id = reportData['customerNumber'] != null
      ? ((reportData['customerNumber']).length > 6
          ? (reportData['customerNumber'] as String)
              .substring((reportData['customerNumber']).length - 6)
          : reportData['customerNumber'])
      : '';
  String sex = '';
  if (reportData['customerSex'] != null) {
    if (reportData['customerSex'] == 0 || reportData['customerSex'] == '0') {
      sex = '先生';
    } else if (reportData['customerSex'] == 1 ||
        reportData['customerSex'] == '1') {
      sex = '女士';
    }
  }

  String customerPhone = '';

  if (reportData['showPhone'] != null && reportData['showPhone'] == true) {
    customerPhone = reportData['customerPhone'] ?? '';
  } else {
    customerPhone = reportData['isSensitive'] == 1
        ? hiddenPhone(reportData['customerPhone'])
        : reportData['customerPhone'] ?? '';
  }
  // String copyStr = '''
  // 报备楼盘：${reportData['projectName'] ?? ''}
  // 产品类型：${reportData['purpose'] ?? ''}
  // 报备公司：${reportData['company'] ?? ''}
  // 报备员工：${reportData['employeeName'] ?? ''}
  // 员工电话：${reportData['employeePhone'] ?? ''}
  // 报备客户：${reportData['customerName'] ?? ''}
  // 客户电话：${reportData['customerPhone'] ?? ''}
  // 报备日期：${reportData['createTime'] ?? ''}
  // 身份证后六位（选填）：$id
  // ''';

  String copyStr = '''''';

  copyStr += '''报备楼盘：${reportData['projectName'] ?? ''}\n''';
  // copyStr += '''产品类型：${reportData['purpose'] ?? ''}\n''';
  copyStr += '''报备公司：${reportData['employeeCompany'] ?? ''}\n''';

  copyStr += '''报备员工：${reportData['employeeName'] ?? ''}\n''';
  copyStr += '''员工电话：${reportData['employeePhone'] ?? ''}\n''';
  copyStr += '''报备客户：${(reportData['customerName'] ?? '') + sex}\n''';
  copyStr += '''客户电话：${customerPhone}\n''';
  copyStr += '''报备日期：${reportData['createTime'] ?? ''}\n''';
  copyStr += '''报备服务点：${reportData['deptName'] ?? ''}\n''';
  copyStr += '''备注：${reportData['remarks'] ?? '无'}\n''';
  // copyStr += '''身份证后六位（选填）：$id\n''';
  // copyStr += '产品类型：' + (reportData['purpose'] ?? '' + '\n');
  // copyStr += '报备公司：' + (reportData['company'] ?? '' + '\n');
  // copyStr += '报备员工：' + (reportData['employeeName'] ?? '' + '\n');
  // copyStr += '员工电话：' + (reportData['employeePhone'] ?? '' + '\n');
  // copyStr += '报备客户：' + (reportData['customerName'] ?? '' + '\n');
  // copyStr += '客户电话：' + (reportData['customerPhone'] ?? '' + '\n');
  // copyStr += '报备日期：' + (reportData['createTime'] ?? '' + '\n');
  // copyStr += '身份证后六位（选填）：' + id + '\n';
  if (CXStoreConfig.isDebug) {
    print('copyStr === $copyStr');
  }
  return copyStr;
}

Color getPurposeColor(String purpose) {
  switch (purpose) {
    case '住宅':
      return Color(0x330CBD74);
      break;
    case '商铺':
      return Color(0x33FE6F54);
      break;
    case '公寓':
      return Color(0x331890FF);
      break;
    case '其他':
      return Color(0x33F5A623);
      break;
    default:
      return Color(0x33F5A623);
  }
}

Color getSexBgColor(dynamic sex) {
  int tmpSex;
  if (sex is String) {
    tmpSex = int.parse(sex);
  } else {
    tmpSex = sex;
  }

  switch (tmpSex) {
    case 0:
      return Color(0x3362677D);
      break;
    case 1:
      return Color(0x33FE6F54);
      break;
    default:
      return Color(0x33FE6F54);
  }
}

Color getSexTextColor(dynamic sex) {
  int tmpSex;
  if (sex is String) {
    tmpSex = int.parse(sex);
  } else {
    tmpSex = sex;
  }
  switch (tmpSex) {
    case 0:
      return Color(0xFF62677D);
      break;
    case 1:
      return Color(0xffFE6F54);
      break;
    default:
      return Color(0xffFE6F54);
  }
}
