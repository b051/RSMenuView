//
//  RSMenuCell.h
//
//  Created by Rex Sheng on 10/17/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSMenuCellItem.h"

@interface RSMenuCell : UITableViewCell

@property (nonatomic, strong, readonly) RSMenuCellItem *rightView;
@property (nonatomic, strong, readonly) RSMenuCellItem *leftView;
@property (nonatomic, strong) UIColor *selectedTextShadowColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *highlightedTextShadowColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *textShadowColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *selectedBackgroundColor;

@property (nonatomic, strong) NSString *identifier;

@end
