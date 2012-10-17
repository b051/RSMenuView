//
//  VHAppDelegate.m
//  VHMenu Example
//
//  Created by Rex Sheng on 10/17/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "VHAppDelegate.h"
#import "VHMenuViewController.h"

@implementation VHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
	self.window.rootViewController = [[VHMenuViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
