//
//  AppDelegate.m
//  TRDataFMDBModel
//
//  Created by ZYW on 2017/12/21.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import "AppDelegate.h"
#import "demoModel.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	
	for (NSInteger idx = 0; idx < 10; idx++) {
		demoModel *model = [[demoModel alloc] init];
		model.userId = [NSString stringWithFormat:@"%ld",idx+1];
		model.nickName = [NSString stringWithFormat:@"李斯%lu",(unsigned long)idx];
		model.headPic = @"http://imgtu.5011.net/uploads/content/20170329/5440631490773274.jpg";
		[model addToDB];
	}
	
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
