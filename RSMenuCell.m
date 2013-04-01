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
		self.backgroundView = [[RSRowBackgroundView alloc] initWithFrame:self.contentView.bounds];
		self.selectedBackgroundView = [[RSRowBackgroundView alloc] initWithFrame:self.contentView.bounds];
		self.imageView.contentMode = UIViewContentModeCenter;
		_rightView = [[RSMenuRightView alloc] initWithFrame:self.contentView.bounds];
		self.rightView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
		[self.contentView addSubview:_rightView];
	}
	return self;
}

- (void)drawShadow
{
	self.textLabel.shadowColor = self.selected ? _selectedTextShadowColor : (self.highlighted ? _highlightedTextShadowColor : _textShadowColor);
}

- (void)setRowSeperatorImage:(UIImage *)rowSeperatorImage
{
	[(RSRowBackgroundView *)self.backgroundView setRowSeperatorImage:rowSeperatorImage];
	[(RSRowBackgroundView *)self.selectedBackgroundView setRowSeperatorImage:rowSeperatorImage];
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
}

- (void)setHighlighted:(BOOL)_highlighted animated:(BOOL)animated
{
	highlighted = _highlighted;
	[self drawShadow];
	self.textLabel.highlighted = highlighted;
	self.imageView.highlighted = highlighted;
}

@end

