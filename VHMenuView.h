//
//  VHMenuView.h
//
//  Created by Rex Sheng on 10/16/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VHMenuView;

@protocol VHMenuViewDelegate <NSObject>

@optional
- (UIFont *)menuView:(VHMenuView *)menuView fontForTextAtIndent:(NSUInteger)indent;
- (void)menuView:(VHMenuView *)menuView didSelectedItemWithIdentifier:(NSString *)identifier;
- (NSDictionary *)menuView:(VHMenuView *)menuView attributesForItemWithIdentifier:(NSString *)identifier;

@end

@interface VHMenuView : UIView

- (id)initWithFrame:(CGRect)frame cellClass:(Class)cellClass;

@property (nonatomic, unsafe_unretained) id<VHMenuViewDelegate> delegate;
@property (nonatomic) UITableViewRowAnimation rowAnimation;
@property (nonatomic) CGSize rowSize;
@property (nonatomic) UIEdgeInsets rowEdgeInsets;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *highlightedTextColor;

- (void)loadFromConfiguration:(NSArray *)configuration;
- (void)setItemSelectedWithIdentifier:(NSString *)identifier;

@end
