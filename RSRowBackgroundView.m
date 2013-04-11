//
//  RSRowBackgroundView.m
//
//  Created by Rex Sheng on 10/16/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "RSRowBackgroundView.h"

@implementation RSRowBackgroundView
{
	UIImageView *ruler;
}

@synthesize highlighted=_highlighted;

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		self.contentMode = UIViewContentModeRedraw;
		self.clipsToBounds = NO;
		self.backgroundColor = [UIColor clearColor];
		_normalAlpha = .11f;
		_highlightedAlpha = .28f;
	}
	return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
	_highlighted = highlighted;
	[self setNeedsDisplay];
}

- (void)setRowSeperatorImage:(UIImage *)rowSeperatorImage
{
	_rowSeperatorImage = rowSeperatorImage;
	[ruler removeFromSuperview];
	if (rowSeperatorImage) {
		self.contentMode = UIViewContentModeScaleToFill;
		ruler = [[UIImageView alloc] initWithImage:rowSeperatorImage];
		CGRect frame = ruler.frame;
		frame.size.width = self.bounds.size.width;
		frame.origin.y = self.bounds.size.height - frame.size.height;
		ruler.frame = frame;
		[self addSubview:ruler];
	} else {
		self.contentMode = UIViewContentModeRedraw;
	}
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	if (_rowSeperatorImage) {
		return [super drawRect:rect];
	}
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGFloat lineHeight = .55f;
	
	CGContextSetGrayFillColor(context, 0, 1);
	CGContextFillRect(context, CGRectMake(0, rect.size.height - lineHeight, rect.size.width, lineHeight));
	CGContextSetGrayFillColor(context, 1, _highlighted ? _highlightedAlpha : _normalAlpha);
	CGContextFillRect(context, CGRectMake(0, 0, rect.size.width, lineHeight));
}

@end
