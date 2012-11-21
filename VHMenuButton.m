//
//  VHMenuCompose.m
//
//  Created by Rex Sheng on 10/16/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "VHMenuButton.h"

NSString * const VHMenuButtonClickedNotificationName = @"VHMenuButtonClickedNotification";

@implementation VHMenuButton
{
	NSString *identifier;
}

- (id)initWithIdentifier:(NSString *)_identifier attributes:(NSDictionary *)attributes
{
	if (self = [super initWithFrame:CGRectZero]) {
		identifier = _identifier;
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		UIImage *icon = [UIImage imageNamed:attributes[@"image"]];
		[button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[button setImage:icon forState:UIControlStateNormal];
		self.frame = button.frame = CGRectMake(0, 0, MAX(icon.size.width, 26), icon.size.height);
		button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		[self addSubview:button];
	}
	return self;
}

- (void)buttonClicked:(id)sender
{
	if (identifier) {
		[[NSNotificationCenter defaultCenter] postNotificationName:VHMenuButtonClickedNotificationName object:identifier];
	}
}

@end
