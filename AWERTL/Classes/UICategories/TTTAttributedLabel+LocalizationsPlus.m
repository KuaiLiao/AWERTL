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

// Install RTL adaptations in order from a single entry point to avoid relying on category +load execution order.
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
