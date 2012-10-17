//
//  VHMenuRightView.m
//  viralheat
//
//  Created by Rex Sheng on 10/16/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "VHMenuRightView.h"
#import "VHMenuRightViewInfo.h"
#import "VHMenuCount.h"
#import "VHMenuButton.h"

NSString * const kVHMenuType = @"type";
NSString * const kVHMenuIdentifier = @"identifier";

@implementation VHMenuRightView

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

- (void)loadItems:(NSArray *)items
{
	for (UIView *view in self.subviews) {
		[view removeFromSuperview];
	}
	NSDictionary *item = nil;
	NSEnumerator *enumerator = [items reverseObjectEnumerator];
	
	while (item = [enumerator nextObject]) {
		Class clazz = NSClassFromString(item[kVHMenuType]);
		if ([clazz conformsToProtocol:@protocol(VHMenuRightViewInfo)]) {
			NSString *identifier = item[kVHMenuIdentifier];
			UIView *view = [[clazz alloc] initWithIdentifier:identifier attributes:item];
			[self addSubview:view];
		}
	}
}

@end
