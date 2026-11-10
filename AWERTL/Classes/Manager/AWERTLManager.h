//
//  AWERTLManager.h
//  AWERTL
//
//  Created by ByteDance on 2018/9/10.
//

#import <Foundation/Foundation.h>

@class AWERTLManager;

NS_ASSUME_NONNULL_BEGIN

@protocol AWERTLManagerDelegate <NSObject>

@required

- (BOOL)AWERTLManager:(AWERTLManager *)manager shouldFlipImageWithName:(NSString *)name;

@end

@interface AWERTLManager : NSObject

// Defer to the delegate when available to determine whether an image should be mirrored.
@property (nonatomic, weak, nullable) id<AWERTLManagerDelegate> delegate;

/** Enable or disable RTL adaptation. */
@property (nonatomic, assign) BOOL enableRTL;

/** Preserve the existing image name list; use it when no image flipping delegate is provided. */
@property (nonatomic, strong) NSArray<NSString *> *flipImageNames;

+ (instancetype)sharedInstance;

- (void)registerUIElement:(id)element;

- (BOOL)shouldFlipImageWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
