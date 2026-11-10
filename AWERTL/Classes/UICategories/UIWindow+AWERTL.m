//
//  UIWindow+AWERTL.m
//  AWERTL
//
//  Created by ByteDance on 2018/9/10.
//

#import "UIWindow+AWERTL.h"
#import "UIView+AWERTL.h"
#import "AWERTLDefinitions.h"
#import "AWERTLManager.h"

@implementation UIWindow (AWERTL)

// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load
{
    ALPSwizzle(self, initWithFrame:, alp_initWithFrame:);
}

- (instancetype)alp_initWithFrame:(CGRect)frame
{
    [self alp_initWithFrame:frame];
    if (self) {
        [self awertl_renewLayerTransformForceRecursively:NO];
        [[AWERTLManager sharedInstance] registerUIElement:self];
    }
    return self;
}

- (AWERTLViewType)awertl_automaticViewType
{
    if ([self isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")]) {
        return AWERTLViewTypeNormal;
    }
    if ([self isKindOfClass:NSClassFromString(@"UIStatusBarWindow")]) {
        return AWERTLViewTypeNormal;
    }
    if ([self isKindOfClass:NSClassFromString(@"UITextEffectsWindow")]) {
        return AWERTLViewTypeNormal;
    }
    return AWERTLViewTypeFlip;
}

@end
