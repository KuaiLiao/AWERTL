//
//  AWERTLYYTextAdaption.h
//  Pods
//
//  Created by ByteDance on 2018/12/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWERTLYYTextAdaption : NSObject

// Install RTL adaptations in order from a single entry point to avoid relying on category +load execution order.
+ (void)awertl_load;

@end

NS_ASSUME_NONNULL_END
