//
//  AppDelegate+ShareSDK.h
//  阳光产险微店
//
//  Created by Lee on 16/7/30.
//  Copyright © 2016年 Lee. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate (ShareSDK)
/**
 * shareSDK分享
*/
- (void)registerShareSDK;

/**
 *  定制平台分享内容分享
*/
+ (void)platShareView:(UIView *)view WithShareContent:(NSString *)shareContent WithShareUrlImg:(NSString *)shareUrlImg WithShareTitle:(NSString *)shareTitle WithHTMLURL:(NSString *)URL;
@end
