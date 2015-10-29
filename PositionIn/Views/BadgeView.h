//
//  BadgeView.h
//  PositionIn
//
//  Created by Alexandr Goncharov on 30/10/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BadgeView : UIView

/**
 The color of the badge.
 */
@property (nonatomic, strong) UIColor *badgeColor;

@property (nonatomic, nullable, copy, readonly) NSString *text;
- (void)setText:(NSString * __nullable)text animated:(BOOL)animated;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;


@end

NS_ASSUME_NONNULL_END