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
	UIImageView *upperRuler;
}

@synthesize highlighted=_highlighted;

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		self.contentMode = UIViewContentModeRedraw;
		self.rowBackgroundColor = [UIColor clearColor];
		self.showsBottomSeperator = NO;
		self.showsTopSeperator = YES;
		self.clipsToBounds = NO;
		self.backgroundColor = nil;
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
	[self setShowsTopSeperator:_showsTopSeperator];
	[self setShowsBottomSeperator:_showsBottomSeperator];
	[self setNeedsDisplay];
}

- (void)setShowsBottomSeperator:(BOOL)showsBottomSeperator
{
	_showsBottomSeperator = showsBottomSeperator;
	[ruler removeFromSuperview];
	if (showsBottomSeperator) {
		if (_rowSeperatorImage) {
			self.contentMode = UIViewContentModeScaleToFill;
			ruler = [[UIImageView alloc] initWithImage:_rowSeperatorImage];
			CGRect frame = ruler.frame;
			frame.size.width = self.bounds.size.width;
			UIOffset offset = self.rowSeperatorImageBottomOffset;
			frame.origin.y = self.bounds.size.height - frame.size.height + offset.vertical;
			frame.origin.x = offset.horizontal;
			ruler.frame = frame;
			ruler.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
			[self addSubview:ruler];
		} else {
			self.contentMode = UIViewContentModeRedraw;
			[self setNeedsDisplay];
		}
	}
}

- (void)setShowsTopSeperator:(BOOL)showsTopSeperator
{
	_showsTopSeperator = showsTopSeperator;
	[upperRuler removeFromSuperview];
	if (showsTopSeperator) {
		if (_rowSeperatorImage) {
			self.contentMode = UIViewContentModeScaleToFill;
			upperRuler = [[UIImageView alloc] initWithImage:_rowSeperatorImage];
			CGRect frame = upperRuler.frame;
			frame.size.width = self.bounds.size.width;
			UIOffset offset = self.rowSeperatorImageTopOffset;
			frame.origin.y = offset.vertical;
			frame.origin.x = offset.horizontal;
			upperRuler.frame = frame;
			[self addSubview:upperRuler];
		} else {
			self.contentMode = UIViewContentModeRedraw;
			[self setNeedsDisplay];
		}
	}
}

- (void)setRowBackgroundColor:(UIColor *)rowBackgroundColor
{
	_rowBackgroundColor = rowBackgroundColor;
	self.backgroundColor = rowBackgroundColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
	[super setBackgroundColor:backgroundColor ?: _rowBackgroundColor];
}

- (void)drawRect:(CGRect)rect
{
	if (_rowSeperatorImage) {
		return [super drawRect:rect];
	}
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat lineHeight = .55f;
	if (_showsBottomSeperator) {
		CGContextSetGrayFillColor(context, 0, _highlighted ? _highlightedAlpha : _normalAlpha);
		CGContextFillRect(context, CGRectMake(0, rect.size.height - lineHeight, rect.size.width, lineHeight));
	}
	if (_showsTopSeperator) {
		CGContextSetGrayFillColor(context, 0, _highlighted ? _highlightedAlpha : _normalAlpha);
		CGContextFillRect(context, CGRectMake(0, 0, rect.size.width, lineHeight));
	}
}

@end
