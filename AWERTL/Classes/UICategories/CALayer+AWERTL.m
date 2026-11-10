//
//  CALayer+AWERTL.m
//  AWERTL
//
//  Created by ByteDance on 2018/9/10.
//

#import "CALayer+AWERTL.h"
#import "AWERTLDefinitions.h"
#import "AWERTLManager.h"

static BOOL shouldEnableRTL = NO;

@implementation CALayer (AWERTL)

// Install RTL adaptations in order from a single entry point to avoid relying on category +load execution order.
+ (void)awertl_load
{
    ALPSwizzle(self, setAffineTransform:, awertl_setAffineTransform:);
    ALPSwizzle(self, affineTransform, awertl_affineTransform);
    ALPSwizzle(self, addAnimation:forKey:, awertl_addAnimation:forKey:);
    ALPSwizzle(self, renderInContext:, awertl_renderInContext:);
}

- (void)setAwertl_basicTransform:(CGAffineTransform)awertl_basicTransform
{
    // Rebuild existing scale animations only when the base mirroring changes to avoid modifying animation values repeatedly.
    NSValue *value = objc_getAssociatedObject(self, @selector(awertl_basicTransform));
    if (!value && CGAffineTransformIsIdentity(awertl_basicTransform)) {
        return;
    }
    CGAffineTransform originTransform = value ? [value CGAffineTransformValue] : CGAffineTransformIdentity;
    if (CGAffineTransformEqualToTransform(originTransform , awertl_basicTransform)) {
        return;
    }
    objc_setAssociatedObject(self, @selector(awertl_basicTransform), [NSValue valueWithCGAffineTransform:awertl_basicTransform], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.affineTransform = self.affineTransform;
    [self awertl_resetIfNeededWhenBasicTransformChanged:originTransform];
}

- (CGAffineTransform)awertl_basicTransform
{
    NSValue *value = objc_getAssociatedObject(self, _cmd);
    return value ? [value CGAffineTransformValue] : CGAffineTransformIdentity;
}

- (void)setAwertl_isRenderStartLayer:(BOOL)awertl_isRenderStartLayer
{
    objc_setAssociatedObject(self, @selector(awertl_isRenderStartLayer), @(awertl_isRenderStartLayer), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)awertl_isRenderStartLayer
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)awertl_setAffineTransform:(CGAffineTransform)m
{
    if (!shouldEnableRTL && [AWERTLManager sharedInstance].enableRTL) {
        shouldEnableRTL = YES;
    }
    if (shouldEnableRTL) {
        objc_setAssociatedObject(self, @selector(awertl_affineTransform), [NSValue valueWithCGAffineTransform:m], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self awertl_setAffineTransform:CGAffineTransformConcat(self.awertl_basicTransform, m)];
    } else {
        [self awertl_setAffineTransform:m];
    }
}

- (CGAffineTransform)awertl_affineTransform
{
    if (!shouldEnableRTL && [AWERTLManager sharedInstance].enableRTL) {
        shouldEnableRTL = YES;
    }
    if (shouldEnableRTL) {
        NSValue *value = objc_getAssociatedObject(self, @selector(awertl_affineTransform));
        return value ? [value CGAffineTransformValue] : [self awertl_affineTransform];
    } else {
        return [self awertl_affineTransform];
    }
}

- (void)awertl_addAnimation:(CAAnimation *)anim forKey:(NSString *)key
{
    // Scale animations within animation groups must also account for the layer's base mirroring.
    if ([anim isKindOfClass:[CAAnimationGroup class]]) {
        CAAnimationGroup *animationGroup = (CAAnimationGroup *)anim;
        [animationGroup.animations enumerateObjectsUsingBlock:^(CAAnimation * _Nonnull animation, NSUInteger idx, BOOL * _Nonnull stop) {
            [self awertl_adaptAnimation:animation forBasicTransform:self.awertl_basicTransform];
        }];
    } else {
        [self awertl_adaptAnimation:anim forBasicTransform:self.awertl_basicTransform];
    }
    [self awertl_addAnimation:anim forKey:key];
}

- (void)awertl_adaptAnimation:(CAAnimation *)anim forBasicTransform:(CGAffineTransform)transform
{
    if ([anim isKindOfClass:[CABasicAnimation class]]) {
        CABasicAnimation *basicAnim = (CABasicAnimation *)anim;
        if ([basicAnim.keyPath hasPrefix:@"transform.scale"] && transform.a == -1) {
            basicAnim.fromValue = @([basicAnim.fromValue floatValue] * -1);
            basicAnim.toValue = @([basicAnim.toValue floatValue] * -1);
        }
    }
}

- (void)awertl_resetIfNeededWhenBasicTransformChanged:(CGAffineTransform)originTransform
{
    // Restore animations using the old transform, then apply the new transform through the animation addition method.
    [self.animationKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CAAnimation *animation = [self animationForKey:obj];
        CAAnimation *originAnimation = [self awertl_originAnimationOfAnimation:animation withBasicTransform:originTransform];
        if (animation != originAnimation) {
            [self removeAnimationForKey:obj];
            [self addAnimation:originAnimation forKey:obj];
        }
    }];
}

- (CAAnimation *)awertl_originAnimationOfAnimation:(CAAnimation *)anim withBasicTransform:(CGAffineTransform)transform
{
    CGFloat scale = transform.a == 1 ? 1.0 : -1.0;
    if ([anim isKindOfClass:[CABasicAnimation class]]) {
        CABasicAnimation *basicAnim = (CABasicAnimation *)anim;
        if ([basicAnim.keyPath hasPrefix:@"transform.scale"]) {
            CABasicAnimation *originAnim = [basicAnim copy];
            originAnim.fromValue = @([basicAnim.fromValue floatValue] * scale);
            originAnim.toValue = @([basicAnim.toValue floatValue] * scale);
            return originAnim;
        }
    } else if ([anim isKindOfClass:[CAAnimationGroup class]]) {
        CAAnimationGroup *originAnim = [(CAAnimationGroup *)anim copy];
        __block BOOL needModifyAnimationInGroup = NO;
        [originAnim.animations enumerateObjectsUsingBlock:^(CAAnimation * _Nonnull animation, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([animation isKindOfClass:[CABasicAnimation class]]) {
                CABasicAnimation *basicAnim = (CABasicAnimation *)animation;
                if ([basicAnim.keyPath hasPrefix:@"transform.scale"]) {
                    needModifyAnimationInGroup = YES;
                    basicAnim.fromValue = @([basicAnim.fromValue floatValue] * scale);
                    basicAnim.toValue = @([basicAnim.toValue floatValue] * scale);
                }
            }
        }];
        return needModifyAnimationInGroup ? originAnim : anim;
    }
    return anim;
}

- (void)awertl_renderInContext:(CGContextRef)ctx
{
    if (!shouldEnableRTL && [AWERTLManager sharedInstance].enableRTL) {
        shouldEnableRTL = YES;
    }
    if (shouldEnableRTL) {
        BOOL isRenderStartLayer = YES;
        CGAffineTransform allSuperLayerTransform = self.awertl_basicTransform;
        CALayer *layer = self;
        while (layer.superlayer) {
            layer = layer.superlayer;
            if ([layer awertl_isRenderStartLayer]) {
                isRenderStartLayer = NO;
                break;
            }
            allSuperLayerTransform = CGAffineTransformConcat(layer.awertl_basicTransform, allSuperLayerTransform);
        }
        if (isRenderStartLayer) {
            [self setAwertl_isRenderStartLayer:YES];
            if (allSuperLayerTransform.a == -1) {
                CGContextSaveGState(ctx);
                CGContextConcatCTM(ctx, CGAffineTransformMakeScale(-1, 1));
                CGContextTranslateCTM(ctx, -self.bounds.size.width, 0);
            }
        }
        [self awertl_renderInContext:ctx];
        if (isRenderStartLayer) {
            [self setAwertl_isRenderStartLayer:NO];
            if (allSuperLayerTransform.a == -1) {
                CGContextRestoreGState(ctx);
            }
        }
    } else {
        [self awertl_renderInContext:ctx];
    }
}

@end
