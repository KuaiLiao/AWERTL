//
//  UITextView+AWERTL.m
//  AWERTL
//
//  Created by ByteDance on 2018/12/6.
//

#import "UITextView+AWERTL.h"
#import "NSObject+AWERTLReloadBlock.h"
#import "AWERTLDefinitions.h"
#import "AWERTLManager.h"

@implementation UITextView (AWERTL)

// Install RTL adaptations in order from a single entry point to avoid relying on category +load execution order.
+ (void)awertl_load
{
    ALPSwizzle(self, setTextAlignment:, awertl_setTextAlignment:);
    ALPSwizzle(self, setAttributedText:, awertl_setAttributedText:);
    ALPSwizzle(self, initWithFrame:, awertl_initWithFrame:);
    ALPSwizzle(self, initWithCoder:, awertl_initWithCoder:);
    ALPSwizzle(self, setTextContainerInset:, awertl_setTextContainerInset:);
}

- (void)awertl_setTextContainerInset:(UIEdgeInsets)textContainerInset {
    // Swap the left and right text container insets in RTL mode.
    if ([AWERTLManager sharedInstance].enableRTL) {
        CGFloat left = textContainerInset.left;
        textContainerInset.left = textContainerInset.right;
        textContainerInset.right = left;
    }
    [self awertl_setTextContainerInset:textContainerInset];
}

- (instancetype)awertl_initWithFrame:(CGRect)frame
{
    [self awertl_initWithFrame:frame];
    if (self) {
        self.textAlignment = NSTextAlignmentLeft;
    }
    return self;
}

- (instancetype)awertl_initWithCoder:(NSCoder *)aDecoder
{
    [self awertl_initWithCoder:aDecoder];
    if (self) {
        self.textAlignment = NSTextAlignmentLeft;
    }
    return self;
}

- (void)awertl_setTextAlignment:(NSTextAlignment)textAlignment
{
    @weakify(self);
    [self awertl_addReloadBlockForKey:@"alignment" andExecuteIt:^{
        @strongify(self);
        if ([AWERTLManager sharedInstance].enableRTL) {
            if (textAlignment == NSTextAlignmentCenter) {
                [self awertl_setTextAlignment:textAlignment];
            } else if (textAlignment == NSTextAlignmentRight) {
                [self awertl_setTextAlignment:NSTextAlignmentLeft];
            } else {
                [self awertl_setTextAlignment:NSTextAlignmentRight];
            }
        } else {
            [self awertl_setTextAlignment:textAlignment];
        }
    }];
}

- (void)awertl_setAttributedText:(NSAttributedString *)attributedText
{
    [self awertl_setAttributedText:attributedText];
    if (self.textAlignment == NSTextAlignmentNatural) {
        self.textAlignment = NSTextAlignmentLeft;
    } else {
        /// Call the original implementation via awertl_setTextAlignment to avoid repeated alignment conversion.
        [self awertl_setTextAlignment:self.textAlignment];
    }
}

@end
