//
//  VHMenuCell.m
//  viralheat
//
//  Created by Rex Sheng on 10/17/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "VHMenuCell.h"

@implementation VHMenuCell

@synthesize rightView;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	self.textLabel.shadowColor = selected ? [UIColor blackColor] : nil;
	self.textLabel.highlighted = selected;
	self.imageView.highlighted = selected;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	self.textLabel.highlighted = highlighted;
	self.imageView.highlighted = highlighted;
}

@end

