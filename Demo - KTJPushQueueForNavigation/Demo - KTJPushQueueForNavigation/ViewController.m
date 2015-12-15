//
//  ViewController.m
//  Demo - KTJPushQueueForNavigation
//
//  Created by 孙继刚 on 15/12/14.
//  Copyright © 2015年 Madordie. All rights reserved.
//

#import "ViewController.h"
#import "XXXViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor redColor];
    [self.navigationController pushViewController:[XXXViewController new] animated:YES];
    //  在低版本中当前现实的View有可能会出：《返回就崩了。。
//    iOS7.1.2 :
//    2015-12-13 11:41:33.837 xxx[4418:60b] nested push animation can result in corrupted navigation bar
//    2015-12-13 11:41:34.195 xxx[4418:60b] Finishing up a navigation transition in an unexpected state. Navigation Bar subview tree might get corrupted.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
