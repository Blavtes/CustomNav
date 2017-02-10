//
//  CustomTabBarViewController.h
//
//  Created by Blavtes on 15/4/26.
//  Copyright (c) 2015年 Blavtes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTabBarViewController : UITabBarController
//  上一次选择
@property (nonatomic, readonly) int lastSelectedIndex;

/*
 *  用于3DTouch，强制返回到首页
 */
- (void)fetch3DTouchCallBackHome;

/*
 *  回到tabbar特定页，会清空navi的子VC
 */
- (void)callBackHomeWithIndex:(int)selectIndex;

@end
