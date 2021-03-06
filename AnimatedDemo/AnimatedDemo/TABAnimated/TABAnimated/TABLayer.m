//
//  TABLayer.m
//  AnimatedDemo
//
//  Created by tigerAndBull on 2019/3/24.
//  Copyright © 2019年 tigerAndBull. All rights reserved.
//

#import "TABLayer.h"
#import "TABAnimated.h"

static CGFloat defaultHeight = 16.f;

@implementation TABLayer

- (instancetype)init {
    if (self = [super init]) {
        self.name = @"TABLayer";
        self.anchorPoint = CGPointMake(0, 0);
        self.position = CGPointMake(0, 0);
        self.opaque = YES;
        self.contentsScale = ([[UIScreen mainScreen] scale] > 3.0) ? [[UIScreen mainScreen] scale]:3.0;
    }
    return self;
}

- (void)updateSublayers:(NSArray <TABComponentLayer *> *)componentLayerArray {
    
    self.backgroundColor = [self.animatedBackgroundColor CGColor];
    
    [TABManagerMethod removeSubLayers:self.sublayers];
    
    for (int i = 0; i < componentLayerArray.count; i++) {
        
        TABComponentLayer *layer = componentLayerArray[i];
        
        if (layer.loadStyle == TABViewLoadAnimationRemove) {
            continue;
        }
        
        CGRect rect = [self resetFrame:layer rect:layer.frame];
        layer.frame = rect;
        
        CGFloat cornerRadius = layer.cornerRadius;
        NSInteger labelLines = layer.numberOflines;
        
        if (labelLines != 1) {
            [self addLayers:rect
               cornerRadius:cornerRadius
                      lines:labelLines
                      space:layer.lineSpace
                  loadStyle:layer.loadStyle];
        }else {
            
            layer.backgroundColor = self.animatedColor.CGColor;
            
            // 设置动画
            if (layer.loadStyle != TABAnimationTypeOnlySkeleton) {
                [layer addAnimation:[self getAnimationWithLoadStyle:layer.loadStyle] forKey:kTABLocationAnimation];
            }
            
            BOOL isImageView = layer.fromImageView;
            if (!isImageView) {
                // 设置圆角
                if (cornerRadius == 0.) {
                    if (self.cancelGlobalCornerRadius) {
                        layer.cornerRadius = self.animatedCornerRadius;
                    }else {
                        if ([TABAnimated sharedAnimated].useGlobalCornerRadius) {
                            if ([TABAnimated sharedAnimated].animatedCornerRadius != 0.) {
                                layer.cornerRadius = [TABAnimated sharedAnimated].animatedCornerRadius;
                            }else {
                                layer.cornerRadius = layer.frame.size.height/2.0;
                            }
                        }
                    }
                }else {
                    layer.cornerRadius = cornerRadius;
                }
            }
            
            [self addSublayer:layer];
        }
    }
}

- (void)addLayers:(CGRect)frame
     cornerRadius:(CGFloat)cornerRadius
            lines:(NSInteger)lines
            space:(CGFloat)space
        loadStyle:(TABViewLoadAnimationStyle)loadStyle {
    
    CGFloat textHeight = defaultHeight*[TABAnimated sharedAnimated].animatedHeightCoefficient;
    
    if (lines == 0) {
        lines = (frame.size.height*1.0)/(textHeight+space);
        if (lines >= 0 && lines <= 1) {
            tabAnimatedLog(@"TABAnimated提醒 - 监测到多行文本高度为0，动画时将使用默认行数3");
            lines = 3;
        }
    }
    
    for (NSInteger i = 0; i < lines; i++) {
        
        CGRect rect;
        if (i != lines - 1) {
            rect = CGRectMake(frame.origin.x, frame.origin.y+i*(textHeight+space), frame.size.width, textHeight);
        }else {
            rect = CGRectMake(frame.origin.x, frame.origin.y+i*(textHeight+space), frame.size.width*0.5, textHeight);
        }
        
        CALayer *layer = [[CALayer alloc]init];
        layer.anchorPoint = CGPointMake(0, 0);
        layer.position = CGPointMake(0, 0);
        layer.frame = rect;
        layer.backgroundColor = self.animatedColor.CGColor;
        
        if (cornerRadius == 0.) {
            if (self.cancelGlobalCornerRadius) {
                layer.cornerRadius = self.animatedCornerRadius;
            }else {
                if ([TABAnimated sharedAnimated].useGlobalCornerRadius) {
                    if ([TABAnimated sharedAnimated].animatedCornerRadius != 0.) {
                        layer.cornerRadius = [TABAnimated sharedAnimated].animatedCornerRadius;
                    }else {
                        layer.cornerRadius = layer.frame.size.height/2.0;
                    }
                }
            }
        }else {
            layer.cornerRadius = cornerRadius;
        }
        
        if (i == lines - 1) {
            if (loadStyle != TABAnimationTypeOnlySkeleton) {
                [layer addAnimation:[self getAnimationWithLoadStyle:loadStyle] forKey:kTABLocationAnimation];
            }
        }
        
        [self addSublayer:layer];
    }
}

#pragma mark - Private

- (CABasicAnimation *)getAnimationWithLoadStyle:(TABViewLoadAnimationStyle)loadStyle {
    CGFloat duration = [TABAnimated sharedAnimated].animatedDuration;
    CGFloat value = 0.;
    
    if (loadStyle == TABViewLoadAnimationToLong) {
        value = [TABAnimated sharedAnimated].longToValue;
    }else {
        value = [TABAnimated sharedAnimated].shortToValue;
    }
    return [TABAnimationMethod scaleXAnimationDuration:duration toValue:value];
}

- (CGRect)resetFrame:(TABComponentLayer *)layer
                rect:(CGRect)rect {
    
    rect = CGRectMake(rect.origin.x + self.cardOffset.x, rect.origin.y + self.cardOffset.y, rect.size.width, rect.size.height);
    
    CGFloat tabWidth = layer.tabViewWidth;
    if (tabWidth > 0.) {
        rect = CGRectMake(rect.origin.x, rect.origin.y, tabWidth, rect.size.height);
    }
    
    BOOL isImageView = layer.fromImageView;
    
    CGFloat height = 0.;
    
    if (!isImageView) {
        if (self.animatedHeight > 0.) {
            height = self.animatedHeight;
        }else {
            if ([TABAnimated sharedAnimated].useGlobalAnimatedHeight) {
                height = [TABAnimated sharedAnimated].animatedHeight;
            }else {
                if (layer.tabViewHeight > 0.) {
                    height = layer.tabViewHeight;
                }else {
                    if (!isImageView) {
                        height = rect.size.height*[TABAnimated sharedAnimated].animatedHeightCoefficient;
                    }
                }
            }
        }
        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width,height);
    }
    
    BOOL isCenterLab = layer.fromCenterLabel;
    if (isCenterLab) {
        rect = CGRectMake((self.frame.size.width - rect.size.width)/2.0, rect.origin.y, rect.size.width, rect.size.height);
    }
    
    return rect;
}

#pragma mark - Getter / Setter

@synthesize animatedColor = _animatedColor;
- (UIColor *)animatedColor {
    if (_animatedColor) {
        return _animatedColor;
    }
    return [TABAnimated sharedAnimated].animatedColor;
}

- (void)setAnimatedColor:(UIColor *)animatedColor {
    _animatedColor = animatedColor;
}

@synthesize animatedBackgroundColor = _animatedBackgroundColor;
- (UIColor *)animatedBackgroundColor {
    if (_animatedBackgroundColor) {
        return _animatedBackgroundColor;
    }
    return [TABAnimated sharedAnimated].animatedBackgroundColor;
}

- (void)setAnimatedBackgroundColor:(UIColor *)animatedBackgroundColor {
    _animatedBackgroundColor = animatedBackgroundColor;
}

@end
