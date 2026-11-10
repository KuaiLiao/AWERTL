//
//  CALayer+AWERTL.h
//  AWERTL
//
//  Created by ByteDance on 2018/9/10.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (AWERTL)

/**
 * Additional property for CALayer, which will be multiplied to the original transform before set.
 */
@property (nonatomic, assign) CGAffineTransform awertl_basicTransform;

// Install RTL adaptations in order from a single entry point to avoid relying on category +load execution order.
+ (void)awertl_load;

@end

NS_ASSUME_NONNULL_END
