//
//  KTJPushQueueForNavigationDelegate.h
//  https://github.com/madordie/KTJPushQueueForNavigation.git
//
//  Created by 孙继刚 on 15/12/13.
//  Copyright © 2015年 Madordie. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  如果你想使用该类，你必须在代理中手动调用此暴露的所有方法
 */
@interface KTJPushQueueForNavigationDelegate : NSObject


// Called when the navigation controller shows a new top view controller via a push, pop or setting of the view controller stack.
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

//  提供以下接口进行调用
//      1、采用类别的方式，并且可以自定义所HOOK的类，对XXNavigationController宏进行赋值即可。可以自定义Navigation可以UINavigation。
//      2、采用集成的方式，继承自此类。无HOOK。无HOOK。无HOOK。
//  用法：
//      1、选择上面两种方式使用;
//      2、设置ktj_useNavPushQueue = YES。默认NO;
//      3、在Navigation的代理中调用如下代码
//        // Called when the navigation controller shows a new top view controller via a push, pop or setting of the view controller stack.
//        - (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//            [self.ktj_navPushQueue navigationController:navigationController willShowViewController:viewController animated:animated];
//        }
//        - (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//            [self.ktj_navPushQueue navigationController:navigationController didShowViewController:viewController animated:animated];
//        }
//
//  ⚠️：如果在代理中没有调用，则将采用默认延迟0.5s推页面的操作。
//      上面的操作，不是每一个机型此延迟均有效的。比如：自测使用的iPhone 5C 7.1.2无效
//  ❌：如果使用，请按照用法1.2.3.进行操作，不使用别引用。防止误操作的HOOK造成代码影响。

/*  打开以下宏则使用HOOK方式进行    */
//#define KTJNavQueueUseExtension

#ifdef KTJNavQueueUseExtension

    #import "NavigationController.h" //  根据自己需要引入自己NavigationController的头文件并赋给下方宏
    #define KTJXXNavigationController  NavigationController
    @interface KTJXXNavigationController (KTJPushQueue)

    @property (nonatomic, assign) BOOL ktj_useNavPushQueue; //  default NO.

    @property (nonatomic, strong, readonly) KTJPushQueueForNavigationDelegate *ktj_navPushQueue;

    @end

#else

    @interface KTJPushQueueForNavigation : UINavigationController

    - (void)setKtj_useNavPushQueue:(BOOL)ktj_useNavPushQueue;
    - (BOOL)ktj_useNavPushQueue;    //  Default NO.

    - (KTJPushQueueForNavigationDelegate *)ktj_navPushQueue;

    @end

    @interface UIViewController (KTJPushQueue)

    /**
     *  需要手动在viewDidDisappear
     */
    - (void)ktj_tellMeViewDidAppear;

    @end

#endif