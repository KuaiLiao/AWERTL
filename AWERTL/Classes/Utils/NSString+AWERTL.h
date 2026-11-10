//
//  NSString+AWERTL.h
//  Pods
//
//  Created by 唐健 on 2019/5/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (AWERTL)

- (BOOL)isRTLString;
- (BOOL)isLTRString;
- (NSString *)RTLString;
- (NSString *)LTRString;

/**
 FSI = FIRST-STRONG ISOLATE
 isolates the content and sets the direction according to the first strongly typed directional character
 返回的string的write direction由内部第一个强类型的字符决定，不受外部的影响，也不会影响外部

 @return 不受整体write direction影响的string
 */
- (NSString *)awertl_FSIString;

@end

NS_ASSUME_NONNULL_END
