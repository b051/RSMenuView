//
//  VHMenuCell.m
//
//  Created by Rex Sheng on 10/17/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "VHMenuCell.h"

@implementation VHMenuCell

@synthesize rightView;
@synthesize selected, highlighted;

- (void)setSelected:(BOOL)_selected animated:(BOOL)animated
{
	selected = _selected;
	self.textLabel.shadowColor = selected ? [UIColor blackColor] : nil;
	self.textLabel.highlighted = selected;
	self.imageView.highlighted = selected;
}

- (void)setHighlighted:(BOOL)_highlighted animated:(BOOL)animated
{
	highlighted = _highlighted;
	self.textLabel.highlighted = highlighted;
	self.imageView.highlighted = highlighted;
}

@end

