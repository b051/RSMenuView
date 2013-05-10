//
//  RSRowBackgroundView.h
//
//  Created by Rex Sheng on 10/16/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSRowBackgroundView : UIView

@property (nonatomic) BOOL highlighted;
@property (nonatomic, strong) UIColor *rowBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIImage *rowSeperatorImage UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat normalAlpha UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat highlightedAlpha UI_APPEARANCE_SELECTOR;
@property (nonatomic) BOOL alsoShowTopSeperator;

@end
