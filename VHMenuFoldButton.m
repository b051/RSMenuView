//
//  VHMenuFoldButton.m
//  viralheat
//
//  Created by Rex Sheng on 10/17/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "VHMenuFoldButton.h"
#import "VHMenuRightView.h"

NSString * const kVHMenuOpening = @"opening";
NSString * const VHMenuOpenNotification = @"VHMenuOpenNotification";

@implementation VHMenuFoldButton
{
	NSString *identifier;
	BOOL opening;
	UIButton *button;
	id observer;
}

- (id)initWithIdentifier:(NSString *)_identifier attributes:(NSDictionary *)attributes
{
	if (self = [super initWithFrame:CGRectZero]) {
		identifier = _identifier;
		button = [UIButton buttonWithType:UIButtonTypeCustom];
		UIImage *icon = [UIImage imageNamed:@"menu_arrow"];
		[button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		opening = [attributes[kVHMenuOpening] boolValue];
		
		observer = [[NSNotificationCenter defaultCenter] addObserverForName:VHMenuOpenNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
			if ([note.userInfo[kVHMenuIdentifier] isEqualToString:identifier]) {
				BOOL status = [note.userInfo[kVHMenuOpening] boolValue];
				[UIView animateWithDuration:.3 animations:^{
					button.transform = CGAffineTransformMakeRotation(status ? 0 : -M_PI_2);
				}];
			}
		}];
		CGFloat r = MAX(icon.size.width, icon.size.height);
		[button setImage:icon forState:UIControlStateNormal];
		self.frame = button.frame = CGRectMake(0, 0, r, r);
		button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		[self addSubview:button];
		if (!opening) {
			button.transform = CGAffineTransformMakeRotation(-M_PI_2);
		}
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:observer];
}

- (void)buttonClicked:(id)sender
{
	opening = !opening;
	if (identifier) {
		[[NSNotificationCenter defaultCenter] postNotificationName:VHMenuOpenNotification object:self userInfo:@{kVHMenuOpening: @(opening), kVHMenuIdentifier: identifier}];
	}
}

@end
