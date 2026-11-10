//
//  UIImageView+AWERTL.h
//  AWERTL
//
//  Created by ByteDance on 2018/12/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (AWERTL)

// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load;

/** 记录最近一次设置的原始图片，支持清空图片。 */
@property (nonatomic, strong, nullable) UIImage *awerl_origin_image;

@end

NS_ASSUME_NONNULL_END
