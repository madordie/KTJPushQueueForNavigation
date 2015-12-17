//
//  KTJPushQueueForNavigationDelegate.m
//  https://github.com/madordie/KTJPushQueueForNavigation.git
//
//  Created by 孙继刚 on 15/12/13.
//  Copyright © 2015年 Madordie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KTJPushQueueForNavigationDelegate.h"

@interface KTJPushVCQueueItem : NSObject
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, assign) BOOL animated;
@end
@implementation KTJPushVCQueueItem
+ (instancetype)itemWithVC:(UIViewController *)vc animated:(BOOL)animated {
    KTJPushVCQueueItem *item = [KTJPushVCQueueItem new];
    item.viewController = vc;
    item.animated = animated;
    return item;
}
@end

@interface KTJPushQueueForNavigationDelegate () <UINavigationControllerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, strong) NSMutableArray<KTJPushVCQueueItem *> *showVCQueue;
@property (nonatomic, assign) BOOL isPushing;
@end
@implementation KTJPushQueueForNavigationDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isPushing = NO;
    }
    return self;
}

// Called when the navigation controller shows a new top view controller via a push, pop or setting of the view controller stack.
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.isPushing = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoPushed) object:nil];
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.isPushing = NO;
}

- (void)setIsPushing:(BOOL)isPushing {
    _isPushing = isPushing;
    if (isPushing == NO && self.showVCQueue.count) {
        KTJPushVCQueueItem *item = self.showVCQueue.firstObject;
        [self.showVCQueue removeObject:item];
        [self.navigationController pushViewController:item.viewController animated:item.animated];
    }
}
- (NSMutableArray<KTJPushVCQueueItem *> *)showVCQueue {
    if (!_showVCQueue) {
        _showVCQueue = [NSMutableArray new];
    }
    return _showVCQueue;
}
/**
 *  如果0.5秒没有显示VC显示，则设置pushed = NO.
 */
- (void)autoFinishPusing {
    self.isPushing = YES;
    [self performSelector:@selector(autoPushed) withObject:nil afterDelay:0.5];
}
- (void)autoPushed {
    self.isPushing = NO;
}
@end

#ifdef KTJNavQueueUseExtension
    #ifndef KTJChangeIMP
    #define KTJChangeIMP(JOriginalSEL, JSwizzledSEL)  \
        {   \
            Class class = [self class]; \
            SEL originalSelector = (JOriginalSEL);  \
            SEL swizzledSelector = (JSwizzledSEL);  \
            Method originalMethod = class_getInstanceMethod(class, originalSelector);   \
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);   \
            BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod)); \
            if (didAddMethod){  \
                class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod)); \
            } else {    \
                method_exchangeImplementations(originalMethod, swizzledMethod); \
            }   \
        }
    #endif
    #import <objc/runtime.h>
    @implementation KTJXXNavigationController (KTJPushQueue)

    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            KTJChangeIMP(@selector(pushViewController:animated:), @selector(hook_pushViewController:animated:));
        });
    }

    - (void)hook_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
        if (self.ktj_useNavPushQueue == NO) {
            [self hook_pushViewController:viewController animated:animated];
        } else {
            if (self.viewControllers.count == 0) {
                [self hook_pushViewController:viewController animated:animated];
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self.ktj_navPushQueue.isPushing) {
                        [self.ktj_navPushQueue.showVCQueue addObject:[KTJPushVCQueueItem itemWithVC:viewController animated:animated]];
                    } else {
                        [self hook_pushViewController:viewController animated:animated];
                        [self.ktj_navPushQueue autoFinishPusing];
                    }
                });
            }
        }
    }

    - (KTJPushQueueForNavigationDelegate *)ktj_navPushQueue {
        KTJPushQueueForNavigationDelegate *pushqueue = objc_getAssociatedObject(self, @selector(ktj_navPushQueue));
        if (!pushqueue) {
            pushqueue = [KTJPushQueueForNavigationDelegate new];
            pushqueue.navigationController = self;
            objc_setAssociatedObject(self, @selector(ktj_navPushQueue), pushqueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        return pushqueue;
    }

    - (void)setKtj_useNavPushQueue:(BOOL)ktj_useNavPushQueue {
        objc_setAssociatedObject(self, @selector(ktj_useNavPushQueue), @(ktj_useNavPushQueue), OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    - (BOOL)ktj_useNavPushQueue {
        NSNumber *use = objc_getAssociatedObject(self, @selector(ktj_useNavPushQueue));
        return use?[use boolValue]:NO;
    }

    @end

@implementation UIViewController (KTJPushQueue)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        KTJChangeIMP(@selector(viewDidAppear:), @selector(hook_viewDidAppear:));
    });
}
- (void)hook_viewDidAppear:(BOOL)animated {
    [self hook_viewDidAppear:animated];
    if ([self.navigationController isKindOfClass:[KTJXXNavigationController class]]) {
        KTJXXNavigationController *navigation = (KTJXXNavigationController *)self.navigationController;
        if (navigation.ktj_useNavPushQueue) {
            navigation.ktj_navPushQueue.isPushing = NO;
        }
    }
}

@end

#else

    @interface KTJPushQueueForNavigation ()

    @property (nonatomic, strong) NSNumber *default_useNavPushQueue;
    @property (nonatomic, strong) KTJPushQueueForNavigationDelegate *ktj_navPushQueue;

    @end
    @implementation KTJPushQueueForNavigation

    - (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
        if (self.ktj_useNavPushQueue == NO) {
            [super pushViewController:viewController animated:animated];
        } else {
            if (self.viewControllers.count == 0) {
                [super pushViewController:viewController animated:animated];
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self.ktj_navPushQueue.isPushing) {
                        [self.ktj_navPushQueue.showVCQueue addObject:[KTJPushVCQueueItem itemWithVC:viewController animated:animated]];
                    } else {
                        [super pushViewController:viewController animated:animated];
                        [self.ktj_navPushQueue autoFinishPusing];
                    }
                });
            }
        }
    }

    - (KTJPushQueueForNavigationDelegate *)ktj_navPushQueue {
        KTJPushQueueForNavigationDelegate *pushqueue = _ktj_navPushQueue;
        if (!pushqueue) {
            pushqueue = [KTJPushQueueForNavigationDelegate new];
            pushqueue.navigationController = self;
            _ktj_navPushQueue = pushqueue;
        }
        return pushqueue;
    }

    - (void)setKtj_useNavPushQueue:(BOOL)ktj_useNavPushQueue {
        self.default_useNavPushQueue = @(ktj_useNavPushQueue);
    }
    - (BOOL)ktj_useNavPushQueue {
        NSNumber *use = self.default_useNavPushQueue;
        return use?[use boolValue]:NO;
    }

    @end

    @implementation UIViewController (KTJPushQueue)

    - (void)ktj_tellPushQueueViewDidAppear {
        if ([self.navigationController isKindOfClass:[KTJPushQueueForNavigation class]]) {
            KTJPushQueueForNavigation *navigation = (KTJPushQueueForNavigation *)self.navigationController;
            if (navigation.ktj_useNavPushQueue) {
                navigation.ktj_navPushQueue.isPushing = NO;
            }
        }
    }

    @end

#endif