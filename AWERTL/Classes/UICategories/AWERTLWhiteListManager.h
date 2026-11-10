//
//  AWERTLWhiteListManager.h
//  AWERTL
//
//  Created by ByteDance on 2018/12/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWERTLWhiteListManager : NSObject

// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load;

@end

NS_ASSUME_NONNULL_END
