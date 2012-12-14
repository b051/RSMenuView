//
//  RSMenuButton.m
//
//  Created by Rex Sheng on 10/16/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "RSMenuButton.h"

NSString * const RSMenuButtonClickedNotificationName = @"RSMenuButtonClickedNotification";

@interface RSMenuButton ()
@property (nonatomic, copy) NSString *identifier;
@end

@implementation RSMenuButton

- (id)initWithIdentifier:(NSString *)identifier attributes:(NSDictionary *)attributes
{
	if (self = [super initWithFrame:CGRectZero]) {
		self.identifier = identifier;
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
	if (_identifier) {
		[[NSNotificationCenter defaultCenter] postNotificationName:RSMenuButtonClickedNotificationName object:_identifier];
	}
}

@end
