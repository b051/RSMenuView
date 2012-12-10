//
//  RSRowBackgroundView.m
//
//  Created by Rex Sheng on 10/16/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "RSRowBackgroundView.h"

@implementation RSRowBackgroundView

@synthesize highlighted;

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		self.contentMode = UIViewContentModeRedraw;
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGFloat lineHeight = .55f;
	CGContextSetGrayFillColor(context, 0, 1);
	CGContextFillRect(context, CGRectMake(0, rect.size.height - lineHeight, rect.size.width, lineHeight));
	CGContextSetGrayFillColor(context, 1, highlighted ? .28f : .11f);
	CGContextFillRect(context, CGRectMake(0, 0, rect.size.width, lineHeight));
	
	if (highlighted) {
		CGContextSetGrayFillColor(context, 1, .11f);
		CGContextFillRect(context, CGRectInset(rect, 0, lineHeight));
	}
}

@end
