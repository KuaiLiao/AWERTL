//
//  UIView+AWERTL.m
//  AWERTL
//
//  Created by ByteDance on 2018/9/10.
//

#import "UIView+AWERTL.h"
#import "CALayer+AWERTL.h"
#import <objc/runtime.h>
#import "AWERTLDefinitions.h"
#import "AWERTLManager.h"

@interface UIView ()

@property (nonatomic, assign) AWERTLViewType awertl_lastType;
@property (nonatomic, assign) AWERTLViewType awertl_calculatedViewType;

@end

@implementation UIView (AWERTL)

#pragma mark - Swizzle
// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load
{
    ALPSwizzle(self, didMoveToSuperview, awertl_didMoveToSuperview);
    ALPSwizzle(self, didMoveToWindow, awertl_didMoveToWindow);
    ALPSwizzle(self, snapshotViewAfterScreenUpdates:, alp_snapshotViewAfterScreenUpdates:);
}

- (void)awertl_didMoveToSuperview
{
    [self awertl_didMoveToSuperview];
    [self awertl_renewLayerTransformForceRecursively:NO];
}

- (void)awertl_didMoveToWindow
{
    [self awertl_didMoveToWindow];
    [self awertl_renewLayerTransformForceRecursively:NO];
    // 无刷新块的普通视图也需在切换 RTL 时更新，管理器负责去重。
    [[AWERTLManager sharedInstance] registerUIElement:self];
}

- (UIView *)alp_snapshotViewAfterScreenUpdates:(BOOL)afterUpdates
{
    UIView *res = [self alp_snapshotViewAfterScreenUpdates:afterUpdates];
    res.awertl_viewType = self.awertl_calculatedViewType;
    return res;
}


#pragma mark - Additional Properties
- (void)setAwertl_viewType:(AWERTLViewType)awertl_viewType
{
    if (self.awertl_viewType == awertl_viewType) {
        return;
    }
    objc_setAssociatedObject(self, @selector(awertl_viewType), @(awertl_viewType), OBJC_ASSOCIATION_RETAIN);
    [self awertl_renewLayerTransformForceRecursively:NO];
}

- (AWERTLViewType)awertl_viewType
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setAwertl_lastType:(AWERTLViewType)awertl_lastType
{
    objc_setAssociatedObject(self, @selector(awertl_lastType), @(awertl_lastType), OBJC_ASSOCIATION_RETAIN);
}

- (AWERTLViewType)awertl_lastType
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setAwertl_calculatedViewType:(AWERTLViewType)awertl_calculatedViewType
{
    objc_setAssociatedObject(self, @selector(awertl_calculatedViewType), @(awertl_calculatedViewType), OBJC_ASSOCIATION_RETAIN);
}

- (AWERTLViewType)awertl_calculatedViewType
{
    AWERTLViewType type = [objc_getAssociatedObject(self, _cmd) integerValue];
    if (type == AWERTLViewTypeAuto) {
        if (self.window) {
            [self awertl_updateCalculatedViewType];
            type = [objc_getAssociatedObject(self, _cmd) integerValue];
        } else {
            type = AWERTLViewTypeNormal;
        }
    }
    return type;
}

// 显式开关跳过父子镜像抵消计算，沿用扩展库的属性名称以兼容调用方。
- (void)setLm_awt_forceFlip_no_calculate:(BOOL)lm_awt_forceFlip_no_calculate {
    objc_setAssociatedObject(self, @selector(lm_awt_forceFlip_no_calculate), @(lm_awt_forceFlip_no_calculate), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)lm_awt_forceFlip_no_calculate {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

#pragma mark - RTL
- (void)awertl_renewLayerTransformForceRecursively:(BOOL)forceRecursively
{
    [self awertl_updateCalculatedViewType];
    AWERTLViewType updatedViewType = [self awertl_calculatedViewType];
    AWERTLViewType superViewCalculatedViewType = [self.superview awertl_calculatedViewType];
    BOOL shouldFlipCurrentView = updatedViewType == AWERTLViewTypeFlip || updatedViewType == AWERTLViewTypeFlipWithAllDescendants;
    BOOL shouldFlipSuperview = superViewCalculatedViewType == AWERTLViewTypeFlip || superViewCalculatedViewType == AWERTLViewTypeFlipWithAllDescendants;
    BOOL shouldSetFlipTransform = shouldFlipSuperview ^ shouldFlipCurrentView;
    if (self.lm_awt_forceFlip_no_calculate) {
        shouldSetFlipTransform = YES;
    }
    if (shouldSetFlipTransform && [AWERTLManager sharedInstance].enableRTL) {
        self.layer.awertl_basicTransform = CGAffineTransformMakeScale(-1, 1);
    } else {
        self.layer.awertl_basicTransform = CGAffineTransformIdentity;
    }
    
    if (updatedViewType != self.awertl_lastType || forceRecursively) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj awertl_renewLayerTransformForceRecursively:forceRecursively];
        }];
    }
    
    self.awertl_lastType = updatedViewType;
}

- (void)awertl_updateCalculatedViewType
{
    AWERTLViewType rtlType = [self awertl_viewType];
    if (rtlType == AWERTLViewTypeAuto) {
        rtlType = [self awertl_automaticViewType];
    }
    
    AWERTLViewType superViewCalculatedType = self.superview.awertl_calculatedViewType;
    if (superViewCalculatedType == AWERTLViewTypeFlipWithAllDescendants || superViewCalculatedType == AWERTLViewTypeNormalWithAllDescendants || rtlType == AWERTLViewTypeInherit) {
        self.awertl_calculatedViewType = self.superview.awertl_calculatedViewType;
    } else {
        self.awertl_calculatedViewType = rtlType;
    }
}

#pragma mark - For Inherit
- (AWERTLViewType)awertl_automaticViewType
{
    return self.superview ? AWERTLViewTypeInherit : AWERTLViewTypeNormal;
}

@end
