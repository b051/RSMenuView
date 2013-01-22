//
//  RSMenuCount.m
//  viralheat
//
//  Created by Rex Sheng on 10/16/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "RSMenuCount.h"

@implementation RSMenuCount
{
	UIFont *font;
	NSString *identifier;
	NSString *text;
	CGFloat height;
	id observer;
}

- (id)initWithIdentifier:(NSString *)_identifier attributes:(NSDictionary *)attributes
{
    if (self = [super initWithFrame:CGRectZero]) {
		identifier = _identifier;
		font = [UIFont systemFontOfSize:15.f];
		height = 25.f;
		if (identifier)
			observer = [[NSNotificationCenter defaultCenter] addObserverForName:identifier object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
				NSUInteger count = [note.object unsignedIntegerValue];
				if (count > 100)
					text = @"100+";
				else if (count == 0)
					text = nil;
				else
					text = [NSString stringWithFormat:@"%d", count];
				[self setNeedsDisplay];
				[self.superview setNeedsLayout];
				[self.superview layoutIfNeeded];
			}];
		self.contentMode = UIViewContentModeRedraw;
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc
{
	if (observer)
		[[NSNotificationCenter defaultCenter] removeObserver:observer];
}

- (CGSize)sizeThatFits:(CGSize)_
{
	if (text) {
		CGSize size = [text sizeWithFont:font];
		size.height = height;
		size.width = MAX(40, size.width + 22);
		return size;
	}
	return CGSizeZero;
}

- (void)drawRect:(CGRect)rect
{
	if (!text) return;
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetAllowsAntialiasing(context, true);
	CGContextSetShouldAntialias(context, true);
	rect = CGRectInset(rect, 0, (rect.size.height - height) / 2);
	UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:12.5f];
	CGContextAddPath(context, bezierPath.CGPath);
	CGContextSetGrayFillColor(context, 1, .3f);
	CGContextFillPath(context);
	
	bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, .5f, .5f) cornerRadius:12];
	CGContextAddPath(context, bezierPath.CGPath);
	CGContextSetRGBFillColor(context, .21f, .23f, .25f, 1);
	CGContextFillPath(context);
	
	CGSize size = [text sizeWithFont:font];
	CGContextSetGrayFillColor(context, 1, 1);
	rect = CGRectInset(rect, 0, (rect.size.height - size.height) / 2);
	[text drawInRect:rect withFont:font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
}

@end
