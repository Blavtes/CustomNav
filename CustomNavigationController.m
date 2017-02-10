//
//  CustomNavigationController.m
//
//  Created by Blavtes on 15/4/26.
//  Copyright (c) 2015年 Blavtes. All rights reserved.
//

#import "CustomNavigationController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - 设置导航栏通用主题
/**
 *  在程序运行过程中 会在你程序中每个类调用一次initialize
 *  在这里设置Navigation相应主题
 */
+ (void)initialize
{
    //  设置UINavigationBar的主题
    [self setupNavigationBarTheme];
    
    //  设置UINavigationItem的主题
    [self setupNavigationItemTheme];
}

/**
 *  设置UINavigationBar的主题
 */
+ (void)setupNavigationBarTheme
{
    UINavigationBar *appearance = [UINavigationBar appearance];

    //  设置naviBar背景图片 - UIBarMetricsDefault/UIBarMetricsCompact
    if (isRetina) {
        [appearance setBackgroundImage:[UIImage imageNamed:@"navi_background_for_iphone4s"] forBarMetrics:UIBarMetricsDefault];
        appearance.barStyle = UIBarStyleBlack;
    } else {
        //  去掉导航栏的边界灰线
        [appearance setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        if (IOS7 && IOS_VERSION >= 8.0 && FourInch) {
            //  ios7以上关闭透明度
#pragma mark -- bug fix - ios8.0以后才设置
            appearance.translucent = NO;
        }
        appearance.barTintColor = COMMON_BLUE_GREEN_COLOR;
    }
    //  去掉下方shadow线
    [appearance setShadowImage:[[UIImage alloc] init]];
    
    //  设置文字属性 去掉阴影
    NSMutableDictionary *textDic = [NSMutableDictionary dictionary];
    textDic[UITextAttributeTextColor] = [UIColor whiteColor];
    //  过期 : 并不代表不能用, 仅仅是有最新的方案可以取代它
    //  UITextAttributeFont  --> NSFontAttributeName(iOS7)
    textDic[UITextAttributeFont] = CommonNavigationTitleFont;
    //  取消阴影就是将offset设置为0
    textDic[UITextAttributeTextShadowOffset] = [NSValue valueWithUIOffset:UIOffsetZero];
    [appearance setTitleTextAttributes:textDic];
}

/**
 *  设置UINavigationItem的主题
 */
+ (void)setupNavigationItemTheme
{
    // 通过appearance对象能修改整个项目中所有UIBarButtonItem的样式
    UIBarButtonItem *appearance = [UIBarButtonItem appearance];
    
    /**设置文字属性**/
    // 设置普通状态的文字属性
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[UITextAttributeTextColor] = [UIColor whiteColor];
    textAttrs[UITextAttributeFont] = [UIFont systemFontOfSize:15];
    textAttrs[UITextAttributeTextShadowOffset] = [NSValue valueWithUIOffset:UIOffsetZero];
    [appearance setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
    // 设置高亮状态的文字属性
    NSMutableDictionary *highTextAttrs = [NSMutableDictionary dictionaryWithDictionary:textAttrs];
    highTextAttrs[UITextAttributeTextColor] = [UIColor redColor];
    [appearance setTitleTextAttributes:highTextAttrs forState:UIControlStateHighlighted];
    
    // 设置不可用状态(disable)的文字属性
    NSMutableDictionary *disableTextAttrs = [NSMutableDictionary dictionaryWithDictionary:textAttrs];
    disableTextAttrs[UITextAttributeTextColor] = [UIColor lightGrayColor];
    [appearance setTitleTextAttributes:disableTextAttrs forState:UIControlStateDisabled];
    
    /**设置背景**/
    // 技巧: 为了让某个按钮的背景消失, 可以设置一张完全透明的背景图片
    [appearance setBackgroundImage:[UIImage imageWithName:@"navigationbar_button_background"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

}

#pragma mark - 设置导航栏通用按钮
/**
 *  拦截所有push进来的子Vc 判断是否是栈底控制器来实现导航栏的通用按钮
 *
 *  @param viewController Vc
 *  @param animated       animated
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //  如果push进来的不是栈底控制器 则隐藏底部tabBar
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
        
        //  设置通用的导航栏按钮
        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"btn_navi_back" highlightImageName:@"btn_navi_back_selected" taget:self action:@selector(back)];
    
    }
    
#pragma mark - 采集数据[只统计非启动加载 && 非tabbar切换]
    //  目标类
    NSString *curClassName = [NSString stringWithUTF8String:object_getClassName(viewController)];
    
    if (self.viewControllers.count > 0) {
        //  当前类 - src
        NSString *srcClassName = [NSString stringWithUTF8String:object_getClassName(self.viewControllers[[self.viewControllers count] - 1])];
        //  配置数据信息
        GjFaxUserBehaviorModel *dataModel = [GjFaxUserBehaviorModel modelWithSrcClassName:srcClassName andCurClassName:curClassName];
        //  保存
        [[GjFaxDataCollection manager] collectUserBehavior:dataModel];
    }
 
#pragma mark - push跳转
    //  pushVc
    [super pushViewController:viewController animated:animated];
}

/**
 *  拦截所有present进来的子Vc 判断是否是栈底控制器来实现导航栏的通用按钮
 *
 *  @param viewController Vc
 *  @param animated       animated
 */
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {

    //DLog(@"presentVc = %@", [viewControllerToPresent class]);
    //  判断是否naviVc进来
    if (![viewControllerToPresent isKindOfClass:[UINavigationController class]] && [viewControllerToPresent isKindOfClass:[UIViewController class]]) {
        //  在presentVc的时候本身无navVc,需要自己创建一个navigationController，这样ViewController的navigationController属性不为nil,即可使用pushViewController。
        CustomNavigationController *navigationController = [[CustomNavigationController alloc] initWithRootViewController:viewControllerToPresent];
        
        //  设置通用的导航栏按钮
        //navigationController.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"btn_navi_back" highlightImageName:@"btn_navi_back_selected" taget:self action:@selector(presentBack)];
        
        
        //  presentVc
        [super presentViewController:navigationController animated:flag completion:completion];
    } else {
        //  presentVc
        [super presentViewController:viewControllerToPresent animated:flag completion:completion];
    }

}

#pragma mark - navi的pop
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *curVc = [super popViewControllerAnimated:animated];
    
#pragma mark - 采集数据[只统计非启动加载 && 非tabbar切换]
    //  目标类
    NSString *curClassName = [NSString stringWithUTF8String:object_getClassName(curVc)];
    
    if (self.viewControllers.count > 0) {
        //  当前类 - src
        NSString *srcClassName = [NSString stringWithUTF8String:object_getClassName(self.viewControllers[[self.viewControllers count] - 1])];
        //  配置数据信息[pop的时候src和cur是相反的，路线为cur->src]
        GjFaxUserBehaviorModel *dataModel = [GjFaxUserBehaviorModel modelWithSrcClassName:curClassName andCurClassName:srcClassName];
        //  保存
        [[GjFaxDataCollection manager] collectUserBehavior:dataModel];
    }
    
    return curVc;
}

- (nullable NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
#pragma mark - 采集数据[只统计非启动加载 && 非tabbar切换]
    //  目标类
    NSString *curClassName = [NSString stringWithUTF8String:object_getClassName(self.topViewController)];
    
    if (self.viewControllers.count > 0) {
        //  当前类 - src
        NSString *srcClassName = [NSString stringWithUTF8String:object_getClassName(self.viewControllers[0])];
        //  配置数据信息[pop的时候src和cur是相反的，路线为cur->src]
        GjFaxUserBehaviorModel *dataModel = [GjFaxUserBehaviorModel modelWithSrcClassName:curClassName andCurClassName:srcClassName];
        //  保存
        [[GjFaxDataCollection manager] collectUserBehavior:dataModel];
    }
    
    return [super popToRootViewControllerAnimated:animated];
}

/**
 *  弹出当前Vc
 */
- (void)back
{
    //  这里用的是self, 因为self就是当前正在使用的导航控制器
    [self popViewControllerAnimated:YES];
}

/**
 *  弹出当前非根Vc
 */
- (void)more
{
    [self popToRootViewControllerAnimated:YES];
}

/**
 *  弹出当前Vc
 */
- (void)presentBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIViewController* topVC = self.topViewController;
    
    return [topVC preferredStatusBarStyle];
    
}
@end
