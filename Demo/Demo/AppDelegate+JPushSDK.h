//
//  AppDelegate+JPushSDK.h
//  sunt6
//
//  Created by 李枭 on 16/8/13.
//  Copyright © 2016年 李枭. All rights reserved.
//

#import "AppDelegate.h"
#import "JPUSHService.h"
@interface AppDelegate (JPushSDK)
/**
 * 初始化JPushSDK
 */
- (void)registerJPushSDKWithOptions:(NSDictionary *)launchOptions;
//- (void)receiveRemoteNotification:(NSDictionary *)userInfo;
@end
