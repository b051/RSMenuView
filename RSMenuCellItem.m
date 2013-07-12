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
	CGFloat h = self.bounds.size.height;
	
	CGFloat width = 0;
	NSMutableArray *sizes = [NSMutableArray array];
	for (UIView *view in self.subviews) {
		if ([view conformsToProtocol:@protocol(RSMenuCellItem)]) {
			CGSize size = [view sizeThatFits:CGSizeZero];
			[sizes addObject:[NSValue valueWithCGSize:size]];
			width += size.width;
		}
	}
	CGFloat initValue, step, gap = 0;
#ifdef __IPHONE_6_0
	if (self.alignment == NSTextAlignmentCenter) {
#else
	if (self.alignment == UITextAlignmentCenter) {
#endif
		gap = (self.bounds.size.width - width) / (sizes.count + 1);
		initValue = gap;
		step = 1;
#ifdef __IPHONE_6_0
	} else if (self.alignment == NSTextAlignmentRight) {
#else
	} else if (self.alignment == UITextAlignmentRight) {
#endif
		initValue = self.bounds.size.width;
		step = -1;
	} else {
		initValue = 0;
		step = 1;
	}
	
	CGFloat x = initValue;
	int i = 0;
	for (UIView *view in self.subviews) {
		if ([view conformsToProtocol:@protocol(RSMenuCellItem)]) {
			CGRect frame = view.frame;
			CGSize size = [(NSValue *)sizes[i++] CGSizeValue];
			if (step > 0) {
				frame.origin.x = x;
				x += size.width * step + gap;
			} else {
				x += size.width * step - gap;
				frame.origin.x = x;
			}
			frame.origin.y = (h - size.height) / 2;
			frame.size = size;
			view.frame = frame;
		}
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
		if ([view conformsToProtocol:@protocol(RSMenuCellItem)]) {
			[view removeFromSuperview];
		}
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
