//
//  AWERTLTests.m
//  AWERTLTests
//

@import XCTest;
#import "AWERTLManager.h"
#import "NSString+AWERTL.h"
#import "UIImage+AWERTL.h"
#import "UIImageView+AWERTL.h"
#import "CALayer+AWERTL.h"
#import "NSObject+AWERTLReloadBlock.h"
#import "UITextView+AWERTL.h"
#import "UIView+AWERTL.h"

// 用可切换的代理验证动态图片决策，以及代理释放后的名单回退。
@interface AWERTLTestImageDelegate : NSObject <AWERTLManagerDelegate>
@property (nonatomic, assign) BOOL shouldFlip;
@end

@implementation AWERTLTestImageDelegate
- (BOOL)AWERTLManager:(AWERTLManager *)manager shouldFlipImageWithName:(NSString *)name
{
    return self.shouldFlip && [name isEqualToString:@"arrow"];
}
@end

@interface Tests : XCTestCase
@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // 每个用例都从 LTR 开始，避免单例状态影响后续断言。
    [AWERTLManager sharedInstance].delegate = nil;
    [AWERTLManager sharedInstance].enableRTL = NO;
    [AWERTLManager sharedInstance].flipImageNames = @[];
}

- (void)tearDown
{
    [AWERTLManager sharedInstance].delegate = nil;
    [AWERTLManager sharedInstance].enableRTL = NO;
    [super tearDown];
}

- (void)testReloadBlockOnNonViewObjectFollowsDirectionChanges
{
    // 刷新注册覆盖所有 NSObject，不能依赖加入视图层级的时机。
    NSObject *object = [NSObject new];
    __block NSUInteger reloadCount = 0;
    [object awertl_addReloadBlockForKey:@"direction" andExecuteIt:^{ reloadCount++; }];
    XCTAssertEqual(reloadCount, 1u);
    [AWERTLManager sharedInstance].enableRTL = YES;
    XCTAssertEqual(reloadCount, 2u);
}

- (void)testDetachedViewReloadsAfterDirectionChanges
{
    // 尚未挂载到窗口的视图也要收到语言切换后的刷新。
    UIView *view = [UIView new];
    __block NSUInteger reloadCount = 0;
    [view awertl_addReloadBlockForKey:@"direction" andExecuteIt:^{ reloadCount++; }];
    [AWERTLManager sharedInstance].enableRTL = YES;
    XCTAssertEqual(reloadCount, 2u);
}

- (void)testAnimationGroupScalesFollowMirroredLayer
{
    // 动画组内的缩放动画应与单独添加的缩放动画采用相同镜像规则。
    CALayer *layer = [CALayer layer];
    layer.awertl_basicTransform = CGAffineTransformMakeScale(-1, 1);
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    scale.fromValue = @1;
    scale.toValue = @2;
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[scale];
    group.duration = 100;
    [layer addAnimation:group forKey:@"scale"];
    CABasicAnimation *installed = (id)[(CAAnimationGroup *)[layer animationForKey:@"scale"] animations].firstObject;
    XCTAssertEqualObjects(installed.fromValue, @-1);
    XCTAssertEqualObjects(installed.toValue, @-2);
}

- (void)testRunningScaleAnimationFollowsDirectionChanges
{
    // 切换镜像状态时重建已有动画，恢复 LTR 后数值也应还原。
    CALayer *layer = [CALayer layer];
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    scale.fromValue = @1;
    scale.toValue = @2;
    scale.duration = 100;
    [layer addAnimation:scale forKey:@"scale"];
    layer.awertl_basicTransform = CGAffineTransformMakeScale(-1, 1);
    XCTAssertEqualObjects([(CABasicAnimation *)[layer animationForKey:@"scale"] toValue], @-2);
    layer.awertl_basicTransform = CGAffineTransformIdentity;
    XCTAssertEqualObjects([(CABasicAnimation *)[layer animationForKey:@"scale"] toValue], @2);
}

- (void)testRunningAnimationGroupRestoresItsScaleAfterDirectionChanges
{
    // 运行中的动画组在 RTL 与 LTR 之间切换时，只改动缩放分量。
    CALayer *layer = [CALayer layer];
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    scale.fromValue = @1;
    scale.toValue = @2;
    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.fromValue = @0;
    opacity.toValue = @1;
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[scale, opacity];
    group.duration = 100;
    [layer addAnimation:group forKey:@"group"];
    layer.awertl_basicTransform = CGAffineTransformMakeScale(-1, 1);
    CAAnimationGroup *mirrored = (id)[layer animationForKey:@"group"];
    XCTAssertEqualObjects([(CABasicAnimation *)mirrored.animations[0] toValue], @-2);
    XCTAssertEqualObjects([(CABasicAnimation *)mirrored.animations[1] toValue], @1);
    layer.awertl_basicTransform = CGAffineTransformMakeScale(-1, 1);
    XCTAssertEqualObjects([(CABasicAnimation *)[(CAAnimationGroup *)[layer animationForKey:@"group"] animations][0] toValue], @-2);
    layer.awertl_basicTransform = CGAffineTransformIdentity;
    XCTAssertEqualObjects([(CABasicAnimation *)[(CAAnimationGroup *)[layer animationForKey:@"group"] animations][0] toValue], @2);
}

- (void)testTextContainerInsetsMirrorInRTL
{
    // 不对称的左右边距在 RTL 下交换，上下边距保持原值。
    UITextView *view = [UITextView new];
    [AWERTLManager sharedInstance].enableRTL = YES;
    view.textContainerInset = UIEdgeInsetsMake(1, 2, 3, 4);
    XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(view.textContainerInset, UIEdgeInsetsMake(1, 4, 3, 2)));
}

- (void)testFirstStrongIsolateWrapsTextAndEmptyStrings
{
    // FSI/PDI 应严格包裹原始文本，不修改其内容。
    XCTAssertEqualObjects([@"مرحبا 123" awertl_FSIString], @"\u2068مرحبا 123\u2069");
    XCTAssertEqualObjects([@"" awertl_FSIString], @"\u2068\u2069");
}

- (void)testLegacyImageNamesStillControlImageFlipping
{
    // 原有名单 API 继续影响 UIImageView 的自动翻转策略。
    [AWERTLManager sharedInstance].flipImageNames = @[@"arrow"];
    UIImage *image = [UIImage new];
    image.awertl_imageName = @"arrow";
    UIImageView *view = [UIImageView new];
    view.image = image;
    XCTAssertEqual(view.awertl_viewType, AWERTLViewTypeFlip);
    XCTAssertEqual(view.awerl_origin_image, image);
    view.image = nil;
    XCTAssertNil(view.awerl_origin_image);
}

- (void)testImageDelegateOverridesNamesAndFallsBackWhenReleased
{
    // 代理的 NO 同样是有效决策；代理释放后恢复使用原有名单。
    AWERTLManager *manager = [AWERTLManager sharedInstance];
    manager.flipImageNames = @[@"arrow"];
    @autoreleasepool {
        AWERTLTestImageDelegate *delegate = [AWERTLTestImageDelegate new];
        manager.delegate = delegate;
        delegate.shouldFlip = YES;
        XCTAssertTrue([manager shouldFlipImageWithName:@"arrow"]);
        delegate.shouldFlip = NO;
        XCTAssertFalse([manager shouldFlipImageWithName:@"arrow"]);
        XCTAssertFalse([manager shouldFlipImageWithName:@"other"]);
    }
    XCTAssertNil(manager.delegate);
    XCTAssertTrue([manager shouldFlipImageWithName:@"arrow"]);
}

- (void)testReplacingImageDelegateChecksCurrentSelectorSupport
{
    // 更换为不支持协议方法的对象后不能复用上一个代理的能力缓存。
    AWERTLManager *manager = [AWERTLManager sharedInstance];
    AWERTLTestImageDelegate *delegate = [AWERTLTestImageDelegate new];
    delegate.shouldFlip = YES;
    manager.delegate = delegate;
    XCTAssertTrue([manager shouldFlipImageWithName:@"arrow"]);
    NSObject *replacement = [NSObject new];
    manager.delegate = (id)replacement;
    XCTAssertFalse([manager shouldFlipImageWithName:@"arrow"]);
}

- (void)testForcedFlipBypassesParentTransformCancellation
{
    // 父子同为翻转视图时，显式强制开关仍使子视图图层镜像。
    [AWERTLManager sharedInstance].enableRTL = YES;
    UIView *parent = [UIView new];
    // 本用例不创建窗口，显式注册离屏根视图以验证方向切换后的刷新。
    [[AWERTLManager sharedInstance] registerUIElement:parent];
    parent.awertl_viewType = AWERTLViewTypeFlip;
    UIView *child = [UIView new];
    child.awertl_viewType = AWERTLViewTypeFlip;
    [parent addSubview:child];
    XCTAssertTrue(CGAffineTransformIsIdentity(child.layer.awertl_basicTransform));
    child.lm_awt_forceFlip_no_calculate = YES;
    [child awertl_renewLayerTransformForceRecursively:NO];
    XCTAssertEqual(child.layer.awertl_basicTransform.a, -1);
    [AWERTLManager sharedInstance].enableRTL = NO;
    XCTAssertTrue(CGAffineTransformIsIdentity(child.layer.awertl_basicTransform));
}

- (void)testDuplicateRegistrationOnlyReloadsOnce
{
    // 手动注册与刷新块注册重叠时，每次方向切换只执行一次刷新。
    UIView *view = [UIView new];
    __block NSUInteger reloadCount = 0;
    [view awertl_addReloadBlockForKey:@"direction" andExecuteIt:^{ reloadCount++; }];
    [[AWERTLManager sharedInstance] registerUIElement:view];
    [[AWERTLManager sharedInstance] registerUIElement:view];
    [AWERTLManager sharedInstance].enableRTL = YES;
    XCTAssertEqual(reloadCount, 2u);
}

- (void)testRegistrationDoesNotRetainReloadObjects
{
    // 管理器弱引用注册对象，不延长业务对象的生命周期。
    __weak NSObject *weakObject;
    @autoreleasepool {
        NSObject *object = [NSObject new];
        weakObject = object;
        [object awertl_addReloadBlockForKey:@"direction" andExecuteIt:^{}];
    }
    XCTAssertNil(weakObject);
    [AWERTLManager sharedInstance].enableRTL = YES;
}

- (void)testNavigationAndCollectionViewsUseLeftToRightSemantics
{
    // 镜像由 AWERTL 处理，导航手势和集合布局保持系统 LTR 语义。
    [AWERTLManager sharedInstance].enableRTL = YES;
    UINavigationController *navigation = [UINavigationController new];
    [navigation loadViewIfNeeded];
    XCTAssertEqual(navigation.view.semanticContentAttribute, UISemanticContentAttributeForceLeftToRight);
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [window addSubview:collection];
    XCTAssertEqual(collection.semanticContentAttribute, UISemanticContentAttributeForceLeftToRight);
}

- (void)testPlainViewsFollowDirectionChangesWithoutReloadBlocks
{
    // 普通视图没有刷新块时，原有的窗口注册路径仍需保持有效。
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UIView *view = [UIView new];
    [window addSubview:view];
    [AWERTLManager sharedInstance].enableRTL = YES;
    XCTAssertEqual(window.layer.awertl_basicTransform.a, -1);
    [AWERTLManager sharedInstance].enableRTL = NO;
    XCTAssertTrue(CGAffineTransformIsIdentity(window.layer.awertl_basicTransform));
}

@end
