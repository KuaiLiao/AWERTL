//
//  UIWebView+AWERTL.m
//  AWERTL
//
//  Created by ByteDance on 2018/10/9.
//

#import "AWERTLRemoteViewControllerAdaptor.h"
#import "UIView+AWERTL.h"
#import "AWERTLDefinitions.h"
#import "AWERTLManager.h"

@implementation SFSafariViewController (AWERTL)

// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load
{
    ALPSwizzle(self, viewDidLoad, alpweb_viewDidLoad);
}

- (void)alpweb_viewDidLoad
{
    [self alpweb_viewDidLoad];
    self.view.awertl_viewType = AWERTLViewTypeNormalWithAllDescendants;
}

@end

@implementation SKCloudServiceSetupViewController (AWERTL)

// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load
{
    ALPSwizzle(self, viewDidLoad, alpsk_viewDidLoad);
}

- (void)alpsk_viewDidLoad
{
    [self alpsk_viewDidLoad];
    self.view.awertl_viewType = AWERTLViewTypeNormalWithAllDescendants;
}

@end

@implementation UIActivityViewController (AWERTL)

// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load
{
    ALPSwizzle(self, viewDidLoad, alp_act_viewDidLoad);
}

- (void)alp_act_viewDidLoad
{
    [self alp_act_viewDidLoad];
    self.view.awertl_viewType = AWERTLViewTypeNormalWithAllDescendants;
}

@end

@implementation UIImagePickerController (AWERTL)

// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load
{
    ALPSwizzle(self, loadView, alp_act_loadView);
}

- (void)alp_act_loadView
{
    [self alp_act_loadView];
    self.view.awertl_viewType = AWERTLViewTypeNormalWithAllDescendants;
}

@end

@implementation SKStoreProductViewController (AWERTL)

// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load
{
    ALPSwizzle(self, loadView, alp_act_loadView);
}

- (void)alp_act_loadView
{
    [self alp_act_loadView];
    self.view.awertl_viewType = AWERTLViewTypeNormalWithAllDescendants;
}

@end

@implementation UINavigationController (AWERTL)

// 由统一入口按顺序安装 RTL 适配，避免分类的 +load 执行顺序不确定。
+ (void)awertl_load
{
    ALPSwizzle(self, loadView, alp_act_loadView);
}

- (void)alp_act_loadView {
    [self alp_act_loadView];
    /// 必须设置，不然系统设置阿拉伯文，内置也设置阿拉文是，手势有问题
    self.view.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
}

@end
