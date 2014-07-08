//
//  AppDelegate.m
//  DemoForCustomSearchDisplay
//
//  Created by darklinden on 14-7-8.
//  Copyright (c) 2014年 darklinden. All rights reserved.
//

#import "AppDelegate.h"
#import "VC_list.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    VC_list *pVC_list = [[VC_list alloc] initWithNibName:@"VC_list" bundle:nil];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:pVC_list];
    
    NSString *str_char = @"abcdefghijklmnopqrstuvwxyz";
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        for (int j = 0; j < 26; j++) {
            NSString *str_c = [str_char substringWithRange:NSMakeRange(j, 1)];
            NSString *str_tmp = [NSString stringWithFormat:@"%@%d", str_c, i];
            O_list_item *item = [O_list_item itemTitle:str_tmp];
            [array addObject:item];
        }
    }
    
    [pVC_list setup:^(SEL cancel, SEL done, NSArray *__autoreleasing *src_array) {
//        [pVC_list.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
        [pVC_list.navigationController.navigationBar setTintColor:[UIColor blueColor]];
        //    [nav.navigationBar setBarTintColor:[UIColor whiteColor]];
//        pVC_list.navigationController.navigationBar.titleTextAttributes =
//        [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil];
        
        UIBarButtonItem *item_canel = [[UIBarButtonItem alloc] init];
        item_canel.title = @"Cancel";
        [item_canel setTarget:pVC_list];
        [item_canel setAction:cancel];
        pVC_list.navigationItem.leftBarButtonItem = item_canel;
        
        UIBarButtonItem *item_done = [[UIBarButtonItem alloc] init];
        item_done.title = @"Done";
        [item_done setTarget:pVC_list];
        [item_done setAction:cancel];
        pVC_list.navigationItem.rightBarButtonItem = item_done;
        
        pVC_list.navigationItem.title = @"Select Item";
        
        *src_array = array;
    }];
    
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
