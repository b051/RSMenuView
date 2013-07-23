//
//  RSMenuFoldButton.m
//
//  Created by Rex Sheng on 10/17/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "RSMenuFoldButton.h"
#import "RSMenuCellItem.h"

NSString * const kRSMenuOpening = @"opening";
NSString * const RSMenuOpenNotification = @"RSMenuOpenNotification";

@implementation RSMenuFoldButton
{
	NSString *identifier;
	BOOL opening;
	UIButton *button;
	id observer;
}

- (id)initWithIdentifier:(NSString *)_identifier attributes:(NSDictionary *)attributes
{
	if (self = [super initWithFrame:CGRectZero]) {
		opening = [attributes[kRSMenuOpening] boolValue];
		UIImage *icon = [UIImage imageNamed:@"menu_arrow"];
		if (!icon) return self;
		identifier = _identifier;
		button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		
		observer = [[NSNotificationCenter defaultCenter] addObserverForName:RSMenuOpenNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
			if ([note.userInfo[kRSMenuIdentifier] isEqualToString:identifier]) {
				BOOL status = [note.userInfo[kRSMenuOpening] boolValue];
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
		[[NSNotificationCenter defaultCenter] postNotificationName:RSMenuOpenNotification object:self userInfo:@{kRSMenuOpening: @(opening), kRSMenuIdentifier: identifier}];
	}
}

@end
