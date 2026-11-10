//
//  TTTAttributedLabel+LocalizationsPlus.h
//  AWELocalizations-iOS
//
//  Created by ByteDance on 2018/2/22.
//

#import <UIKit/UIKit.h>

@interface AWERTLTTTAttributedLabel : NSObject

// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load;

@end
