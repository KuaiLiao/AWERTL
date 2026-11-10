//
//  NSString+AWERTL.h
//  Pods
//
//  Created by Tang Jian on 2019/5/23.
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
 The returned string uses its first strong directional character to determine its writing direction, independently of the surrounding text and without affecting it.

 @return A string whose writing direction is independent of the surrounding text.
 */
- (NSString *)awertl_FSIString;

@end

NS_ASSUME_NONNULL_END
