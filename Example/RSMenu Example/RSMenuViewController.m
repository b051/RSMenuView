//
//  RSMenuViewController.m
//  viralheat
//
//  Created by Rex Sheng on 10/10/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "RSMenuViewController.h"
#import "RSRowBackgroundView.h"
#import "RSMenuView.h"

@interface RSMenuViewController () <RSMenuViewDelegate>

@end

@implementation RSMenuViewController
{
	UILabel *nameLabel;
	UIImageView *avatarView;
	RSMenuView *menuView;
	NSUInteger count;
	NSTimer *testTimer;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu_pattern"]];
	
	CGSize size = self.view.bounds.size;
	
	CGFloat height = 44.f;
	CGFloat margin = 7.f;
	CGFloat avatarWidth = height - margin * 2;
	RSRowBackgroundView *headerView = [[RSRowBackgroundView alloc] initWithFrame:CGRectMake(0, 0, size.width, height)];
	headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:headerView];
	avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(margin, margin, avatarWidth, avatarWidth)];
	[headerView addSubview:avatarView];
	UIFont *font = [UIFont systemFontOfSize:20];
	nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(height, (height - font.lineHeight) / 2, size.width - height, font.lineHeight)];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.font = font;
	nameLabel.textColor = [UIColor colorWithWhite:.7 alpha:1];
	nameLabel.shadowColor = [UIColor blackColor];
	nameLabel.shadowOffset = CGSizeMake(0, 1);
	[headerView addSubview:nameLabel];
	menuView = [[RSMenuView alloc] initWithFrame:CGRectMake(0, height, size.width, size.height - height)];
	menuView.delegate = self;
	menuView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	menuView.highlightedTextColor = [UIColor colorWithRed:.93f green:.5f blue:.21f alpha:1];
	menuView.rowEdgeInsets = UIEdgeInsetsMake(0, 1.5, 0, 16);
	[self.view addSubview:menuView];

	nameLabel.text = @"Author: Rex Sheng";
	NSString *configFile = [[NSBundle mainBundle] pathForResource:@"Menu" ofType:@"plist"];
	[menuView setItems:[NSArray arrayWithContentsOfFile:configFile]];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	count = 0;
	testTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(step) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[testTimer invalidate];
	testTimer = nil;
}

- (void)step
{
	count += 2;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"saved[0].count" object:@(count)];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"saved[1].count" object:@(count / 2)];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"messages.scheduled.count" object:@(count / 4)];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	nameLabel = nil;
	avatarView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIFont *)menuView:(RSMenuView *)menuView fontForTextAtIndent:(NSUInteger)indent
{
	if (indent) {
		return [UIFont systemFontOfSize:15.1f];
	} else {
		return [UIFont boldSystemFontOfSize:17.15f];
	}
}

@end
