//
//  AppDelegate+WXApi.m
//  阳光产险微店
//
//  Created by 祥云创想 on 16/8/19.
//  Copyright © 2016年 Lee. All rights reserved.
//

#import "AppDelegate+WXApi.h"
#import "WXUtil.h"
#import "ApiXml.h"
#import <objc/runtime.h>

static NSString *const prePayIDUrl = @"https://api.mch.weixin.qq.com/pay/unifiedorder";

static void * const mchID_key = "mchID_key";
static void * const appID_key = "appID_key";
static void * const secretKey_key = "secretKey_key";
static void * const callbackConfig_key = "callbackConfig_key";

@interface WxApiDelegateObject : NSObject<WXApiDelegate>

@property (nonatomic, copy) void(^config)(BOOL success);

+ (instancetype)objectWithConfig:(void(^)(BOOL success))config;

@end

@implementation WxApiDelegateObject

+ (instancetype)objectWithConfig:(void(^)(BOOL success))config{
    WxApiDelegateObject *obj = [WxApiDelegateObject new];
    obj.config = config;
    return obj;
}

#pragma mark - <WXApiDelegate>

- (void)onResp:(BaseResp *)resp{
    if ([resp isKindOfClass:[PayResp class]]) {
        [self handlePayResq:resp];
    }
}

- (void)handlePayResq:(BaseResp *)resq{
    if (_config) {
        _config(resq.errCode == WXSuccess);
        _config = nil;
        objc_setAssociatedObject([WXApi class], callbackConfig_key, nil, OBJC_ASSOCIATION_ASSIGN);
    }
    /*
     if ([resp isKindOfClass:[PayResp class]]) {
     PayResp*response=(PayResp*)resp;  // 微信终端返回给第三方的关于支付结果的结构体
     switch (response.errCode) {
     case WXSuccess:
     {// 支付成功，向后台发送消息
     LXLog(@"支付成功");
     [[NSNotificationCenter defaultCenter] postNotificationName:@"WX_PaySuccess" object:nil];
     }
     break;
     case WXErrCodeCommon:
     { //签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等
     [MBProgressHUD showError:@"支付失败"];
     LXLog(@"支付失败");
     }
     break;
     case WXErrCodeUserCancel:
     { //用户点击取消并返回
     LXLog(@"取消支付");
     [MBProgressHUD showError:@"取消支付"];
     }
     break;
     case WXErrCodeSentFail:
     { //发送失败
     LXLog(@"发送失败");
     [MBProgressHUD showError:@"发送失败"];
     }
     break;
     case WXErrCodeUnsupport:
     { //微信不支持
     LXLog(@"微信不支持");
     [MBProgressHUD showError:@"微信不支持"];
     }
     break;
     case WXErrCodeAuthDeny:
     { //授权失败
     LXLog(@"授权失败");
     [MBProgressHUD showError:@"授权失败"];
     }
     break;
     default:
     break;
     }
     }
     */
}

@end

@implementation AppDelegate (WXApi)
+ (void)registerWeChatWithAppID:(NSString *)appID {
    [WXApi registerApp:appID];
    [self saveValueWithKey:appID_key value:appID];
}

+ (void)registerWXPayWithMchID:(NSString*)mchID appSecret:(NSString*)secretKey {
    [self saveValueWithKey:mchID_key value:mchID];
    [self saveValueWithKey:secretKey_key value:secretKey];
}

+ (void)sendWeChatPayRequestWithOrderID:(NSString *)orderID
                              orderName:(NSString *)orderName
                             orderPrice:(NSString *)orderPrice
                         orderNotifyUrl:(NSString *)orderNotifyUrl
                         callbackConfig:(void (^)(BOOL successed))config; {
    if (!config) {
        NSLog(@"必须设置回调block");
        return;
    }
    NSString *appID = [self readValueWithKey:appID_key];
    NSString *mchID = [self readValueWithKey:mchID_key];
    NSString *secretKey = [self readValueWithKey:secretKey_key];
    if (!mchID || !secretKey || !appID) {
        NSLog(@"您暂未注册微信支付");
        config(NO);
        return;
    }
    if (!orderID || !orderName || !orderNotifyUrl || !orderPrice) {
        NSLog(@"基础信息不全，无法调用支付");
        config(NO);
        return;
    }
    //随机数串
    srand( (unsigned)time(0) );
    NSString *noncestr  = [NSString stringWithFormat:@"%d", rand()];
    //发器支付的机器ip,暂时没有发现其作用
    NSString* orderIP = [WXUtil getIPAddress:YES];
    //支付类型，固定为APP
    NSString* orderType = @"APP";
    //生成预支付信息字典
    NSDictionary *prePayDict = @{@"appid" : appID,
                                 @"mch_id" : mchID,
                                 @"nonce_str" : noncestr,
                                 @"trade_type" : orderType,
                                 @"body" : orderName,
                                 @"notify_url" : orderNotifyUrl,
                                 @"out_trade_no" : orderID,
                                 @"spbill_create_ip" : orderIP,
                                 @"total_fee" : orderPrice};
    //获取预支付ID
    NSString *prePayID = [self sendForPrePayIDWithPrePayDict:prePayDict];
    if (!prePayID) {
        NSLog(@"获取prePayID失败");
        config(NO);
        return;
    }
    //进行二次签名
    time_t now;
    time(&now);
    NSString *time  = [NSString stringWithFormat:@"%ld", now];
    NSString *nonce_str = [WXUtil md5:time];
    NSDictionary *signParams = @{@"appid" : appID,
                                 @"partnerid" : mchID,
                                 @"noncestr" : nonce_str,
                                 @"package" : @"Sign=WXPay",
                                 @"timestamp" : time,
                                 @"prepayid" : prePayID};
    NSString *sign  = [self createMd5Sign:signParams];
    [self senWeChatPayRequsetWithAppID:signParams[@"appid"] partnerId:signParams[@"partnerid"] prepayId:signParams[@"prepayid"] nonceStr:signParams[@"noncestr"] timeStamp:signParams[@"timestamp"] package:signParams[@"package"] sign:sign callbackConfig:config];
}

+ (void)senWeChatPayRequsetWithAppID:(NSString *)appID partnerId:(NSString *)partnerId prepayId:(NSString *)prepayId nonceStr:(NSString *)nonceStr timeStamp:(NSString *)timeStamp package:(NSString *)package sign:(NSString *)sign callbackConfig:(void (^)(BOOL))config{
    //构建请求对象
    PayReq *req = [PayReq new];
    req.openID = appID;
    req.partnerId = partnerId;
    req.prepayId = prepayId;
    req.nonceStr = nonceStr;
    req.timeStamp = (UInt32)[timeStamp intValue];
    req.package = package;
    req.sign = sign;
    //发起微信支付
    BOOL flag = [WXApi sendReq:req];
    if (!flag){
        NSLog(@"请求微信失败");
        config(NO);
        return;
    }
    else{
        NSLog(@"请求成功");
        //保存回调block
        objc_setAssociatedObject(self, callbackConfig_key, config, OBJC_ASSOCIATION_COPY_NONATOMIC);
        return;
    }
    
}


+ (void)handleOpenURLWithWeChat:(NSURL *)url {
    void(^config)(BOOL success) = objc_getAssociatedObject(self, callbackConfig_key);
    if (!config) {
        return;
    }
    [WXApi handleOpenURL:url delegate:[WxApiDelegateObject objectWithConfig:config]];
}

#pragma mark - private methods

+ (NSString *)sendForPrePayIDWithPrePayDict:(NSDictionary *)dict{
    NSString *prePayID = nil;
    NSString *send = [self stringAfterPackageDict:dict];
    //请求prePayID
    NSData *res = [WXUtil httpSend:prePayIDUrl method:@"POST" data:send];
    XMLHelper *xml  = [[XMLHelper alloc] init];
    //开始解析
    [xml startParse:res];
    NSMutableDictionary *resParams = [xml getDict];
    //判断返回
    NSString *return_code = [resParams objectForKey:@"return_code"];
    NSString *result_code = [resParams objectForKey:@"result_code"];
    if ( [return_code isEqualToString:@"SUCCESS"] ) {
        //获取prePayID 成功
        NSString *sign      = [self createMd5Sign:resParams ];
        NSString *send_sign =[resParams objectForKey:@"sign"] ;
        //验证签名正确性
        if( [sign isEqualToString:send_sign]){
            if( [result_code isEqualToString:@"SUCCESS"]) {
                //验证业务处理状态
                prePayID = [resParams objectForKey:@"prepay_id"];
                return_code = 0;
            }
        }else{
            NSLog(@"签名验证失败");
        }
    }else{
        NSLog(@"未返回prePayID结果");
    }
    return prePayID;
}

/**打包参数字典为packageString*/
+ (NSString *)stringAfterPackageDict:(NSDictionary*)dict {
    NSString *sign;
    NSMutableString *reqPars=[NSMutableString string];
    //生成签名
    sign = [self createMd5Sign:dict];
    //生成xml的package
    NSArray *keys = [dict allKeys];
    [reqPars appendString:@"<xml>\n"];
    for (NSString *categoryId in keys) {
        [reqPars appendFormat:@"<%@>%@</%@>\n", categoryId, [dict objectForKey:categoryId],categoryId];
    }
    [reqPars appendFormat:@"<sign>%@</sign>\n</xml>", sign];
    return [NSString stringWithString:reqPars];
}

/**md5签名*/
+ (NSString*) createMd5Sign:(NSDictionary*)dict {
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (   ![[dict objectForKey:categoryId] isEqualToString:@""]
            && ![categoryId isEqualToString:@"sign"]
            && ![categoryId isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
        
    }
    NSString *secretKey = [self readValueWithKey:secretKey_key];
    //添加key字段
    [contentString appendFormat:@"key=%@", secretKey];
    //得到MD5 sign签名
    NSString *md5Sign =[WXUtil md5:contentString];
    
    return md5Sign;
}

// 给对象添加关联
// object:给哪个对象添加属性
// key:属性名
// value:属性值
// policy:策略
+ (void)saveValueWithKey:(void *)key value:(id)value{
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (id)readValueWithKey:(void *)key{
    return objc_getAssociatedObject(self, key);
}

@end
