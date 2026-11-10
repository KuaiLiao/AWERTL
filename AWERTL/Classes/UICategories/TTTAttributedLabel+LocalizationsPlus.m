//
//  TTTAttributedLabel+LocalizationsPlus.m
//  AWELocalizations-iOS
//
//  Created by ByteDance on 2018/2/22.
//

#import "TTTAttributedLabel+LocalizationsPlus.h"
#import <objc/runtime.h>
#import "RSSwizzle.h"
#import "AWERTLManager.h"

@implementation AWERTLTTTAttributedLabel

// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load
{
    Class class = NSClassFromString(@"TTTAttributedLabel");
    if (!class) {
        return;
    }
    
    RSSwizzleInstanceMethod(class, NSSelectorFromString(@"textAlignment"), RSSWReturnType(NSTextAlignment), RSSWArguments(), RSSWReplacement({
        NSTextAlignment alignment = RSSWCallOriginal();
        if (alignment == NSTextAlignmentNatural && [AWERTLManager sharedInstance].enableRTL) {
            return NSTextAlignmentRight;
        }
        return alignment;
    }), 0, NULL);
}

@end
