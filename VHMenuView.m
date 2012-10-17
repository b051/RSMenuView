//
//  VHMenuView.m
//  viralheat
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
	__unsafe_unretained Class cellClass;
}

@synthesize textColor, highlightedTextColor;
@synthesize rowAnimation, rowSize, rowEdgeInsets;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame cellClass:[VHMenuCell class]];
}

- (id)initWithFrame:(CGRect)frame cellClass:(__unsafe_unretained Class)_cellClass
{
    self = [super initWithFrame:frame];
    if (self) {
		cellClass = _cellClass;
		NSAssert([cellClass isSubclassOfClass:[VHMenuCell class]], @"cellClass must be VHMenuCell subclass");
		_tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
		_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:_tableView];
		_tableView.delegate = self;
		textColor = [UIColor whiteColor];
		_tableView.dataSource = self;
		_tableView.backgroundColor = [UIColor clearColor];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		foldableRows = [NSMutableDictionary dictionary];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuFoldingChanged:) name:VHMenuOpenNotification object:nil];
		self.rowSize = CGSizeMake(frame.size.width, 44);
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setRowSize:(CGSize)_rowSize
{
	rowSize = _rowSize;
	_tableView.rowHeight = rowSize.height;
}

- (void)menuFoldingChanged:(NSNotification *)note
{
	id opening = [note.userInfo objectForKey:kVHMenuOpening];
	id identifier = [note.userInfo objectForKey:kVHMenuIdentifier];
	[foldableRows setObject:opening forKey:identifier];
	
	__block NSDictionary *config = nil;
	[configuration enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([[obj objectForKey:kVHMenuIdentifier] isEqualToString:identifier]) {
			*stop = YES;
			config = obj;
		}
	}];
	NSUInteger startRow = [currentRows indexOfObject:config] + 1;
	NSArray *subitems = [config objectForKey:kVHMenuItems];
	[_tableView beginUpdates];
	if ([opening boolValue]) {
		NSMutableArray *indexPaths = [NSMutableArray array];
		for (int i = 0; i < subitems.count; i++) {
			NSUInteger row = startRow + i;
			[currentRows insertObject:subitems[i] atIndex:row];
			[indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
		}
		[_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:rowAnimation];
	} else {
		NSMutableArray *indexPaths = [NSMutableArray array];
		[currentRows removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startRow, subitems.count)]];
		for (int i = 0; i < subitems.count; i++) {
			NSUInteger row = startRow + i;
			[indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
		}
		[_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:rowAnimation];
	}
	[_tableView endUpdates];
}

- (void)loadFromConfiguration:(NSArray *)_configuration
{
	[foldableRows removeAllObjects];
	configuration = _configuration;
	currentRows = [NSMutableArray arrayWithArray:configuration];
	
	[configuration enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSArray *subitems = [obj objectForKey:kVHMenuItems];
		NSString *identifier = [obj objectForKey:kVHMenuIdentifier];
		if (subitems && identifier) {
			BOOL opening = [obj[@"itemsOpened"] boolValue];
			[foldableRows setObject:@(opening) forKey:identifier];
			if (opening) [currentRows addObjectsFromArray:subitems];
		}
	}];
	[_tableView reloadData];
}

#pragma mark - UITableView Delegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
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
		cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		CGRect frame = cell.contentView.bounds;
		cell.backgroundView = [[VHRowBackgroundView alloc] initWithFrame:frame];
		cell.selectedBackgroundView = [[VHRowBackgroundView alloc] initWithFrame:frame];
		
		//imageview
		CGFloat r = frame.size.height - rowEdgeInsets.top - rowEdgeInsets.bottom;
		cell.imageView.frame = CGRectMake(rowEdgeInsets.left, rowEdgeInsets.top, r, r);
		cell.imageView.contentMode = UIViewContentModeCenter;
		
		//textlabel
		CGFloat x = r + rowEdgeInsets.left * 2;
		cell.textLabel.frame = CGRectMake(x, rowEdgeInsets.top, rowSize.width - rowEdgeInsets.right - x, r);
		cell.textLabel.textColor = [UIColor whiteColor];
		cell.textLabel.highlightedTextColor = self.highlightedTextColor;
		cell.textLabel.shadowOffset = CGSizeMake(0, 1);
		
		//rightview
		frame.size.width = rowSize.width;
		
		cell.rightView = [[VHMenuRightView alloc] initWithFrame:cell.textLabel.frame];
		cell.rightView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
		[cell.contentView addSubview:cell.rightView];
	}
	
	NSDictionary *row = [currentRows objectAtIndex:indexPath.row];
	//indent
	NSUInteger indent = [[row objectForKey:@"indent"] integerValue];
	if ([self.delegate respondsToSelector:@selector(menuView:fontForTextAtIndent:)]) {
		cell.textLabel.font = [self.delegate menuView:self fontForTextAtIndent:indent];
	}
	[(VHRowBackgroundView *)cell.backgroundView setHighlighted:indent == 0];
	
	//title
	cell.textLabel.text = [row objectForKey:@"title"];
	
	//leftviews
	NSString *leftview = [row objectForKey:@"leftview"];
	if (leftview) {
		cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_active", leftview]];
		cell.imageView.highlightedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_enabled", leftview]];
	} else {
		cell.imageView.image = nil;
	}
	//rightviews
	NSArray *subitems = [row objectForKey:kVHMenuItems];
	NSArray *rightViews = [row objectForKey:kVHMenuRightViews];
	NSString *identifier = [row objectForKey:kVHMenuIdentifier];
	if (subitems && identifier) {
		NSMutableArray *newRightViews = [NSMutableArray array];
		[newRightViews addObjectsFromArray:rightViews];
		BOOL opening = [[foldableRows objectForKey:identifier] boolValue];
		[newRightViews addObject:@{
					 kVHMenuType: @"VHMenuFoldButton",
			   kVHMenuIdentifier: identifier,
				  kVHMenuOpening: @(opening)
		 }];
		rightViews = newRightViews;
	}
	[cell.rightView loadItems:rightViews];
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *row = [currentRows objectAtIndex:indexPath.row];
	NSArray *subitems = [row objectForKey:kVHMenuItems];
	NSString *identifier = [row objectForKey:kVHMenuIdentifier];
	if (subitems && identifier) {
		BOOL opening = ![[foldableRows objectForKey:identifier] boolValue];
		[[NSNotificationCenter defaultCenter] postNotificationName:VHMenuOpenNotification
															object:nil
														  userInfo:@{
													kVHMenuOpening: @(opening),
												 kVHMenuIdentifier: identifier}];
		return nil;
	}
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *row = [currentRows objectAtIndex:indexPath.row];
	NSString *identifier = [row objectForKey:kVHMenuIdentifier];
	if (identifier) {
		if ([self.delegate respondsToSelector:@selector(menuView:didSelectedItemWithIdentifier:)]) {
			[self.delegate menuView:self didSelectedItemWithIdentifier:identifier];
		}
	}
}

@end
