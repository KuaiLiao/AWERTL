//
//  UIImageView+AWERTL.m
//  AWERTL
//
//  Created by ByteDance on 2018/12/6.
//

#import "UIImageView+AWERTL.h"
#import "UIView+AWERTL.h"
#import "UIImage+AWERTL.h"
#import "AWERTLManager.h"
#import "AWERTLDefinitions.h"
#import "CALayer+AWERTL.h"

@implementation UIImageView (AWERTL)

// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load
{
    ALPSwizzle(self, setImage:, awertl_setImage:);
}

- (void)awertl_setImage:(UIImage *)image
{
    if (self.awertl_viewType <=  AWERTLViewTypeFlip) {
        self.awertl_viewType = [self shouldFlipImage:image] ? AWERTLViewTypeFlip : AWERTLViewTypeAuto;
    }
    // 保存输入图片，供调用方读取未经镜像处理的原图。
    self.awerl_origin_image = image;
    [self awertl_setImage:image];
}

- (void)setAwerl_origin_image:(UIImage *)awerl_origin_image {
    objc_setAssociatedObject(self, _cmd, awerl_origin_image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)awerl_origin_image {
    return objc_getAssociatedObject(self, @selector(setAwerl_origin_image:));
}

- (BOOL)shouldFlipImage:(UIImage *)image
{
    if (image.awertl_imageName && [[AWERTLManager sharedInstance] shouldFlipImageWithName:image.awertl_imageName]) {
        return YES;
    }
    BOOL isImageFilpBySystem;
    if (@available(iOS 9.0, *)) {
        isImageFilpBySystem = image.flipsForRightToLeftLayoutDirection;
    } else {
        isImageFilpBySystem = [self.superview isKindOfClass:NSClassFromString(@"_UIModernBarButton")];
    }
    if (isImageFilpBySystem) {
        return YES;
    }
    return NO;
}

@end
