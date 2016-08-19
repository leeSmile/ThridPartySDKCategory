//
//  AppDelegate+JPushSDK.m
//  sunt6
//
//  Created by 李枭 on 16/8/13.
//  Copyright © 2016年 李枭. All rights reserved.
//

#import "AppDelegate+JPushSDK.h"


static NSString *JPushKey = @"b5ee731d7772a1f0ef4aeb8d";

@implementation AppDelegate (JPushSDK)

- (void)registerJPushSDKWithOptions:(NSDictionary *)launchOptions
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound |UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
    [JPUSHService setupWithOption:launchOptions appKey:JPushKey channel:nil apsForProduction:YES advertisingIdentifier:nil];
}

//- (void)receiveRemoteNotification:(NSDictionary *)userInfo
//{
//    [self receiveRemoteNotification:userInfo isActive:NO];
//}
//
//
//- (void)receiveRemoteNotification:(NSDictionary *)userInfo isActive:(BOOL)active
//{
//    [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
//    
//    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//    
//    [[UIApplication sharedApplication] cancelAllLocalNotifications] ;
//    
//    if (active) {
//        
//        return;
//    }
////    [[AppDelegate currentAppDelegate].tabBarViewController setSelectedIndex:0];
////    [(UINavigationController*)[[AppDelegate currentAppDelegate].tabBarViewController.viewControllers objectAtIndex:0] popToRootViewControllerAnimated:NO];
//    
//}
/*
 
 - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
 {
 DLog(@"receive RemoteNotification: %@", userInfo);
 
 if (application.applicationState == UIApplicationStateInactive)
 {
 //[self receiveRemoteNotification:userInfo isActive:NO];
 [self performSelector:@selector(receiveRemoteNotification:) withObject:userInfo afterDelay:1];
 }
 else if (application.applicationState == UIApplicationStateActive)
 {
 //[self receiveRemoteNotification:userInfo isActive:YES];
 }
 
 }
 
 - (void)receiveRemoteNotification:(NSDictionary *)userInfo
 {
 [self receiveRemoteNotification:userInfo isActive:NO];
 }
 
 - (void)receiveRemoteNotification:(NSDictionary *)userInfo isActive:(BOOL)active
 {
 [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
 
 [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
 
 [[UIApplication sharedApplication] cancelAllLocalNotifications] ;
 
 if (active) {
 
 return;
 }
 
 [[AppDelegate currentAppDelegate].tabBarViewController setSelectedIndex:0];
 [(UINavigationController*)[[AppDelegate currentAppDelegate].tabBarViewController.viewControllers objectAtIndex:0] popToRootViewControllerAnimated:NO];
 remotePageTitle = L(@"Product_Push");
 //dm
 [SNRouter handleAdTypeCode:EncodeStringFromDic(userInfo, @"adTypeCode")
 adId:EncodeStringFromDic(userInfo, @"adId")
 chanId:EncodeStringFromDic(userInfo, @"activityRule")
 qiangId:EncodeStringFromDic(userInfo, @"activityTitle")
 onChecking:^(SNRouterObject *obj) {
 [self.window showHUDIndicatorViewAtCenter:L(@"Loading")];
 } shouldRoute:^BOOL(SNRouterObject *obj) {
 [self.window hideHUDIndicatorViewAtCenter];
 //                        if (obj.errorMsg.length) [self.window showTipViewAtCenter:obj.errorMsg];
 return YES;
 } didRoute:NULL
 source:SNRouteSourceRemoteNotification];
 }
 */
@end
