//
//  UIWebView+AWERTL.h
//  AWERTL
//
//  Created by ByteDance on 2018/10/9.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <SafariServices/SafariServices.h>
#import <StoreKit/StoreKit.h>


@interface SFSafariViewController (AWERTL)
// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load;
@end

@interface SKCloudServiceSetupViewController (AWERTL)
// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load;
@end

@interface UIActivityViewController (AWERTL)
// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load;
@end

@interface UIImagePickerController (AWERTL)
// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load;
@end

@interface SKStoreProductViewController (AWERTL)
// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load;
@end

@interface UINavigationController (AWERTL)
// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load;
@end
