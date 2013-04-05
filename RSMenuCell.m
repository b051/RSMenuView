//
//  RSMenuCell.m
//
//  Created by Rex Sheng on 10/17/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "RSMenuCell.h"
#import "RSRowBackgroundView.h"

@implementation RSMenuCell

@synthesize selected, highlighted;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.backgroundView = [[RSRowBackgroundView alloc] initWithFrame:self.contentView.bounds];
		self.imageView.contentMode = UIViewContentModeCenter;
		_rightView = [[RSMenuCellItem alloc] initWithFrame:self.contentView.bounds];
		_rightView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
		[self.contentView addSubview:_rightView];
		_leftView = [[RSMenuCellItem alloc] initWithFrame:CGRectZero];
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect frame = self.textLabel.frame;
	if (!self.leftView.hidden) {
		CGRect lf = self.leftView.frame;
		lf.origin.y = (self.bounds.size.height - lf.size.height) / 2;
		self.leftView.frame = lf;
		[self.contentView addSubview:self.leftView];
		frame.origin.x = CGRectGetMaxX(lf) + lf.origin.x;
	} else {
		CGRect frame = self.textLabel.frame;
		frame.origin.x = 30;
		[self.leftView removeFromSuperview];
	}
	self.textLabel.frame = frame;
}

- (void)drawShadow
{
	self.textLabel.shadowColor = self.selected ? _selectedTextShadowColor : (self.highlighted ? _highlightedTextShadowColor : _textShadowColor);
}

- (void)setRowSeperatorImage:(UIImage *)rowSeperatorImage
{
	[(RSRowBackgroundView *)self.backgroundView setRowSeperatorImage:rowSeperatorImage];
}

- (void)setSelectedTextShadowColor:(UIColor *)selectedTextShadowColor
{
	_selectedTextShadowColor = selectedTextShadowColor;
	[self drawShadow];
}

- (void)setTextShadowColor:(UIColor *)textShadowColor
{
	_textShadowColor = textShadowColor;
	[self drawShadow];
}

- (void)setSelected:(BOOL)_selected animated:(BOOL)animated
{
	selected = _selected;
	[self drawShadow];
	self.textLabel.highlighted = selected;
	self.imageView.highlighted = selected;
	if (_selectedBackgroundColor) {
		[self.backgroundView setBackgroundColor:selected ? _selectedBackgroundColor : [UIColor clearColor]];
	}
}

- (void)setHighlighted:(BOOL)_highlighted animated:(BOOL)animated
{
	highlighted = _highlighted;
	[self drawShadow];
	self.textLabel.highlighted = highlighted;
	self.imageView.highlighted = highlighted;
	if (_selectedBackgroundColor) {
		[self.backgroundView setBackgroundColor:highlighted ? _selectedBackgroundColor : [UIColor clearColor]];
	}
}

@end

