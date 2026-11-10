//
//  UITextField+AWERTL.h
//  AWERTL
//
//  Created by ByteDance on 2018/12/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (AWERTL)

// Install RTL adaptations in order from a single entry point to avoid relying on category +load execution order.
+ (void)awertl_load;

@end

NS_ASSUME_NONNULL_END
