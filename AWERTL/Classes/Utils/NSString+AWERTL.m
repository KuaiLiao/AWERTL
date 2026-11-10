//
//  NSString+AWERTL.m
//  Pods
//
//  Created by Tang Jian on 2019/5/23.
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
    // Wrap the content in FSI/PDI to isolate its first strong directional character from the surrounding text direction.
    return [NSString stringWithFormat:@"\u2068%@\u2069", self];
}

@end
