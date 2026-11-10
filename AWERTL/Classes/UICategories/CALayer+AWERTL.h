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

// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load;

@end

NS_ASSUME_NONNULL_END
