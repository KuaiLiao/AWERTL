//
//  ALPMasonryAdaption.m
//  AWELocalizations-iOS
//
//  Created by ByteDance on 2018/2/11.
//

#import "Masonry+AWERTL.h"
#import <objc/runtime.h>

@implementation AWERTLMasonryAdaption

// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load
{
    [self swizzleClass:@"MASConstraintMaker" oldMethod:@"leading" withNewMethod:@"left"];
    [self swizzleClass:@"MASConstraintMaker" oldMethod:@"trailing" withNewMethod:@"right"];
    [self swizzleClass:@"MASViewConstraint" oldMethod:@"leading" withNewMethod:@"left"];
    [self swizzleClass:@"MASViewConstraint" oldMethod:@"trailing" withNewMethod:@"right"];
    [self swizzleClass:@"UIView" oldMethod:@"mas_leading" withNewMethod:@"mas_left"];
    [self swizzleClass:@"UIView" oldMethod:@"mas_trailing" withNewMethod:@"mas_right"];
    [self swizzleClass:@"UIView" oldMethod:@"mas_leadingMargin" withNewMethod:@"mas_leftMargin"];
    [self swizzleClass:@"UIView" oldMethod:@"mas_trailingMargin" withNewMethod:@"mas_rightMargin"];
    [self swizzleClass:@"UILayoutGuide" oldMethod:@"mas_leading" withNewMethod:@"mas_left"];
    [self swizzleClass:@"UILayoutGuide" oldMethod:@"mas_trailing" withNewMethod:@"mas_right"];
}

+ (void)swizzleClass:(NSString *)className oldMethod:(NSString *)oldMethodName withNewMethod:(NSString *)newMethodName
{
    Class class = NSClassFromString(className);
    if (!class) {
        return;
    }
    SEL sel = NSSelectorFromString(oldMethodName);
    Method method = class_getInstanceMethod(class, sel);
    if (!method) {
        return;
    }
    
    SEL newSel = NSSelectorFromString(newMethodName);
    Method newMethod = class_getInstanceMethod(class, newSel);
    if (!newMethod) {
        return;
    }
    IMP newImplementation = method_getImplementation(newMethod);
    if (!newImplementation) {
        return;
    }
    
    method_setImplementation(method, newImplementation);
}

@end
