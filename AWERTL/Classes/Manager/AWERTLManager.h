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

// 代理存在时优先由代理决定图片是否需要镜像。
@property (nonatomic, weak, nullable) id<AWERTLManagerDelegate> delegate;

/** 开启或关闭 RTL 适配。 */
@property (nonatomic, assign) BOOL enableRTL;

/** 保留原有图片名单配置；未提供图片翻转代理时使用此名单。 */
@property (nonatomic, strong) NSArray<NSString *> *flipImageNames;

+ (instancetype)sharedInstance;

- (void)registerUIElement:(id)element;

- (BOOL)shouldFlipImageWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
