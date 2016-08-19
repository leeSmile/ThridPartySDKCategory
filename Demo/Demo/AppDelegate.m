//
//  AppDelegate.m
//  Demo
//
//  Created by 祥云创想 on 16/8/19.
//  Copyright © 2016年 Lee. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+ShareSDK.h"
#import "AppDelegate+WXApi.h"
#import "AppDelegate+AlipaySDK.h"
#import "AppDelegate+JPushSDK.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //初始化所有的第三方SDK
    [self setUpThridPartySDKWithOptions:launchOptions];
    
    return YES;
}

- (void)setUpThridPartySDKWithOptions:(NSDictionary *)launchOptions
{
    //注册ShareSDK
    [AppDelegate registerShareSDK];
    
    //注册极光推送
    [AppDelegate registerJPushSDKWithOptions:launchOptions];
    
    //注册微信支付
    [AppDelegate registerWeChatWithAppID:@"AppID"];
    [AppDelegate registerWXPayWithMchID:@"MchID" appSecret:@"Secret"];//客户端签名时调用注册
    
    //注册支付宝支付
    [AppDelegate registerAlipayWithPartnerID:@"PartnerID" sellerID:@"sellerID" partnerPrivKey:@"PrivKey"];//客户端签名时调用注册
    
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options{
    //处理微信回调
    [AppDelegate handleOpenURLWithWeChat:url];
    //处理支付宝回调
    [AppDelegate handleOpenURLWithAlipaySDK:url];
    return YES;
}

#pragma mark -- 极光相关
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [JPUSHService registerDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [JPUSHService handleRemoteNotification:userInfo];
}
@end
