//
//  RSMenuView.h
//
//  Created by Rex Sheng on 10/16/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSMenuView;

@protocol RSMenuViewDelegate <NSObject>

@optional
- (void)menuView:(RSMenuView *)menuView didSelectItemWithIdentifier:(NSString *)identifier;
- (NSDictionary *)menuView:(RSMenuView *)menuView attributesForItemWithIdentifier:(NSString *)identifier;

@end

@interface RSMenuView : UIView

@property (nonatomic) UITableViewRowAnimation rowAnimation;
@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *highlightedTextColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) CGFloat rowHeight UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIEdgeInsets rowEdgeInsets UI_APPEARANCE_SELECTOR;

@property (nonatomic) CGSize textShadowOffset UI_APPEARANCE_SELECTOR;

@property (nonatomic, weak) id<RSMenuViewDelegate> delegate;

- (void)setItems:(NSArray *)configuration;
- (void)insertItem:(NSDictionary *)item atRow:(NSUInteger)row;
- (void)deleteItemAtRow:(NSUInteger)row;
- (void)replaceItemAtRow:(NSUInteger)row withItem:(NSDictionary *)item;
- (void)performBatchUpdates:(dispatch_block_t)updates;

- (void)setTextFont:(UIFont *)font forIndent:(NSUInteger)indent UI_APPEARANCE_SELECTOR;
- (UIFont *)textFontForIndent:(NSUInteger)indent UI_APPEARANCE_SELECTOR;

- (void)setItemSelectedWithIdentifier:(NSString *)identifier;

@end
