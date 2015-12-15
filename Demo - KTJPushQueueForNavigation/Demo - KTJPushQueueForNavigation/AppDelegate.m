//
//  AppDelegate.m
//  Demo - KTJPushQueueForNavigation
//
//  Created by 孙继刚 on 15/12/14.
//  Copyright © 2015年 Madordie. All rights reserved.
//

#import "AppDelegate.h"
#import "KTJPushQueueForNavigationDelegate.h"
#import "ViewController.h"

@interface AppDelegate () <UINavigationControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    
    KTJPushQueueForNavigation *navigation = [[KTJPushQueueForNavigation alloc] initWithRootViewController:[ViewController new]];
    navigation.ktj_useNavPushQueue = YES;
    navigation.delegate = self;
    self.window.rootViewController = navigation;
    
    
    
    [self.window makeKeyAndVisible];
    return YES;
}

// Called when the navigation controller shows a new top view controller via a push, pop or setting of the view controller stack.
- (void)navigationController:(KTJPushQueueForNavigation *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [navigationController.ktj_navPushQueue navigationController:navigationController willShowViewController:viewController animated:animated];
}
- (void)navigationController:(KTJPushQueueForNavigation *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [navigationController.ktj_navPushQueue navigationController:navigationController didShowViewController:viewController animated:animated];
}







- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
