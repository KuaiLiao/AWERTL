//
//  UIWebView+AWERTL.h
//  AWERTL
//
//  Created by ByteDance on 2018/10/9.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <SafariServices/SafariServices.h>
#import <StoreKit/StoreKit.h>


@interface SFSafariViewController (AWERTL)
// Install RTL adaptations in order from a single entry point to avoid relying on category +load execution order.
+ (void)awertl_load;
@end

@interface SKCloudServiceSetupViewController (AWERTL)
// Install RTL adaptations in order from a single entry point to avoid relying on category +load execution order.
+ (void)awertl_load;
@end

@interface UIActivityViewController (AWERTL)
// Install RTL adaptations in order from a single entry point to avoid relying on category +load execution order.
+ (void)awertl_load;
@end

@interface UIImagePickerController (AWERTL)
// Install RTL adaptations in order from a single entry point to avoid relying on category +load execution order.
+ (void)awertl_load;
@end

@interface SKStoreProductViewController (AWERTL)
// Install RTL adaptations in order from a single entry point to avoid relying on category +load execution order.
+ (void)awertl_load;
@end

@interface UINavigationController (AWERTL)
// Install RTL adaptations in order from a single entry point to avoid relying on category +load execution order.
+ (void)awertl_load;
@end
