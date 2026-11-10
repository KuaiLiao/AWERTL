//
//  TTTAttributedLabel+LocalizationsPlus.h
//  AWELocalizations-iOS
//
//  Created by ByteDance on 2018/2/22.
//

#import <UIKit/UIKit.h>

@interface AWERTLTTTAttributedLabel : NSObject

// Install RTL adaptations in order from a single entry point to avoid relying on category +load execution order.
+ (void)awertl_load;

@end
