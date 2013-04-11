//
//  RSMenuCellItem.h
//
//  Created by Rex Sheng on 10/16/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kRSMenuType;
extern NSString * const kRSMenuIdentifier;

@protocol RSMenuCellItem <NSObject>

- (id)initWithIdentifier:(NSString *)identifier attributes:(NSDictionary *)attributes;

@end

@interface RSMenuCellItem : UIView

- (void)loadItems:(NSArray *)items;

@property (nonatomic) UITextAlignment alignment;

@end
