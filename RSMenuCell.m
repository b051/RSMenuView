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
		self.backgroundColor = self.textLabel.backgroundColor = self.contentView.backgroundColor = [UIColor clearColor];
		self.backgroundView = [[RSRowBackgroundView alloc] initWithFrame:self.contentView.bounds];
		self.imageView.contentMode = UIViewContentModeCenter;
		_leftView = [[RSMenuCellItem alloc] initWithFrame:CGRectZero];
		_rightView = [[RSMenuCellItem alloc] initWithFrame:self.contentView.bounds];
		_rightView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

#ifdef __IPHONE_6_0
		self.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
		_leftView.alignment = NSTextAlignmentCenter;
		_rightView.alignment = NSTextAlignmentRight;
#else
		self.textLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
		_leftView.alignment = UITextAlignmentCenter;
		_rightView.alignment = UITextAlignmentRight;
#endif
		[self.contentView addSubview:_rightView];
		
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect tf = self.textLabel.frame;
	[self.rightView layoutSubviews];
	CGRect rf = self.rightView.frame;
	UIView *mostLeftRightView = self.rightView.subviews.lastObject;
	CGFloat maxX = (mostLeftRightView ? mostLeftRightView.frame.origin.x : rf.size.width) + rf.origin.x;
	tf.origin.x = rf.origin.x;
	if (!self.leftView.hidden) {
		CGRect lf = self.leftView.frame;
		lf.origin.y = (self.bounds.size.height - lf.size.height) / 2;
		lf.origin.x = (tf.origin.x - lf.size.width) / 2;
		self.leftView.frame = lf;
		[self.contentView addSubview:self.leftView];
		tf.origin.x = CGRectGetMaxX(lf) + lf.origin.x;
	} else {
		self.imageView.center = CGPointMake(tf.origin.x / 2, tf.size.height / 2);
		[self.leftView removeFromSuperview];
	}
	tf.size.width = maxX - tf.origin.x;
	self.textLabel.frame = tf;
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
	if (self.selectedBackgroundColor) {
		[self.backgroundView setBackgroundColor:selected ? self.selectedBackgroundColor : nil];
	}
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor
{
	_selectedBackgroundColor = selectedBackgroundColor;
	if (selectedBackgroundColor) {
		[self.backgroundView setBackgroundColor:(selected | highlighted) ? selectedBackgroundColor : nil];
	}
}

- (void)setHighlighted:(BOOL)_highlighted animated:(BOOL)animated
{
	highlighted = _highlighted;
	[self drawShadow];
	self.textLabel.highlighted = highlighted;
	self.imageView.highlighted = highlighted;
	if (self.selectedBackgroundColor) {
		[self.backgroundView setBackgroundColor:highlighted ? self.selectedBackgroundColor : nil];
	}
}

@end

