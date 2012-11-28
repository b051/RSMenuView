//
//  VHMenuView.m
//
//  Created by Rex Sheng on 10/16/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "VHMenuView.h"
#import "VHMenuFoldButton.h"
#import "VHRowBackgroundView.h"
#import "VHMenuCell.h"

NSString * const kVHMenuTitle = @"title";
NSString * const kVHMenuLeftView = @"leftview";
NSString * const kVHMenuRightViews = @"rightviews";
NSString * const kVHMenuItems = @"items";


#pragma mark - VHMenuView
@interface VHMenuView () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation VHMenuView
{
	NSMutableDictionary *foldableRows;
	NSArray *configuration;
	NSMutableArray *currentRows;
	UITableView *_tableView;
	NSString *selectedIdentifier;
	NSIndexPath *indexPathOfSelectedRow;
	__unsafe_unretained Class cellClass;
	BOOL everLayedout;
}

@synthesize rowEdgeInsets=_rowEdgeInsets;

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		cellClass = [VHMenuCell class];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
		_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:_tableView];
		_tableView.delegate = self;
		_textColor = [UIColor whiteColor];
		_textShadowOffset = CGSizeMake(0, 1);
		_tableView.dataSource = self;
		_tableView.backgroundColor = [UIColor clearColor];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		foldableRows = [NSMutableDictionary dictionary];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuFoldingChanged:) name:VHMenuOpenNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setRowHeight:(CGFloat)rowHeight
{
	_tableView.rowHeight = rowHeight;
}

- (CGFloat)rowHeight
{
	return _tableView.rowHeight;
}

- (void)menuFoldingChanged:(NSNotification *)note
{
	id opening = (note.userInfo)[kVHMenuOpening];
	id identifier = (note.userInfo)[kVHMenuIdentifier];
	foldableRows[identifier] = opening;
	
	__block NSDictionary *config = nil;
	[configuration enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj[kVHMenuIdentifier] isEqualToString:identifier]) {
			*stop = YES;
			config = obj;
		}
	}];
	NSUInteger startRow = [currentRows indexOfObject:config] + 1;
	NSArray *subitems = config[kVHMenuItems];
	[_tableView beginUpdates];
	if ([opening boolValue]) {
		NSMutableArray *indexPaths = [NSMutableArray array];
		for (int i = 0; i < subitems.count; i++) {
			NSUInteger row = startRow + i;
			[currentRows insertObject:subitems[i] atIndex:row];
			[indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
		}
		[_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:_rowAnimation];
	} else {
		NSMutableArray *indexPaths = [NSMutableArray array];
		[currentRows removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startRow, subitems.count)]];
		for (int i = 0; i < subitems.count; i++) {
			NSUInteger row = startRow + i;
			[indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
		}
		[_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:_rowAnimation];
	}
	[_tableView endUpdates];
}

- (void)loadFromConfiguration:(NSArray *)_configuration
{
	[foldableRows removeAllObjects];
	configuration = _configuration;
	currentRows = [NSMutableArray arrayWithArray:configuration];
	
	[configuration enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSArray *subitems = obj[kVHMenuItems];
		NSString *identifier = obj[kVHMenuIdentifier];
		if (subitems && identifier) {
			BOOL opening = [obj[@"itemsOpened"] boolValue];
			foldableRows[identifier] = @(opening);
			if (opening) [currentRows addObjectsFromArray:subitems];
		}
	}];
	[_tableView reloadData];
}

#pragma mark - UITableView Delegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return currentRows ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return currentRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"VHMenuCell";
	VHMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[VHMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	CGRect frame = cell.contentView.bounds;
	//imageview
	CGFloat r = tableView.rowHeight - _rowEdgeInsets.top - _rowEdgeInsets.bottom;
	cell.imageView.frame = CGRectMake(_rowEdgeInsets.left, _rowEdgeInsets.top, r, r);
	
	//textlabel
	CGFloat x = r + _rowEdgeInsets.left * 2;
	cell.rightView.frame = cell.textLabel.frame = CGRectMake(x, _rowEdgeInsets.top, frame.size.width - _rowEdgeInsets.right - x, r);
	cell.textLabel.textColor = _textColor;
	cell.textLabel.highlightedTextColor = _highlightedTextColor;
	cell.textLabel.shadowOffset = _textShadowOffset;
	NSDictionary *row = currentRows[indexPath.row];
	//indent
	NSUInteger indent = [row[@"indent"] integerValue];
	if ([self.delegate respondsToSelector:@selector(menuView:fontForTextAtIndent:)]) {
		cell.textLabel.font = [self.delegate menuView:self fontForTextAtIndent:indent];
	}
	[(VHRowBackgroundView *)cell.backgroundView setHighlighted:indent == 0];
	
	//title
	cell.textLabel.text = row[@"title"];
	
	//leftviews
	NSString *leftview = row[@"leftview"];
	if (leftview) {
		cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_active", leftview]];
		cell.imageView.highlightedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_enabled", leftview]];
	} else {
		cell.imageView.image = nil;
	}
	//rightviews
	NSArray *subitems = row[kVHMenuItems];
	NSArray *rightViewsConfiguration = row[kVHMenuRightViews];
	NSString *identifier = row[kVHMenuIdentifier];
	
	NSMutableArray *rightViews = [NSMutableArray array];
	if (rightViewsConfiguration) {
		for (NSDictionary *config in rightViewsConfiguration) {
			id rid = config[kVHMenuIdentifier];
			if ([self.delegate respondsToSelector:@selector(menuView:attributesForItemWithIdentifier:)]) {
				NSDictionary *attributes = [self.delegate menuView:self attributesForItemWithIdentifier:rid];
				if (attributes) {
					NSMutableDictionary *r = [config mutableCopy];
					[r addEntriesFromDictionary:attributes];
					[rightViews addObject:r];
				} else {
					[rightViews addObject:config];
				}
			} else {
				[rightViews addObject:config];
			}
		}
	}
	if (subitems && identifier) {
		BOOL opening = [foldableRows[identifier] boolValue];
		[rightViews addObject:@{
				  kVHMenuType:@"VHMenuFoldButton",
			kVHMenuIdentifier:identifier,
			   kVHMenuOpening:@(opening)
		 }];
	}
	[cell.rightView loadItems:rightViews];
	if ([selectedIdentifier isEqualToString:identifier]) {
		[cell setSelected:YES animated:NO];
		indexPathOfSelectedRow = indexPath;
	}
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPathOfSelectedRow) {
		[[tableView cellForRowAtIndexPath:indexPathOfSelectedRow] setSelected:NO animated:YES];
		indexPathOfSelectedRow = nil;
	}
	NSDictionary *row = currentRows[indexPath.row];
	NSArray *subitems = row[kVHMenuItems];
	NSString *identifier = row[kVHMenuIdentifier];
	if (subitems && identifier) {
		BOOL opening = ![foldableRows[identifier] boolValue];
		[[NSNotificationCenter defaultCenter] postNotificationName:VHMenuOpenNotification
															object:nil
														  userInfo:@{
													kVHMenuOpening:@(opening),
												 kVHMenuIdentifier:identifier}];
		return nil;
	}
	indexPathOfSelectedRow = indexPath;
	return indexPath;
}

- (void)layoutSubviews
{
	everLayedout = YES;
	[super layoutSubviews];
}

- (void)setItemSelectedWithIdentifier:(NSString *)identifier
{
	if (![selectedIdentifier isEqualToString:identifier]) {
		selectedIdentifier = identifier;
		if (everLayedout) {
			int idx = 0;
			for (NSDictionary *row in currentRows) {
				if ([row[kVHMenuIdentifier] isEqualToString:selectedIdentifier]) {
					[_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewRowAnimationNone];
					break;
				}
				idx++;
			}
			
		}
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *row = currentRows[indexPath.row];
	NSString *identifier = row[kVHMenuIdentifier];
	if (identifier) {
		if ([self.delegate respondsToSelector:@selector(menuView:didSelectedItemWithIdentifier:)]) {
			selectedIdentifier = identifier;
			[self.delegate menuView:self didSelectedItemWithIdentifier:identifier];
		}
	}
}

@end
