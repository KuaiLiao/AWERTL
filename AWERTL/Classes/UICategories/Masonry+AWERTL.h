//
//  ALPMasonryAdaption.h
//  AWELocalizations-iOS
//
//  Created by ByteDance on 2018/2/11.
//

#import <Foundation/Foundation.h>

@interface AWERTLMasonryAdaption : NSObject

// Install RTL adaptations in order from a single entry point to avoid relying on category +load execution order.
+ (void)awertl_load;

@end
