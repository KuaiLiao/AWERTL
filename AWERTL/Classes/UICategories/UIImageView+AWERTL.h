//
//  UIImageView+AWERTL.h
//  AWERTL
//
//  Created by ByteDance on 2018/12/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (AWERTL)

// Install RTL adaptations in order from a single entry point to avoid relying on category +load execution order.
+ (void)awertl_load;

/** Stores the most recently assigned original image; setting it to nil clears the stored image. */
@property (nonatomic, strong, nullable) UIImage *awerl_origin_image;

@end

NS_ASSUME_NONNULL_END
