//
//  RSMenuCell.h
//
//  Created by Rex Sheng on 10/17/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSMenuRightView.h"

@interface RSMenuCell : UITableViewCell

@property (nonatomic, strong) RSMenuRightView *rightView;

@property (nonatomic, strong) UIColor *selectedTextShadowColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *textShadowColor UI_APPEARANCE_SELECTOR;

@end
