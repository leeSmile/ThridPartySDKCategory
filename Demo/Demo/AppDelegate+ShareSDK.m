//
//  AppDelegate+ShareSDK.m
//  阳光产险微店
//
//  Created by Lee on 16/7/30.
//  Copyright © 2016年 Lee. All rights reserved.
//

#import "AppDelegate+ShareSDK.h"
//ShareSDK
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
//微信SDK头文件
#import "WXApi.h"
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>

#import "Alert.h"

static NSString *ShareSDKKey = @"b5ee731d7772a1f0ef4aeb8d";
static NSString *WeChatAppId = @"WeChatByAppId";
static NSString *WeChatSecret = @"WeChatSecret";

@implementation AppDelegate (ShareSDK)

#pragma mark 分享平台初始化
+ (void)registerShareSDK
{
    /**
     *  设置ShareSDK的appKey，如果尚未在ShareSDK官网注册过App，请移步到http://mob.com/login 登录后台进行应用注册
     *  在将生成的AppKey传入到此方法中。
     *  方法中的第二个第三个参数为需要连接社交平台SDK时触发，
     *  在此事件中写入连接代码。第四个参数则为配置本地社交平台时触发，根据返回的平台类型来配置平台信息。
     *  如果您使用的时服务端托管平台信息时，第二、四项参数可以传入nil，第三项参数则根据服务端托管平台来决定要连接的社交SDK。
     */
    [ShareSDK registerApp:ShareSDKKey
          activePlatforms:@[
                            @(SSDKPlatformSubTypeWechatSession),
                            @(SSDKPlatformSubTypeWechatTimeline)]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
                 case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
                 
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
                 
                 case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:WeChatAppId
                                       appSecret:WeChatSecret];
                 break;
                 
                 
             default:
                 break;
         }
     }];

}
+ (void)platShareView:(UIView *)view WithShareContent:(NSString *)shareContent WithShareUrlImg:(NSString *)shareUrlImg WithShareTitle:(NSString *)shareTitle WithHTMLURL:(NSString *)URL
{
    //    //设置分享菜单栏样式（非必要）
    //    //        [SSUIShareActionSheetStyle setActionSheetBackgroundColor:[UIColor colorWithRed:249/255.0 green:0/255.0 blue:12/255.0 alpha:0.5]];
    //    //        [SSUIShareActionSheetStyle setActionSheetColor:[UIColor colorWithRed:21.0/255.0 green:21.0/255.0 blue:21.0/255.0 alpha:1.0]];
    //    //        [SSUIShareActionSheetStyle setCancelButtonBackgroundColor:[UIColor colorWithRed:21.0/255.0 green:21.0/255.0 blue:21.0/255.0 alpha:1.0]];
    //    //        [SSUIShareActionSheetStyle setCancelButtonLabelColor:[UIColor whiteColor]];
    //    //        [SSUIShareActionSheetStyle setItemNameColor:[UIColor whiteColor]];
    //    //        [SSUIShareActionSheetStyle setItemNameFont:[UIFont systemFontOfSize:10]];
    //    //        [SSUIShareActionSheetStyle setCurrentPageIndicatorTintColor:[UIColor colorWithRed:156/255.0 green:156/255.0 blue:156/255.0 alpha:1.0]];
    //    //        [SSUIShareActionSheetStyle setPageIndicatorTintColor:[UIColor colorWithRed:62/255.0 green:62/255.0 blue:62/255.0 alpha:1.0]];
    //创建分享参数
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    
    //微信好友
    [shareParams SSDKSetupWeChatParamsByText:shareContent title:shareTitle url:[NSURL URLWithString:URL] thumbImage:[UIImage imageNamed:shareUrlImg] image:[UIImage imageNamed:shareUrlImg] musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeWebPage forPlatformSubType:SSDKPlatformSubTypeWechatSession];
    
    //微信朋友圈
    [shareParams SSDKSetupWeChatParamsByText:shareContent title:shareTitle url:[NSURL URLWithString:URL] thumbImage:[UIImage imageNamed:shareUrlImg] image:[UIImage imageNamed:shareUrlImg] musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeWebPage forPlatformSubType:SSDKPlatformSubTypeWechatTimeline];
    
    SSUIShareActionSheetController *sheet = [ShareSDK showShareActionSheet:view items:nil shareParams:shareParams onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
        
        switch (state)
        {
                case SSDKResponseStateSuccess:
            {
                Alert *alert = [[Alert alloc] initWithTitle:@"分享成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alert.contentAlignment = NSTextAlignmentLeft;
                [alert show];
                break;
            }
                case SSDKResponseStateFail:
            {
                Alert *alert = [[Alert alloc] initWithTitle:@"分享失败" message:@"    您好像没有安装分享设备平台哦" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                //                alert.tag = 10;
                alert.contentAlignment = NSTextAlignmentLeft;
                [alert show];
                break;
            }
                case SSDKResponseStateCancel:
            {
                break;
            }
            default:
                break;
        }
    }];
    
    //删除和添加平台示例
    [sheet.directSharePlatforms addObject:@(SSDKPlatformTypeSinaWeibo)];
    [sheet.directSharePlatforms addObject:@(SSDKPlatformTypeTencentWeibo)];


}


@end
