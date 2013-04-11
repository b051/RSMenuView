//
//  RSMenuView.m
//
//  Created by Rex Sheng on 10/16/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "RSMenuView.h"
#import "RSMenuFoldButton.h"
#import "RSRowBackgroundView.h"
#import "RSMenuCell.h"

NSString * const kRSMenuTitle = @"title";
NSString * const kRSMenuLeftView = @"leftview";
NSString * const kRSMenuRightViews = @"rightviews";
NSString * const kRSMenuItems = @"items";

#pragma mark - RSMenuView
@interface RSMenuView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableDictionary *configuration;
@property (nonatomic, strong) NSMutableDictionary *currentRows;
@property (nonatomic, strong) NSMutableDictionary *foldableRows;
@property (nonatomic, strong) NSMutableDictionary *sectionHeaders;
@end

@implementation RSMenuView
{
	UITableView *_tableView;
	NSString *selectedIdentifier;
	NSIndexPath *indexPathOfSelectedRow;
	__unsafe_unretained Class cellClass;
	BOOL everLayedout;
	BOOL _inBatchUpdates;
	NSMutableDictionary *textFonts;
	NSMutableDictionary *textColors;
	NSMutableDictionary *rowBackgroundColors;
}

@dynamic menuHeaderView, menuFooterView;

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		cellClass = [RSMenuCell class];
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
		_foldableRows = [NSMutableDictionary dictionary];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuFoldingChanged:) name:RSMenuOpenNotification object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Appearance API
- (void)setTextFont:(UIFont *)font forIndent:(NSUInteger)indent
{
	if (!textFonts) {
		textFonts = [@{} mutableCopy];
	}
	textFonts[@(indent)] = font;
}

- (UIFont *)textFontForIndent:(NSUInteger)indent
{
	return textFonts[@(indent)];
}

- (void)setTextColor:(UIColor *)color forIndent:(NSUInteger)indent
{
	if (!textColors) {
		textColors = [@{} mutableCopy];
	}
	textColors[@(indent)] = color;
}

- (UIColor *)textColorForIndent:(NSUInteger)indent
{
	if (textColors) {
		UIColor *color = textColors[@(indent)];
		if (color) return color;
	}
	return _textColor;
}

- (void)setRowBackgroundColor:(UIColor *)color forIndent:(NSUInteger)indent
{
	if (!rowBackgroundColors) {
		rowBackgroundColors = [@{} mutableCopy];
	}
	rowBackgroundColors[@(indent)] = color;
}

- (UIColor *)rowBackgroundColorForIndent:(NSUInteger)indent
{
	if (rowBackgroundColors) {
		UIColor *color = rowBackgroundColors[@(indent)];
		if (color) return color;
	}
	return [UIColor clearColor];
}

- (void)setMenuFooterView:(UIView *)menuFooterView
{
	_tableView.tableFooterView = menuFooterView;
}

- (UIView *)menuFooterView
{
	return _tableView.tableFooterView;
}

- (UIView *)menuHeaderView
{
	return _tableView.tableHeaderView;
}

- (void)setMenuHeaderView:(UIView *)menuHeaderView
{
	_tableView.tableHeaderView = menuHeaderView;
}

- (void)setRowHeight:(CGFloat)rowHeight
{
	_tableView.rowHeight = rowHeight;
}

- (CGFloat)rowHeight
{
	return _tableView.rowHeight;
}

- (NSMutableArray *)rowsForSection:(NSUInteger)section
{
	if (!_configuration) _configuration = [@{} mutableCopy];
	
	NSMutableArray *sectionConfig = _configuration[@(section)];
	if (!sectionConfig) {
		sectionConfig = [NSMutableArray array];
		_configuration[@(section)] = sectionConfig;
	}
	return sectionConfig;
}

- (NSMutableArray *)currentRowsForSection:(NSUInteger)section
{
	if (!_currentRows) _currentRows = [@{} mutableCopy];
	
	NSMutableArray *sectionConfig = _currentRows[@(section)];
	if (!sectionConfig) {
		sectionConfig = [NSMutableArray array];
		_currentRows[@(section)] = sectionConfig;
	}
	return sectionConfig;
}

#pragma mark - Menu Operations
- (NSIndexPath *)indexPathOfDisplayingRowsWithIdentifier:(NSString *)identifier
{
	__block NSIndexPath *indexPath = nil;
	[_currentRows enumerateKeysAndObjectsUsingBlock:^(NSNumber *section, NSArray *currentRows, BOOL *stop) {
		int idx = 0;
		for (NSDictionary *row in currentRows) {
			if ([row[kRSMenuIdentifier] isEqualToString:identifier]) {
				indexPath = [NSIndexPath indexPathForRow:idx inSection:section.integerValue];
				*stop = YES;
				break;
			}
			idx++;
		}
	}];
	return indexPath;
}

- (void)setItemSelectedWithIdentifier:(NSString *)identifier
{
	if (![selectedIdentifier isEqualToString:identifier]) {
		selectedIdentifier = identifier;
		if (everLayedout) {
			NSIndexPath *selectIndexPath = [self indexPathOfDisplayingRowsWithIdentifier:identifier];
			if (selectIndexPath) [_tableView selectRowAtIndexPath:selectIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
		}
	}
}

- (void)menuFoldingChanged:(NSNotification *)note
{
	id opening = (note.userInfo)[kRSMenuOpening];
	id identifier = (note.userInfo)[kRSMenuIdentifier];
	_foldableRows[identifier] = opening;
	
	__block NSDictionary *config = nil;
	__block NSUInteger section = 0;
	[self.configuration enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSArray *obj, BOOL *stop) {
		[obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if ([obj[kRSMenuIdentifier] isEqualToString:identifier]) {
				*stop = YES;
				config = obj;
				section = key.integerValue;
			}
		}];
		if (config) *stop = YES;
	}];
	
	NSMutableArray *currentRows = [self currentRowsForSection:section];
	NSUInteger startRow = [currentRows indexOfObject:config] + 1;
	NSArray *subitems = config[kRSMenuItems];
	[_tableView beginUpdates];
	if ([opening boolValue]) {
		NSMutableArray *indexPaths = [NSMutableArray array];
		for (int i = 0; i < subitems.count; i++) {
			NSUInteger row = startRow + i;
			[currentRows insertObject:subitems[i] atIndex:row];
			[indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
		}
		[_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:_rowAnimation];
	} else {
		NSMutableArray *indexPaths = [NSMutableArray array];
		[currentRows removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startRow, subitems.count)]];
		for (int i = 0; i < subitems.count; i++) {
			NSUInteger row = startRow + i;
			[indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
		}
		[_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:_rowAnimation];
	}
	[_tableView endUpdates];
}

- (NSArray *)_insertItem:(NSDictionary *)obj atIndex:(NSUInteger)idx section:(NSUInteger)section
{
	NSMutableArray *indexPaths = [@[] mutableCopy];
	NSMutableArray *currentRows = [self currentRowsForSection:section];
	
	[currentRows insertObject:obj atIndex:idx];
	[indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:section]];
	NSArray *subitems = obj[kRSMenuItems];
	NSString *identifier = obj[kRSMenuIdentifier];
	if (subitems && identifier) {
		BOOL opening = [obj[@"itemsOpened"] boolValue];
		_foldableRows[identifier] = @(opening);
		if (opening) {
			for (int i = 0; i < subitems.count; i++) {
				NSUInteger row = idx + i;
				[currentRows insertObject:subitems[i] atIndex:row];
				[indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
			}
		}
	}
	return indexPaths;
}

- (NSArray *)_deleteItemAtIndex:(NSUInteger)idx section:(NSUInteger)section
{
	NSMutableArray *indexPaths = [@[] mutableCopy];
	NSMutableArray *currentRows = [self currentRowsForSection:section];
	
	if (currentRows.count > idx) {
		NSDictionary *obj = currentRows[idx];
		NSArray *subitems = obj[kRSMenuItems];
		NSString *identifier = obj[kRSMenuIdentifier];
		if (subitems && identifier) {
			if ([_foldableRows[identifier] boolValue]) {
				[currentRows removeObjectsInRange:NSMakeRange(idx + 1, subitems.count)];
				for (int i = 0; i < subitems.count; i++) {
					[indexPaths addObject:[NSIndexPath indexPathForRow:idx + 1 + i inSection:section]];
				}
			}
		}
		[currentRows removeObjectAtIndex:idx];
		[indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:section]];
	}
	return indexPaths;
}

- (void)setItems:(NSArray *)configuration forSection:(NSUInteger)section sectionHeader:(NSDictionary *)sectionHeader
{
	[_foldableRows removeAllObjects];
	NSMutableArray *currentRows = [self currentRowsForSection:section];
	[currentRows removeAllObjects];
	[[self rowsForSection:section] addObjectsFromArray:configuration];
	if (sectionHeader) {
		if (!_sectionHeaders) _sectionHeaders = [@{} mutableCopy];
		_sectionHeaders[@(section)] = sectionHeader;
	}
	[configuration enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[self _insertItem:obj atIndex:currentRows.count section:section];
	}];
	
	[_tableView reloadData];
}

- (void)setItems:(NSArray *)configuration
{
	[self setItems:configuration forSection:0 sectionHeader:nil];
}

- (void)updateSectionItem:(NSDictionary *)item atSection:(NSUInteger)section
{
	if (!_inBatchUpdates) [_tableView beginUpdates];
	if (item) {
		if (!_sectionHeaders) _sectionHeaders = [@{} mutableCopy];
		_sectionHeaders[@(section)] = item;
		[_tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
	}
	if (!_inBatchUpdates) [_tableView endUpdates];
}

- (void)insertItem:(NSDictionary *)item atRow:(NSUInteger)row section:(NSUInteger)section
{
	if (!_tableView) return;
	if (!_inBatchUpdates) [_tableView beginUpdates];
	
	NSMutableArray *configuration = [self rowsForSection:section];
	NSMutableArray *currentRows = [self currentRowsForSection:section];
	
	NSUInteger relativeRow = 0;
	if (configuration.count > row) {
		relativeRow = [currentRows indexOfObject:configuration[row]];
	}
	
	[configuration insertObject:item atIndex:row];
	NSArray *paths = [self _insertItem:item atIndex:relativeRow section:section];
	[_tableView insertRowsAtIndexPaths:paths withRowAnimation:_rowAnimation];
	if (!_inBatchUpdates) [_tableView endUpdates];
}

- (void)insertItem:(NSDictionary *)item atRow:(NSUInteger)row
{
	[self insertItem:item atRow:row section:0];
}

- (void)deleteItemAtRow:(NSUInteger)row section:(NSUInteger)section
{
	if (!_inBatchUpdates) [_tableView beginUpdates];
	
	NSMutableArray *configuration = [self rowsForSection:section];
	NSMutableArray *currentRows = [self currentRowsForSection:section];
	
	if (configuration.count > row) {
		NSUInteger relativeRow = [currentRows indexOfObject:configuration[row]];
		[configuration removeObjectAtIndex:row];
		NSArray *paths = [self _deleteItemAtIndex:relativeRow section:section];
		[_tableView deleteRowsAtIndexPaths:paths withRowAnimation:_rowAnimation];
	}
	
	if (!_inBatchUpdates) [_tableView endUpdates];
}

- (void)deleteItemAtRow:(NSUInteger)row
{
	[self deleteItemAtRow:row section:0];
}

- (void)replaceItemAtRow:(NSUInteger)row section:(NSUInteger)section withItem:(NSDictionary *)item
{
	if (!_inBatchUpdates) [_tableView beginUpdates];
	
	NSMutableArray *configuration = [self rowsForSection:section];
	NSMutableArray *currentRows = [self currentRowsForSection:section];
	
	if (configuration.count > row) {
		NSUInteger relativeRow = [currentRows indexOfObject:configuration[row]];
		configuration[row] = item;
		NSArray *_deletePaths = [self _deleteItemAtIndex:relativeRow section:section];
		NSArray *_insertPaths = [self _insertItem:item atIndex:relativeRow section:section];
		NSMutableArray *deletePaths = [_deletePaths mutableCopy];
		NSMutableArray *insertPaths = [_insertPaths mutableCopy];
		NSMutableArray *updatePaths = [@[] mutableCopy];
		for (NSIndexPath *path in _insertPaths) {
			if ([_deletePaths containsObject:path]) {
				[updatePaths addObject:path];
				[deletePaths removeObject:path];
				[insertPaths removeObject:path];
			}
		}
		if (updatePaths.count) [_tableView reloadRowsAtIndexPaths:updatePaths withRowAnimation:_rowAnimation];
		if (deletePaths.count) [_tableView deleteRowsAtIndexPaths:deletePaths withRowAnimation:_rowAnimation];
		if (insertPaths.count) [_tableView insertRowsAtIndexPaths:insertPaths withRowAnimation:_rowAnimation];
	}
	
	if (!_inBatchUpdates) [_tableView endUpdates];
}

- (void)replaceItemAtRow:(NSUInteger)row withItem:(NSDictionary *)item
{
	[self replaceItemAtRow:row section:0 withItem:item];
}

- (void)performBatchUpdates:(dispatch_block_t)updates
{
	[_tableView beginUpdates];
	_inBatchUpdates = YES;
	updates();
	_inBatchUpdates = NO;
	[_tableView endUpdates];
}

#pragma mark - UITableView Delegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return _currentRows.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self currentRowsForSection:section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	NSDictionary *config = _sectionHeaders[@(section)];
	if (config) {
		if ([self.delegate respondsToSelector:@selector(menuView:heightForItemWithIdentifier:)]) {
			return [self.delegate menuView:self heightForItemWithIdentifier:config[kRSMenuIdentifier]];
		}
		return self.rowHeight;
	}
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSDictionary *config = _sectionHeaders[@(section)];
	UIView *view = nil;
	if (config) {
		view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
		RSMenuCell *cell = [self cellForRow:config identifier:@"header"];
		cell.frame = view.bounds;
		cell.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		[view addSubview:cell];
		[view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSectionHeader:)]];
	}
	return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([self.delegate respondsToSelector:@selector(menuView:heightForItemWithIdentifier:)]) {
		NSArray *currentRows = [self currentRowsForSection:indexPath.section];
		NSDictionary *row = currentRows[indexPath.row];
		return [self.delegate menuView:self heightForItemWithIdentifier:row[kRSMenuIdentifier]];
	}
	return self.rowHeight;
}

- (NSMutableArray *)updateMenuCellItemAttributes:(NSArray *)conf
{
    NSMutableArray *atrributes = [NSMutableArray array];
	if (conf) {
		BOOL customize = [self.delegate respondsToSelector:@selector(menuView:attributesForItemWithIdentifier:)];
		for (NSDictionary *config in conf) {
			if (customize) {
				id rid = config[kRSMenuIdentifier];
				NSDictionary *attributes = [self.delegate menuView:self attributesForItemWithIdentifier:rid];
				if (attributes) {
					NSMutableDictionary *r = [config mutableCopy];
					[r addEntriesFromDictionary:attributes];
					[atrributes addObject:r];
				} else {
					[atrributes addObject:config];
				}
			} else {
				[atrributes addObject:config];
			}
		}
	}
    return atrributes;
}

- (RSMenuCell *)cellForRow:(NSDictionary *)row identifier:(NSString *)cellIdentifier
{
	NSUInteger indent = [row[@"indent"] integerValue];
	
	RSMenuCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[RSMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		CGRect frame = cell.contentView.bounds;
		//imageview
		CGFloat r = _tableView.rowHeight - _rowEdgeInsets.top - _rowEdgeInsets.bottom;
		cell.leftView.frame = cell.imageView.frame = CGRectMake(_rowEdgeInsets.top, _rowEdgeInsets.top, r, r);
		//textlabel
		cell.rightView.frame = cell.textLabel.frame = UIEdgeInsetsInsetRect(frame, _rowEdgeInsets);
		cell.textLabel.highlightedTextColor = _highlightedTextColor;
		cell.textLabel.shadowOffset = _textShadowOffset;
	}
	//indent
	cell.textLabel.font = [self textFontForIndent:indent];
	cell.textLabel.textColor = [self textColorForIndent:indent];
	cell.backgroundView.backgroundColor = [self rowBackgroundColorForIndent:indent];
	cell.textLabel.text = row[@"title"];
	id leftview = row[kRSMenuLeftView];
	if (leftview) {
		if ([leftview isKindOfClass:[NSDictionary class]]) {
			NSMutableArray *leftViews = [self updateMenuCellItemAttributes:@[leftview]];
			[cell.leftView loadItems:leftViews];
			cell.imageView.image = nil;
		} else {
			UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_active", leftview]];
			cell.imageView.image = image ?: [UIImage imageNamed:leftview];
			cell.imageView.highlightedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_enabled", leftview]];
			cell.leftView.hidden = YES;
		}
	} else {
		cell.leftView.hidden = YES;
		cell.imageView.image = nil;
	}
	//rightviews
	NSArray *subitems = row[kRSMenuItems];
	NSString *identifier = row[kRSMenuIdentifier];
	cell.identifier = identifier;
	NSMutableArray *rightViews = [self updateMenuCellItemAttributes:row[kRSMenuRightViews]];
	if (subitems && identifier) {
		BOOL opening = [_foldableRows[identifier] boolValue];
		[rightViews addObject:@{
				  kRSMenuType:@"RSMenuFoldButton",
			kRSMenuIdentifier:identifier,
			   kRSMenuOpening:@(opening)
		 }];
	}
	[cell.rightView loadItems:rightViews];
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *row = [self currentRowsForSection:indexPath.section][indexPath.row];
	static NSString *cellIdentifier = @"RSMenuCell";
	RSMenuCell *cell = [self cellForRow:row identifier:cellIdentifier];
	if ([selectedIdentifier isEqualToString:cell.identifier]) {
		indexPathOfSelectedRow = indexPath;
		[tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
		[cell setSelected:YES animated:NO];
	}
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPathOfSelectedRow) {
		[[tableView cellForRowAtIndexPath:indexPathOfSelectedRow] setSelected:NO animated:YES];
		indexPathOfSelectedRow = nil;
	}
	NSDictionary *row = [self currentRowsForSection:indexPath.section][indexPath.row];
	NSArray *subitems = row[kRSMenuItems];
	NSString *identifier = row[kRSMenuIdentifier];
	if (subitems && identifier) {
		BOOL opening = ![_foldableRows[identifier] boolValue];
		[[NSNotificationCenter defaultCenter] postNotificationName:RSMenuOpenNotification
															object:nil
														  userInfo:@{
													kRSMenuOpening:@(opening),
												 kRSMenuIdentifier:identifier}];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *row = [self currentRowsForSection:indexPath.section][indexPath.row];
	NSString *identifier = row[kRSMenuIdentifier];
	if (identifier) {
		selectedIdentifier = identifier;
		if ([self.delegate respondsToSelector:@selector(menuView:didSelectItemWithIdentifier:)]) {
			[self.delegate menuView:self didSelectItemWithIdentifier:identifier];
		}
	}
}

- (void)tapSectionHeader:(UITapGestureRecognizer *)tap
{
	if (tap.state == UIGestureRecognizerStateRecognized) {
		NSString *identifier = ((RSMenuCell *)(tap.view.subviews[0])).identifier;
		if ([self.delegate respondsToSelector:@selector(menuView:didSelectItemWithIdentifier:)]) {
			[self.delegate menuView:self didSelectItemWithIdentifier:identifier];
		}
	}
}

@end
