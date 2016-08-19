//
//  AppDelegate+AlipaySDK.h
//  阳光产险微店
//
//  Created by 祥云创想 on 16/8/19.
//  Copyright © 2016年 Lee. All rights reserved.
//
/**
 集成步骤：
 1、导入相关库，配置info.plist、配置Scheme、配置header search paths，进行编译前准备
 2、调用registerAlipayWithPartnerID:sellerID:partnerPrivKey:方法注册支付宝支付，该方法在客户端签名时候才需要调用
 4、在appDelegate中的handleURL中调用handleOpenURL设置回调
 5、调用sendPayRequest方法发起支付申请，该方法分为有客户端签名和服务端签名两个版本
 6、在回调block中处理相关逻辑
 */

#import "AppDelegate.h"
#import <AlipaySDK/AlipaySDK.h>

@interface AppDelegate (AlipaySDK)
/**
 *  注册支付宝支付(客户端签名的时候才需要调用)
 *
 *  @param partnerID      PID，商户ID，一般以2088开头
 *  @param sellerID       收款账户地址，如邮箱等
 *  @param partnerPrivKey 通过SSL工具生成的私钥，同时需要把匹配的公钥传至支付宝账户
 */
+ (void)registerAlipayWithPartnerID:(NSString *)partnerID sellerID:(NSString *)sellerID partnerPrivKey:(NSString *)partnerPrivKey;

/**
 *  发起支付（客户端签名版本）
 *
 *  @param orderID          订单号
 *  @param orderName        订单标题
 *  @param orderDescription 订单描述
 *  @param orderPrice       订单价格，保留小数点2位，单位（元）
 *  @param orderNotifyUrl   服务端回调URL（重要）
 *  @param appScheme        设置的app的URLScheme
 *  @param config           支付完成后的回调（无论是网页版本还是支付宝客户端的版本都通过此block回调）（successed = YES 代表支付成功）
 */
+ (void)sendAlipayPayRequestWithOrderID:(NSString *)orderID
                              orderName:(NSString *)orderName
                       orderDescription:(nullable NSString *)orderDescription
                             orderPrice:(NSString *)orderPrice
                         orderNotifyUrl:(NSString *)orderNotifyUrl
                              appScheme:(NSString *)appScheme
                         callbackConfig:(void (^)(BOOL successed))config;

/**
 *  发起支付 (服务器端签名版本)
 *
 *  @param orderInfo 服务器签名好的订单信息
 *  @param appScheme 设置的app的URLScheme
 *  @param config    支付完成后的回调（无论是网页版本还是支付宝客户端的版本都通过此block回调）（successed = YES 代表支付成功）
 */
+ (void)sendAlipayPayWithOrderInfo:(NSString *)orderInfo
                         appScheme:(NSString *)appScheme
                    callbackConfig:(void (^)(BOOL successed))config;

/**
 *  处理回调的openUrl，请在AppDelegate对应的方法中调用
 *
 *  @param url 回调的openURL
 */
+ (void)handleOpenURLWithAlipaySDK:(NSURL *)url;
@end
