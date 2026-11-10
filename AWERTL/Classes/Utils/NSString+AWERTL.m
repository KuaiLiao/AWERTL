//
//  NSString+AWERTL.m
//  Pods
//
//  Created by 唐健 on 2019/5/23.
//

#import "NSString+AWERTL.h"

@implementation NSString (AWERTL)

- (BOOL)isRTLString
{
    return [self hasPrefix:@"\u202B"];
}

- (BOOL)isLTRString
{
    return [self hasPrefix:@"\u202A"];
}

- (NSString *)RTLString
{
    if ([self isRTLString] || [self isLTRString]) {
        return self;
    }
    return [NSString stringWithFormat:@"\u202B%@\u202C", self];
}

- (NSString *)LTRString
{
    if ([self isRTLString] || [self isLTRString]) {
        return self;
    }
    return [NSString stringWithFormat:@"\u202A%@\u202C", self];
}

- (NSString *)awertl_FSIString
{
    // 用 FSI/PDI 包裹内容，隔离内部首个强方向字符与外部文本方向。
    return [NSString stringWithFormat:@"\u2068%@\u2069", self];
}

@end
