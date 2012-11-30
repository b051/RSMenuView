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
@property (nonatomic, strong) NSMutableArray *configuration;
@property (nonatomic, strong) NSMutableArray *currentRows;
@property (nonatomic, strong) NSMutableDictionary *foldableRows;
@end

@implementation VHMenuView
{
	UITableView *_tableView;
	NSString *selectedIdentifier;
	NSIndexPath *indexPathOfSelectedRow;
	__unsafe_unretained Class cellClass;
	BOOL everLayedout;
	BOOL _inBatchUpdates;
	NSMutableDictionary *textFonts;
}

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
		_foldableRows = [NSMutableDictionary dictionary];
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
	_foldableRows[identifier] = opening;
	
	__block NSDictionary *config = nil;
	[self.configuration enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj[kVHMenuIdentifier] isEqualToString:identifier]) {
			*stop = YES;
			config = obj;
		}
	}];
	NSUInteger startRow = [_currentRows indexOfObject:config] + 1;
	NSArray *subitems = config[kVHMenuItems];
	[_tableView beginUpdates];
	if ([opening boolValue]) {
		NSMutableArray *indexPaths = [NSMutableArray array];
		for (int i = 0; i < subitems.count; i++) {
			NSUInteger row = startRow + i;
			[_currentRows insertObject:subitems[i] atIndex:row];
			[indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
		}
		[_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:_rowAnimation];
	} else {
		NSMutableArray *indexPaths = [NSMutableArray array];
		[_currentRows removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startRow, subitems.count)]];
		for (int i = 0; i < subitems.count; i++) {
			NSUInteger row = startRow + i;
			[indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
		}
		[_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:_rowAnimation];
	}
	[_tableView endUpdates];
}

- (NSArray *)_insertItem:(NSDictionary *)obj atIndex:(NSUInteger)idx
{
	NSMutableArray *indexPaths = [@[] mutableCopy];
	[_currentRows insertObject:obj atIndex:idx];
	[indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
	NSArray *subitems = obj[kVHMenuItems];
	NSString *identifier = obj[kVHMenuIdentifier];
	if (subitems && identifier) {
		BOOL opening = [obj[@"itemsOpened"] boolValue];
		_foldableRows[identifier] = @(opening);
		if (opening) {
			for (int i = 0; i < subitems.count; i++) {
				NSUInteger row = idx + i;
				[_currentRows insertObject:subitems[i] atIndex:row];
				[indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
			}
		}
	}
	return indexPaths;
}

- (NSArray *)_deleteItemAtIndex:(NSUInteger)idx
{
	NSMutableArray *indexPaths = [@[] mutableCopy];
	if (_currentRows.count > idx) {
		NSDictionary *obj = _currentRows[idx];
		NSArray *subitems = obj[kVHMenuItems];
		NSString *identifier = obj[kVHMenuIdentifier];
		if (subitems && identifier) {
			if ([_foldableRows[identifier] boolValue]) {
				[_currentRows removeObjectsInRange:NSMakeRange(idx + 1, subitems.count)];
				for (int i = 0; i < subitems.count; i++) {
					[indexPaths addObject:[NSIndexPath indexPathForRow:idx + 1 + i inSection:0]];
				}
			}
		}
		[_currentRows removeObjectAtIndex:idx];
		[indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
	}
	return indexPaths;
}

- (void)setItems:(NSArray *)configuration
{
	[_foldableRows removeAllObjects];
	_configuration = [configuration mutableCopy];
	_currentRows = [@[] mutableCopy];
	
	[configuration enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[self _insertItem:obj atIndex:_currentRows.count];
	}];
	
	[_tableView reloadData];
}

- (void)insertItem:(NSDictionary *)item atRow:(NSUInteger)row
{
	if (!_inBatchUpdates) [_tableView beginUpdates];
	
	NSUInteger relativeRow = 0;
	if (_configuration.count > row) {
		relativeRow = [_currentRows indexOfObject:_configuration[row]];
	}
	[_configuration insertObject:item atIndex:row];
	NSArray *paths = [self _insertItem:item atIndex:relativeRow];
	[_tableView insertRowsAtIndexPaths:paths withRowAnimation:_rowAnimation];
	
	if (!_inBatchUpdates) [_tableView endUpdates];
}

- (void)deleteItemAtRow:(NSUInteger)row
{
	if (!_inBatchUpdates) [_tableView beginUpdates];
	
	if (_configuration.count > row) {
		NSUInteger relativeRow = [_currentRows indexOfObject:_configuration[row]];
		[_configuration removeObjectAtIndex:row];
		NSArray *paths = [self _deleteItemAtIndex:relativeRow];
		[_tableView deleteRowsAtIndexPaths:paths withRowAnimation:_rowAnimation];
	}
	
	if (!_inBatchUpdates) [_tableView endUpdates];
}

- (void)replaceItemAtRow:(NSUInteger)row withItem:(NSDictionary *)item
{
	if (!_inBatchUpdates) [_tableView beginUpdates];
	
	if (_configuration.count > row) {
		NSUInteger relativeRow = [_currentRows indexOfObject:_configuration[row]];
		_configuration[row] = item;
		NSArray *_deletePaths = [self _deleteItemAtIndex:relativeRow];
		NSArray *_insertPaths = [self _insertItem:item atIndex:relativeRow];
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
	return _currentRows ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _currentRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"VHMenuCell";
	VHMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[VHMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
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
	}
	NSDictionary *row = _currentRows[indexPath.row];
	//indent
	NSUInteger indent = [row[@"indent"] integerValue];
	cell.textLabel.font = [self textFontForIndent:indent];
	[(VHRowBackgroundView *)cell.backgroundView setHighlighted:indent == 0];
	cell.textLabel.text = row[@"title"];
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
		BOOL opening = [_foldableRows[identifier] boolValue];
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
	NSDictionary *row = _currentRows[indexPath.row];
	NSArray *subitems = row[kVHMenuItems];
	NSString *identifier = row[kVHMenuIdentifier];
	if (subitems && identifier) {
		BOOL opening = ![_foldableRows[identifier] boolValue];
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
			for (NSDictionary *row in _currentRows) {
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
	NSDictionary *row = _currentRows[indexPath.row];
	NSString *identifier = row[kVHMenuIdentifier];
	if (identifier) {
		if ([self.delegate respondsToSelector:@selector(menuView:didSelectedItemWithIdentifier:)]) {
			selectedIdentifier = identifier;
			[self.delegate menuView:self didSelectedItemWithIdentifier:identifier];
		}
	}
}

@end
