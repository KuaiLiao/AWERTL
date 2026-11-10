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
        // Use weak references and deduplicate by object identity to avoid duplicate notifications from repeated attachment or multiple reload blocks.
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
    // Check the current delegate each time to avoid using stale selector support information after it is replaced or deallocated.
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
    // Take a snapshot before reloading so callbacks can register new objects.
    NSArray *elements = self.registeredUIElements.allObjects;
    NSMutableSet<UIView *> *rootViews = [NSMutableSet set];
    for (id object in elements) {
        [object awertl_performReload];
        // Reload blocks also support non-view objects; only UIView instances participate in root view mirroring updates.
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
        /// Work around collection view alignment issues.
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
