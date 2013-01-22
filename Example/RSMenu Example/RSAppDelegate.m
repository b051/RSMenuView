//
//  RSAppDelegate.m
//  RSMenu Example
//
//  Created by Rex Sheng on 10/17/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "RSAppDelegate.h"
#import "RSMenuViewController.h"

@implementation RSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
	self.window.rootViewController = [[RSMenuViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
