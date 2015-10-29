//
//  BadgeView.m
//  PositionIn
//
//  Created by Alexandr Goncharov on 30/10/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import "BadgeView.h"

static CAAnimation *newFadeOutAnimation(void)
{
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
    transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.05, 0.05, 1.0)];
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = @1.0;
    fadeAnimation.toValue = @0.0;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[ transformAnimation, fadeAnimation ];
    animationGroup.duration = 0.3;
    animationGroup.removedOnCompletion = YES;
    
    return animationGroup;
}

static CAAnimation *newBounceInAnimation(void)
{
    CAKeyframeAnimation *transformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    transformAnimation.values = @[
                                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.05, 0.05, 1.0)],
                                  
                                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.4, 1.4, 1.0)],
                                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1.0)],
                                  
                                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1.0)],
                                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.975, 0.975, 1.0)],
                                  
                                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)],
                                  ];
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = @0.0;
    fadeAnimation.toValue = @1.0;
    fadeAnimation.duration = 0.5 / 5.0 * 2.0;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[ transformAnimation, fadeAnimation ];
    animationGroup.duration = 0.5;
    animationGroup.removedOnCompletion = YES;
    
    return animationGroup;
}

@interface BadgeView ()

@property (nonatomic, readonly) UIFont *font;
@property (nonatomic, copy) void(^animationCompletionBlock)(BOOL finished);

@end


@implementation BadgeView

#pragma mark - setters and getters

- (void)setText:(NSString *)text animated:(BOOL)animated
{
    
    if (text != _text && ![text isEqual:_text]) {
        BOOL shouldBounceIn = animated && text.length > 0 && _text.length == 0;
        BOOL shouldFadeOut = animated && text.length == 0 && _text.length > 0;
        
        NSString *animationKey = @"fadeOutOrBounceInAnimation";
        
        if ([self.layer animationForKey:animationKey]) {
            [self.layer removeAnimationForKey:animationKey];
            
            if (self.animationCompletionBlock) {
                self.animationCompletionBlock(NO);
                self.animationCompletionBlock = nil;
            }
        }
        
        if (shouldBounceIn) {
            [self willChangeValueForKey:@"text"];
            
            _text = text;
            [self setNeedsDisplay];
            
            [self didChangeValueForKey:@"text"];
            
            CAAnimation *bounceInAnimation = newBounceInAnimation();
            bounceInAnimation.delegate = self;
            
            [self.layer addAnimation:bounceInAnimation forKey:@"fadeOutOrBounceInAnimation"];
        } else if (shouldFadeOut) {
            __weak BadgeView *weakSelf = self;
            [self setAnimationCompletionBlock:^(BOOL finished) {
                BadgeView *strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                
                [strongSelf willChangeValueForKey:@"text"];
                
                strongSelf->_text = text;
                [strongSelf setNeedsDisplay];
                
                [strongSelf didChangeValueForKey:@"text"];
            }];
            
            self.layer.opacity = 0.0;
            
            CAAnimation *fadeOutAnimation = newFadeOutAnimation();
            fadeOutAnimation.delegate = self;
            
            [self.layer addAnimation:fadeOutAnimation forKey:@"fadeOutOrBounceInAnimation"];
        } else {
            [self willChangeValueForKey:@"text"];
            
            _text = text;
            [self setNeedsDisplay];
            
            [self didChangeValueForKey:@"text"];
        }
    }
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.animationCompletionBlock) {
        self.animationCompletionBlock(flag);
    }
    
    self.animationCompletionBlock = nil;
    [self.layer removeAnimationForKey:@"fadeOutOrBounceInAnimation"];
}

#pragma mark - Initialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commotInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.needsDisplayOnBoundsChange = YES;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        
        _badgeColor = [UIColor redColor];
        [self commotInit];
    }
    return self;
}

- (void)commotInit {
    _font = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [UIFont boldSystemFontOfSize:17.0] : [UIFont boldSystemFontOfSize:12.0];
}

- (void)drawRect:(CGRect)rect
{
    [[UIColor colorWithRed:121.0 / 255.0 green:20.0 / 255.0 blue:9.0 / 255.0 alpha:1.0] setFill];
    [self.badgeColor setFill];
    
    CGFloat insets = [UIScreen mainScreen].scale > 1.0 ? 0.5 : 1.0;
    CGFloat radius = MIN(CGRectGetHeight(rect), CGRectGetWidth(rect)) / 2.0;
    UIBezierPath *badgePath = [UIBezierPath bezierPathWithRoundedRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(insets, insets, insets, insets))
                                                         cornerRadius:radius];
    
    [badgePath fill];
    
    NSMutableParagraphStyle *paragraphStyle = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: _font,
                                 NSParagraphStyleAttributeName: paragraphStyle,
                                 NSForegroundColorAttributeName: [UIColor whiteColor]
                                 };
    
    CGSize size = [_text boundingRectWithSize:rect.size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    CGRect textRect = CGRectMake(CGRectGetMidX(rect) - size.width / 2.0,
                                 CGRectGetMidY(rect) - size.height / 2.0,
                                 size.width,
                                 size.height);
    
    [_text drawInRect:textRect withAttributes:attributes];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    NSString *text = _text ?: @"";
    
    NSMutableParagraphStyle *paragraphStyle = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: _font,
                                 NSParagraphStyleAttributeName: paragraphStyle,
                                 NSForegroundColorAttributeName: [UIColor whiteColor]
                                 };
    
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return CGSizeMake(textSize.width + 2.0 * 8.0, 22.0);
    }
    
    return CGSizeMake(textSize.width + 2.0 * 10.0, 25.0);
}


@end
