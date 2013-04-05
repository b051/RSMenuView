//
//  RSMenuCellItem.m
//
//  Created by Rex Sheng on 10/16/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "RSMenuCellItem.h"

NSString * const kRSMenuType = @"type";
NSString * const kRSMenuIdentifier = @"identifier";

@implementation RSMenuCellItem

- (void)layoutSubviews
{
	CGFloat x = self.bounds.size.width;
	CGFloat h = self.bounds.size.height;
	
	for (UIView *view in self.subviews) {
		CGSize size = [view sizeThatFits:CGSizeZero];
		x -= size.width;
		size.height = h;
		view.frame = CGRectMake(x, 0, size.width, size.height);
	}
	[super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
}

- (void)loadItems:(NSArray *)items
{
	self.hidden = items == nil;
	for (UIView *view in self.subviews) {
		[view removeFromSuperview];
	}
	NSDictionary *item = nil;
	NSEnumerator *enumerator = [items reverseObjectEnumerator];
	
	while (item = [enumerator nextObject]) {
		Class clazz = NSClassFromString(item[kRSMenuType]);
		if ([clazz conformsToProtocol:@protocol(RSMenuCellItem)]) {
			NSString *identifier = item[kRSMenuIdentifier];
			UIView *view = [[clazz alloc] initWithIdentifier:identifier attributes:item];
			[self addSubview:view];
		}
	}
}

@end
