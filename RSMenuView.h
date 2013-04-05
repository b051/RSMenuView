//
//  RSMenuView.h
//
//  Created by Rex Sheng on 10/16/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSMenuView;
@class RSMenuCell;

@protocol RSMenuViewDelegate <NSObject>

@optional
- (void)menuView:(RSMenuView *)menuView didSelectItemWithIdentifier:(NSString *)identifier;
- (NSDictionary *)menuView:(RSMenuView *)menuView attributesForItemWithIdentifier:(NSString *)identifier;
- (CGFloat)menuView:(RSMenuView *)menuView heightForItemWithIdentifier:(NSString *)identifier;

@end

@interface RSMenuView : UIView

@property (nonatomic, strong) UIView *menuHeaderView;
@property (nonatomic, strong) UIView *menuFooterView;
@property (nonatomic) UITableViewRowAnimation rowAnimation;
@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *highlightedTextColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) CGFloat rowHeight UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIEdgeInsets rowEdgeInsets UI_APPEARANCE_SELECTOR;

@property (nonatomic) CGSize textShadowOffset UI_APPEARANCE_SELECTOR;

@property (nonatomic, weak) id<RSMenuViewDelegate> delegate;

- (RSMenuCell *)cellForRow:(NSDictionary *)row;
- (void)updateSectionItem:(NSDictionary *)item atSection:(NSUInteger)section;

- (void)setItems:(NSArray *)configuration __deprecated;
- (void)setItems:(NSArray *)configuration forSection:(NSUInteger)section sectionHeader:(NSDictionary *)sectionHeader;
- (void)insertItem:(NSDictionary *)item atRow:(NSUInteger)row __deprecated;
- (void)insertItem:(NSDictionary *)item atRow:(NSUInteger)row section:(NSUInteger)section;
- (void)deleteItemAtRow:(NSUInteger)row __deprecated;
- (void)deleteItemAtRow:(NSUInteger)row section:(NSUInteger)section;
- (void)replaceItemAtRow:(NSUInteger)row withItem:(NSDictionary *)item __deprecated;
- (void)replaceItemAtRow:(NSUInteger)row section:(NSUInteger)section withItem:(NSDictionary *)item;
- (void)performBatchUpdates:(dispatch_block_t)updates;

- (void)setTextFont:(UIFont *)font forIndent:(NSUInteger)indent UI_APPEARANCE_SELECTOR;
- (UIFont *)textFontForIndent:(NSUInteger)indent UI_APPEARANCE_SELECTOR;

- (void)setTextColor:(UIColor *)color forIndent:(NSUInteger)indent UI_APPEARANCE_SELECTOR;
- (UIColor *)textColorForIndent:(NSUInteger)indent UI_APPEARANCE_SELECTOR;

- (void)setRowBackgroundColor:(UIColor *)color forIndent:(NSUInteger)indent UI_APPEARANCE_SELECTOR;
- (UIColor *)rowBackgroundColorForIndent:(NSUInteger)indent UI_APPEARANCE_SELECTOR;

- (void)setItemSelectedWithIdentifier:(NSString *)identifier;

@end
