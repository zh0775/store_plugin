class Urls {
  static const homeData = "/api/Home/User_HomeData";
  static const publicHomeData = "/api/UserLogin/User_PublicHomeData";

  //注册 登录 忘记密码
  // 发送验证码（登录前）sendType 1.登录 2.登录异常 3.注册 4.修改密码 5.修改支付密码或手机号
  static const sendCode = "/api/SendCode/SendCode";
  // 发送验证码（登录后）type 1.登录 2.登录异常 3.注册 4.修改密码 5.信息变更
  static const sendCodeAfterLogin = "/api/SendCode/SendCodeByLogin";
  // 注册第一步
  static const registStep1 = "/api/UserLogin/User_ApplicationStep1";
  // 注册第二步
  static const registStep2 = "/api/UserLogin/User_ApplicationStep2";
  // 注册最后一步
  static const registLastStep = "/api/UserLogin/User_Application";
  // 找回密码
  static const findPwd = "/api/UserLogin/User_FindPwd";
  // 登录
  static const login = "/api/UserLogin/Login";
  //获取协议 1.注册协议 2.购买VIP协议 3.隐私协议 7.热门问题 8.文案分享
  static String userHelpList(int type) => "/api/BuyMember/User_HelpList/$type";

// /api/UserLogin/AgreementListByID
  static String agreementListByID(int id) =>
      "/api/UserLogin/AgreementListByID/$id";
  // 枚举字典
  static const enumMapList = "/api/DefaultSelect/GetEnumDictionaryList/";
  // 根据枚举名获取枚举列表
  static const enumList = "/api/DefaultSelect/GetEnumList/";

  ////首页
  // 我的消息列表
  static const myMessage = "/api/FriendLog/User_UserFriendList";
  //自定义模块
  static const userSetHomeModule = "/api/Home/UserSetHomeModule";

  //公告列表
  static const newList = "/api/New/User_NewList";
  //公告详情
  static String newDetail(dynamic id) => "/api/New/UserNewShow_BindForm/$id";

  // 商户入驻
  static const merchantsNetList = "/api/New/User_MerchantsNetList";

  //奖励金
  // 获取转红包信息
  static const getInvestList = "/api/Invest/GetInvestList";
  // 获取奖励金数据
  static const userInvestOrder = "/api/Invest/UserInvestOrder";
  // 获取领取数据统计
  static const userInvestReceived = "/api/Invest/UserInvestReceived";
  // 我的红包领取记录
  static const userHongbaoQueueList = "/api/Invest/UserHongbaoQueueList";
  // 获取订单记录
  static const userInvestReceivedList = "/api/Invest/UserInvestReceivedList";
  // 领取今日红包 条件判断看具体项目逻辑 例如 每天领取时间 领取金额上限，总上限等
  static const userReceiveHongbao = "/api/Invest/UserReceiveHongbao";
  // 撤单
  static String userInvestOrderCancel(dynamic id) =>
      "/api/Invest/User_InvestOrderCancel/$id";
  // 转换红包信息
  static String redpackConvert(dynamic investConfigId) =>
      "/api/Invest/InvestOrder/$investConfigId";
  // 转红包
  static const investOrder = "/api/Invest/InvestOrder";

  ////积分商城
  //积分商城首页
  static String userProductHomeInfo(int type) =>
      "/api/Product/User_ProductHomeInfo/$type";
  //商城列表
  static const userProductList = "/api/Product/User_ProductList";
  //商城所有分类
  static const userShopAllClass = "/api/Product/User_ShopAllClass";
  //商品详情
  static String userProductShow(int id) => "/api/Product/User_ProductShow/$id";
  //积分商城下单预览
  static const userViewBigShopOrder = "/api/Product/User_ViewBigShopOrder";
  //积分商城下单
  static const userGenerateBigOrders = "/api/Product/User_GenerateBigOrders";
  //积分商城优惠券列表
  static const userCouponList = "/api/Coupon/User_CouponList";
  //积分商城优惠券兑换
  static const userBuyCoupon = "/api/Coupon/User_BuyCoupon";

  //分润统计
  static const userProfitCount = "/api/Home/User_ProfitCount";

  //排行榜
  static const userTOPScoreList = "/api/Home/User_TOPScoreList";

  ////会员权益
  //权益信息
  static const memberList = "/api/LevelGift/User_LevelGiftList";
  //权益支付
  static const menberPay = "/api/LevelGift/User_LevelGiftPay";

  //// 机具划拨
  //查找划拨对象
  static const userFindTeam = "/api/Terminal/User_FindTeam";
  //获取机具品牌列表
  static const userTerminalBrandList = "${enumMapList}TerminalBrand";
  //个人机具列表（高版）
  static const userPersonTerminalHighList =
      "/api/Terminal/User_PersonTerminal_HighList";
  //待办订单
  static const terminalTransferOrder =
      "/api/Terminal/User_TerminalTransferOrder";
  //机具划拨
  static const terminalTransfer = "/api/Terminal/User_TerminalTransfer";
  //划拨记录
  static const terminalTransferList = "/api/Terminal/User_TerminalTransferList";
  //划拨记录明细
  static String terminalTransferDetail(int id) =>
      "/api/Terminal/User_TerminalDetails/$id";
  //同意划拨
  static String userTerminalTransferConfirm(int id) =>
      "/api/Terminal/User_TerminalTransferConfirm/$id";
  //划拨发货
  static const userTerminalTransferSend =
      "/api/Terminal/User_TerminalTransferSend";
  //修改划拨状态
  static String userTerminalTransferStatus(int id, int status) =>
      "/api/Terminal/User_TerminalTransferStatus/$id/$status";

  ////我的机具
  //机具管理统计
  static const userTerminalCount = "/api/Terminal/User_TerminalCount";
  //获取我的机具状态列表
  static const userTerminalList = "/api/Terminal/User_TerminalList";
  //获取团队机具状态列表
  static const userTeamTerminalList = "/api/Terminal/User_TeamTerminalList";
  //获取 费率模板下拉列表
  static const getSelectToolMarginTemplateList =
      "/api/SensitiveSelect/GetSelectToolMarginTemplateList";
  //机具信息
  static String userTerminalInfo(int tId) =>
      "/api/Terminal/User_TerminalInfo/$tId";

  ////商学院
  //商学院首页
  static const userBusinessSchoolInfo = "/api/New/User_BusinessSchoolInfo";
  //商学院列表d_Type对应分类ID
  static const userBusinessSchoolList = "api/New/User_BusinessSchoolList";
  //商学院详情
  static String userBusinessSchoolShow(int id) =>
      "/api/New/User_BusinessSchoolShow/$id";
  //收藏
  static String userShareCollection({required int id, required int type}) =>
      "/api/BuyMember/User_ShareCollection/$id/$type";
  //取消收藏
  static String userDelShareCollection(int id) =>
      "/api/BuyMember/User_DelShareCollection/$id";
  //收藏列表
  static const userShareCollectionList =
      "/api/BuyMember/User_ShareCollectionList";

  ////产品
  //在线商城(礼包)
  static const userLevelGiftList = "/api/LevelGift/User_LevelGiftTeamList";
  //商城详情（礼包）
  // static String userLevelGiftShow(id) =>
  //     "/api/LevelGift/User_LevelGiftShow/$id";
  //生成订单(礼包)
  static const userLevelGiftPay = "/api/LevelGift/User_LevelGiftPay";
  //产品礼包订单预览
  static const previewOrder = "/api/LevelGift/PreviewOrder";

  ////采购
  //商城详情
  static String userLevelGiftTeamDetail(int id) =>
      "api/LevelGift/User_LevelGiftTeamDetail/$id";

  //// 个人
  //修改个人信息
  static const userProfileEdit = "/api/Member/UserProfileEdit";
  //帮助中心
  static const userHelpCenter = "/api/BuyMember/User_HelpList/7";

  //获取省市区信息
  static const getProvinceList = "/api/DefaultSelect/GetProvinceList";
  //查询收货地址
  static const userContactList = "/api/Member/UserContactList";
  //添加/编辑收货地址
  static const userContactEdit = "/api/Member/UserContactEdit";
  //设置默认地址
  static String userContactSetdft(dynamic id) {
    return "/api/Member/UserContactSetdft/$id";
  }

  //分润等级详情
  static const userShareProfitLevelInfoData =
      "/api/UserLevel/User_ShareProfitLevelInfoData";
  //分润统计枚举字典
  static const teamColEnum = enumList + "TeamColEnum";

  //删除收货地址
  static String deleteContact(dynamic id) {
    return "/api/Member/DeleteContact/$id";
  }

  //意见反馈上传
  static const userFeedback = "/api/Member/UserMessageSend";

  ////我的账单
  static const userSubBillingList = "/api/Finance/User_SubBillingList";
  //账单详情分润账单详情
  static const userSubBillingShow = "/api/Finance/User_SubBillingShow";

  //业绩明细
  static const userBounsList = "/api/Finance/User_BounsList";

  ////授权证书
  static const userHtmlToImg = "/api/Member/User_HtmlToImg";

  //读取网点地址
  static const userNetworkContactList = "/api/Member/UserNetworkContactList";

  //实名认证第一步（正反面第三方校验）
  static const userVerifiedStep1 = "/api/Member/UserVerifiedStep1";
  //实名认证第二部 (姓名、身份证号、性别、正反照)
  static const userVerifiedStep2 = "/api/Member/UserVerifiedStep2";

  //支付宝账号修改
  static const userAliPayEdit = "/api/Member/UserOnlinePayEdit";

  //核对短信验证码
  static String checkAuthCode(dynamic code) {
    return "/api/Member/CheckCode/$code";
  }

  //注销
  static const userCancel = "/api/Home/User_Cancel";

  //设置安全密码(支付密码)
  static const userSetPayPwd = "/api/Member/User3ndPadEdit";

  //修改登录密码
  static const userChangePwd = "/api/Member/EditLoginPwdByCode";

  //根据 支付密码 修改 登录密码
  static const user1stPadEdit = "/api/Member/User1stPadEdit";

  //修改备用手机
  static const userBackupMobileEdit = "/api/Member/UserBackupMobileEdit";

  //启动或关闭备用手机
  static const userIsBackupMobile = "/api/Member/UserIsBackupMobile";

  //银行账号添加, 修改
  static const userBankEdit = "/api/Member/UserBankEdit";

  //商城订单列表
  static const userOrderList = "/api/Order/User_OrderList";

  //商城订单去付款
  static String userPayOrder(dynamic id) => "/api/Order/User_PayOrder/$id";

  //商城订单取消订单
  static const userConfirmCancel = "/api/Order/User_ConfirmCancel";

  //商城订单确认收货
  static String userOrderConfirm(dynamic id) =>
      "/api/Order/User_OrderConfirm/$id";

  //商城订单删除订单
  static String userDelOrder(dynamic id) => "/api/Order/User_DelOrder/$id";

  //商城订单详情
  static String userOrderShow(dynamic id) => "/api/Order/User_OrderShow/$id";

  //商城订单 验证订单
  static String userOrderVerifi(dynamic orderNO) =>
      "/api/BuyMember/VerifiOrderStatus/2/$orderNO";
  //商城订单 交易类型
  static const getTradeDataConfigList =
      "/api/SensitiveSelect/GetTradeDataConfigList/0/1";
  //商城订单 状态枚举
  static const getOrderStatusList = "${enumList}OrderStateEnum";

  //生成礼包订单#
  // static const userLevelGiftPay = "/api/LevelGift/User_LevelGiftPay";

  //礼包订单列表
  static const userLevelGiftOrderList =
      "/api/LevelGift/User_LevelGiftOrderList";
  static String userLevelGiftOrderShow(int id) =>
      "/api/LevelGift/User_LevelGiftOrderShow/$id";

  //礼包订单 去支付
  static String userPayGiftOrder(dynamic id) =>
      "/api/LevelGift/User_PayOrder/$id";

  //礼包订单 取消订单
  static String userLevelGiftOrderCancel(dynamic id) =>
      "/api/LevelGift/User_LevelGiftOrderCancel/$id";

  //礼包订单 确认收货
  static String userLevelGiftOrderConfirm(dynamic id) =>
      "/api/LevelGift/User_LevelGiftOrderConfirm/$id";

  //礼包订单 删除订单
  static String userLevelGiftDelOrder(dynamic id) =>
      "/api/LevelGift/User_LevelGiftDelOrder/$id";

  //礼包订单 商城详情
  static String userLevelGiftShow(dynamic id) =>
      "/api/LevelGift/User_LevelGiftShow/$id";

  //礼包订单 验证订单
  static String userGiftOrderVerifi(dynamic orderNO) =>
      "/api/BuyMember/VerifiOrderStatus/1/$orderNO";

  //我的钱包
  //提现记录
  static const userDrawList = "/api/Draw/User_DrawList";
  //提现
  static const userDrawMoneyApply = "/api/Draw/UserDrawMoneyApply";
  //钱包流水
  static const userFinanceIntegralList =
      "/api/Finance/User_FinanceIntegralList";

  ////我的团队
  //我的团队首页
  static const userTeamCount = "/api/UserTeam/User_TeamCount";
  //直属团队人和交易量
  static const userTerminalDataList = "/api/Home/User_TerminalDataList";

  //直属团队数据
  static const userSponsorTeamData = "/api/Home/User_SponsorTeamData/2";

  //直属团队详情
  static const userTerminalDetails = "/api/Home/User_TerminalDetails";
  //我的团队人员列表
  static const userTeamByPeopleList = "/api/UserTeam/User_TeamByPeopleList";
  //盟友资料
  static const userTeamPeopleShow = "/api/UserTeam/User_TeamPeopleShow";

  //伙伴数据详情
  static const userBottomDataDetails2 = "/api/Home/User_BottomDataDetails2";

  ////回拨机具
  //获取需要回拨机具列表
  static const userTerminalBackList = "/api/Terminal/User_TerminalBackList";
  //批量回拨机具
  static String userTerminalCallBack(String tids) =>
      "/api/Terminal/User_TerminalCallBack/$tids";
  //获取机具操作日志
  static const userTerminalLogsList = "/api/Terminal/User_TerminalLogsList";
  //获取机具操作日志详情
  static String userTerminalLogsDetails(String orderNO) =>
      "/api/Terminal/User_TerminalLogsDetails/$orderNO";

  ////我的商户
  //获取商户品质列表----搜索条件
  static const userMerchantStatusSearch =
      "/api/Merchant/UserMerchantStatusSearch";
  //商户状态统计
  static const userMerchantStatusData = "/api/Merchant/UserMerchantStatusData";
  //商户类型枚举
  static const userMerchantEnum = "${enumMapList}MerchantEarlyWarning";
  //我的商户列表
  static const userMerchantDetail = "/api/Merchant/UserMerchantDetail";
  //我的商户列表(老板)
  static const userMerchantDetail2 = "/api/Merchant/UserMerchantDetail2";
  //查看商户详情
  static String userMerchantShow(dynamic tId) =>
      "/api/Merchant/User_MerchantDetail_High/$tId";

  //商户交易记录
  static const userMerchantOrderList = "/api/Merchant/UserMerchantOrderList";
  //商户交易详情2
  static const userMerchantOrder2List = "/api/Merchant/UserMerchantOrder2List";
  //商户详情(柱状图)
  static const userMerchantDetails2 = "/api/Merchant/UserMerchantDetails2";

  ////数据
  //交易数据
  static const userTradeDataList = "/api/Home/User_TradeDataList";
  //激活明细
  static const userActivDetails = "/api/Home/User_ActivDetails";
  //商户数据
  static const userMercDetails = "/api/Home/User_MercDetails";
  //交易数据
  static const userPartnerDetails = "/api/Home/User_PartnerDetails";

  ////收益
  //收益奖
  static String userBounsDetailEarn(dynamic type) =>
      "/api/Finance/User_BounsDetail/$type";
  //收益流水
  static const userFinanceList = "/api/Finance/User_BounsList";
  //收益详情
  static String userFinanceSourceShow(dynamic id, dynamic sources) =>
      "/api/Finance/User_FinanceSourceShow/$id/$sources";
  //收益详情(按日，月，年 分组统计)
  static const userEarningsDataList = "/api/Finance/User_EarningsDataList";

  //业绩图表
  static const userBounsDetail = "/api/Finance/User_BounsDetail";

  //业绩详情(按日，月，年 分组统计)
  static const userPerformanceDetailList =
      "/api/UserTeam/User_PerformanceDetailList";

  //上传图片
  static const uploadUrl = "/api/SingleImageUpload";

  //关闭今日提示更新版本
  static const closeTodayUpdateVersion = "/api/Home/CloseTodayUpdateVersion";

  //获取外部注册信息
  static const getAPPExternalRegInfo =
      "/api/UserLogin/User_GetAPPExternalRegInfo";
}
