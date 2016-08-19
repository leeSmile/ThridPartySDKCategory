//
//  AppDelegate+AlipaySDK.m
//  阳光产险微店
//
//  Created by 祥云创想 on 16/8/19.
//  Copyright © 2016年 Lee. All rights reserved.
//

#import "AppDelegate+AlipaySDK.h"
#import "Order.h"
#import "DataSigner.h"
#import <objc/runtime.h>

static void * const partnerID_key = "partnerID_key";
static void * const sellerID_key = "sellerID_key";
static void * const partnerPrivKey_key = "partnerPrivKey_key";
static void * const callbackConfig_key = "callbackConfig_key";

@implementation AppDelegate (AlipaySDK)
+ (void)registerAlipayWithPartnerID:(NSString*)partnerID sellerID:(NSString*)sellerID partnerPrivKey:(NSString *)partnerPrivKey {
    [self saveValueWithKey:partnerID_key value:partnerID];
    [self saveValueWithKey:sellerID_key value:sellerID];
    [self saveValueWithKey:partnerPrivKey_key value:partnerPrivKey];
}

+ (void)sendAlipayPayRequestWithOrderID:(NSString *)orderID
                              orderName:(NSString *)orderName
                       orderDescription:(NSString *)orderDescription
                             orderPrice:(NSString *)orderPrice
                         orderNotifyUrl:(NSString *)orderNotifyUrl
                              appScheme:(NSString *)appScheme
                         callbackConfig:(void (^)(BOOL successed))config {
    if (!config) {
        NSLog(@"必须设置回调block");
        return;
    }
    //生成订单信息
    NSString * partnerID = [self readValueWithKey:partnerID_key];
    NSString * sellerID = [self readValueWithKey:sellerID_key];
    NSString * partnerPrivKey = [self readValueWithKey:partnerPrivKey_key];
    if (!partnerID.length || !sellerID.length || !partnerPrivKey.length) {
        NSLog(@"基础信息不全");
        config(NO);
        return;
    }
    Order *order = [[Order alloc] init];
    order.partner = partnerID; //支付宝分配给商户的ID
    order.sellerID = sellerID; //收款支付宝账号（用于收钱）
    order.outTradeNO = orderID; //订单ID(由商家自行制定)
    order.subject = orderName; //商品标题
    order.body = orderDescription; //商品描述
    order.totalFee = orderPrice; //商品价格
    order.notifyURL =  orderNotifyUrl; //回调URL（通知服务器端交易结果）(重要)
    order.service = @"mobile.securitypay.pay"; //接口名称, 固定值, 不可空
    order.inputCharset = @"utf-8"; //参数编码字符集: 商户网站使用的编码格式, 固定为utf-8, 不可空
    // 将订单信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"订单信息orderSpec = %@", orderSpec);
    //通过私钥将订单信息签名
    id<DataSigner> signer = CreateRSADataSigner(partnerPrivKey);
    NSString *signedString = [signer signString:orderSpec];
    if (!signedString.length) {
        NSLog(@"签名失败");
        config(NO);
        return;
    }
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                   orderSpec, signedString, @"RSA"];
    NSLog(@"==== %@", orderString);
    [self sendAlipayPayWithOrderInfo:orderString appScheme:appScheme callbackConfig:config];
}

+ (void)sendAlipayPayWithOrderInfo:(NSString *)orderInfo
                         appScheme:(NSString *)appScheme
                    callbackConfig:(void (^)(BOOL successed))config {
    //保存回调block
    objc_setAssociatedObject(self, callbackConfig_key, config, OBJC_ASSOCIATION_COPY_NONATOMIC);
    //发起支付请求
    [[AlipaySDK defaultService] payOrder:orderInfo fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        [self checkResultWithDict:resultDic];
    }];
    
}

+ (void)handleOpenURLWithAlipaySDK:(NSURL *)url {
    if (![url.host isEqualToString:@"safepay"]) {
        return;
    }
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        [self checkResultWithDict:resultDic];
    }];
}

#pragma mark - private methods

+ (void)checkResultWithDict:(NSDictionary *)resultDic{
    void (^config)(BOOL successed) = objc_getAssociatedObject(self, callbackConfig_key);
    if (!config) {
        return;
    }
    config([resultDic[@"resultStatus"] intValue] == 9000);
    config = nil;
    objc_setAssociatedObject(self, callbackConfig_key, nil, OBJC_ASSOCIATION_ASSIGN);
}

+ (void)saveValueWithKey:(void *)key value:(id)value{
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (id)readValueWithKey:(void *)key{
    return objc_getAssociatedObject(self, key);
}

@end
