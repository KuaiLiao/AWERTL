//
//  AWERTLManager.m
//  AWERTL
//
//  Created by ByteDance on 2018/9/10.
//

#import "AWERTLManager.h"
#import "UIView+AWERTL.h"
#import "NSObject+AWERTLReloadBlock.h"
#import "AWERTLDefinitions.h"

@interface AWERTLManager ()

@property (nonatomic, strong) NSHashTable<id> *registeredUIElements;

@end

@implementation AWERTLManager

+ (instancetype)sharedInstance
{
    static AWERTLManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AWERTLManager alloc] init];
        // 弱引用且按对象地址去重，避免重复挂载或多个刷新块导致重复通知。
        manager.registeredUIElements = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality];
    });
    return manager;
}

- (void)registerUIElement:(id)element
{
    if (element) {
        [self.registeredUIElements addObject:element];
    }
}

- (BOOL)shouldFlipImageWithName:(NSString *)name
{
    // 每次读取当前代理，避免代理更换或释放后复用旧的响应能力缓存。
    id<AWERTLManagerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(AWERTLManager:shouldFlipImageWithName:)]) {
        return [delegate AWERTLManager:self shouldFlipImageWithName:name];
    }
    return [self.flipImageNames containsObject:name];
}

- (void)setEnableRTL:(BOOL)enableRTL
{
    if (enableRTL == _enableRTL) {
        return;
    }
    _enableRTL = enableRTL;
    // 复制快照后刷新，允许回调过程中注册新对象。
    NSArray *elements = self.registeredUIElements.allObjects;
    NSMutableSet<UIView *> *rootViews = [NSMutableSet set];
    for (id object in elements) {
        [object awertl_performReload];
        // 刷新块也支持非视图对象，只有 UIView 才参与根视图镜像更新。
        if (![object isKindOfClass:[UIView class]]) {
            continue;
        }
        UIView *element = object;
        if (element.window && element.window != element) {
            continue;
        }
        
        [rootViews addObject:[self rootViewForView:element]];
    }
    
    [rootViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj awertl_renewLayerTransformForceRecursively:YES];
    }];
    
    if (@available(iOS 9_0, *)) {
        UISemanticContentAttribute attr = enableRTL ? UISemanticContentAttributeForceRightToLeft : UISemanticContentAttributeForceLeftToRight;
        [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        [UISearchBar appearance].semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        /// collectionView靠齐方式有问题
        [UICollectionView appearance].semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        [UILabel appearance].semanticContentAttribute = attr;
        [UITextField appearance].semanticContentAttribute = attr;
        [UITextView appearance].semanticContentAttribute = attr;
        [UIDatePicker appearance].semanticContentAttribute = attr;
        [UIView appearanceWhenContainedInInstancesOfClasses:@[[UIDatePicker class]]].semanticContentAttribute = attr;
    }
}

- (UIView *)rootViewForView:(UIView *)view
{
    if (view.window) {
        return view.window;
    }
    UIView *rootView = view;
    while (rootView.superview) {
        rootView = rootView.superview;
    }
    return rootView;
}

@end
