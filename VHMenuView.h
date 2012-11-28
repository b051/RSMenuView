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

@property (nonatomic) UITableViewRowAnimation rowAnimation;
@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *highlightedTextColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) CGFloat rowHeight UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIEdgeInsets rowEdgeInsets UI_APPEARANCE_SELECTOR;

@property (nonatomic) CGSize textShadowOffset UI_APPEARANCE_SELECTOR;

@property (nonatomic, weak) id<VHMenuViewDelegate> delegate;

- (void)loadFromConfiguration:(NSArray *)configuration;
- (void)setItemSelectedWithIdentifier:(NSString *)identifier;

@end
