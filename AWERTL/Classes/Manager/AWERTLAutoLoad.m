//
//  AWERTLAutoLoad.m
//  AWERTL
//
//  Created by Anonymous on 2020/6/29.
//

#import "AWERTLAutoLoad.h"
#import "AWERTLRemoteViewControllerAdaptor.h"
#import "AWERTLWhiteListManager.h"
#import "CALayer+AWERTL.h"
#import "Masonry+AWERTL.h"
#import "TTTAttributedLabel+LocalizationsPlus.h"
#import "UIImageView+AWERTL.h"
#import "UILabel+AWERTL.h"
#import "UITextField+AWERTL.h"
#import "UITextView+AWERTL.h"
#import "UIView+AWERTL.h"
#import "UIWindow+AWERTL.h"
#import "YYLabel+AWERTL.h"
#import "UIImage+AWERTL.h"

@implementation AWERTLAutoLoad

// 将所有适配集中在一次性入口，先配置系统控制器，再安装视图与图片钩子。
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 9.0, *)) {
            [SFSafariViewController awertl_load];
        }
        if (@available(iOS 10.1, *)) {
            [SKCloudServiceSetupViewController awertl_load];
        }
        [UIActivityViewController awertl_load];
        [UIImagePickerController awertl_load];
        [SKStoreProductViewController awertl_load];

        [AWERTLWhiteListManager awertl_load];
        [CALayer awertl_load];
        [AWERTLMasonryAdaption awertl_load];
        [AWERTLTTTAttributedLabel awertl_load];
        [UIImageView awertl_load];
        [UILabel awertl_load];
        [UITextField awertl_load];
        [UITextView awertl_load];
        [UIView awertl_load];
        [UIWindow awertl_load];
        [AWERTLYYTextAdaption awertl_load];
        [UIImage awertl_load];
        [UINavigationController awertl_load];
    });
}

@end
