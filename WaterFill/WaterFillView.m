//
//  WaterFillView.m
//  WaterFillView
//
//  Created by Wang Yandong on 4/21/14.
//  Copyright (c) 2014 wangyandong@outlook.com. All rights reserved.
//

#import "WaterFillView.h"


static const CGFloat amplitude = 10.0;
//static const CGFloat progress = 16;// 目前暂定为
//static const CGFloat kPhaseStep = 0.1;

@interface WaterFillView ()
{
    CADisplayLink *_displayLink;
    CGFloat _phrase;
    CGFloat _y;
}
@property(nonatomic,assign)float kAmplitude;
@property(nonatomic,assign)float kFrequency;
@property(nonatomic,assign)float kPhaseStep;
@property(nonatomic,assign)float kProgress;// 水波上升的高度百分比
/**
 0-100          20%
 101- 1000      40%
 1001 - 10000   60%
 10001 - 50000  80%
 50001-         100%
 */
@end


@implementation WaterFillView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (void) setup
{
    [self startDisplayLinkWithProgress:0.2];
}

- (void) dealloc
{
    [self stopDisplayLink];
}

- (void) startDisplayLink
{
    self.kAmplitude=amplitude;
    self.kFrequency=0.04;
    self.kPhaseStep=0.1;
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    _displayLink.frameInterval = 2;
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}
// 设置水波上升的高度
-(void) startDisplayLinkWithProgress:(float)progress{
    self.kProgress = progress;
    [self startDisplayLink];
}
- (void) stopDisplayLink
{
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void) update:(CADisplayLink *)displayLink
{
    float delta =(1-(fabs(_y)/CGRectGetWidth(self.bounds)));
    _phrase += self.kPhaseStep*delta;
    
    float stopY=CGRectGetWidth(self.bounds)*(1-self.kProgress);//
    
    if (CGRectGetWidth(self.bounds)+_y >=stopY)
    {
        float oneStep =self.kPhaseStep*1.5 ;
        //上升到五分之四的高度需要的steps
        float steps= CGRectGetWidth(self.bounds)*(self.kProgress)/oneStep;
        self.kAmplitude-=(amplitude-2)/steps;
        NSLog(@"self.kam=%f",self.kAmplitude);
        _y -=oneStep ;
    }
    
    [self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect
{
    CGRect bounds = self.bounds;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat halfHeight = CGRectGetWidth(bounds);
    
    UIBezierPath* bezierPath=[UIBezierPath  bezierPathWithRoundedRect:bounds cornerRadius:bounds.size.width/2];
    CGContextAddPath(context, bezierPath.CGPath);
    CGContextClip(context);
    CGContextAddArc(context, bounds.size.width/2, bounds.size.width/2, bounds.size.width/2, 0, M_PI*2, YES);
    
    UIColor *color=  [UIColor colorWithRed:.2 green:.6 blue:.1 alpha:1];
    
    CGContextSetFillColorWithColor(context,  color.CGColor);
    // 画出背景色
    CGContextDrawPath(context, kCGPathFill);
    
    
    
    CGContextSaveGState(context);
    //画第一个水波
    NSUInteger times = (NSUInteger)CGRectGetWidth(bounds);
    CGPoint start;
    
    for (NSUInteger t = 0; t <= times; ++t)
    {
        CGFloat y = (CGFloat)(self.kAmplitude * sin(t * self.kFrequency + _phrase));
        
        if (0 == t)
        {
            CGContextMoveToPoint(context, 0.0, y + halfHeight + _y);
            start = CGPointMake(0, y);
        }
        else
        {
            CGContextAddLineToPoint(context, t, y + halfHeight + _y);
        }
    }
    
    CGContextAddLineToPoint(context, CGRectGetWidth(bounds), CGRectGetHeight(bounds));
    CGContextAddLineToPoint(context, 0, CGRectGetHeight(bounds));
    CGContextAddLineToPoint(context, start.x, start.y);
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.00f green:0.70f blue:1.00f alpha:1.00f].CGColor);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    //画第二个水波
    //NSUInteger times = (NSUInteger)CGRectGetWidth(bounds);
    CGPoint startSecond=CGPointZero;
    for (NSUInteger t = 0; t <= times; ++t)
    {
        CGFloat y = (CGFloat)(self.kAmplitude * sin(t * self.kFrequency+1 + _phrase+2));
        
        if (0 == t)
        {
            CGContextMoveToPoint(context, 0.0, y + halfHeight + _y);
            startSecond = CGPointMake(0, y);
        }
        else
        {
            CGContextAddLineToPoint(context, t, y + halfHeight + _y);
        }
    }
    
    CGContextAddLineToPoint(context, CGRectGetWidth(bounds), CGRectGetHeight(bounds));
    CGContextAddLineToPoint(context, 0, CGRectGetHeight(bounds));
    CGContextAddLineToPoint(context, startSecond.x, startSecond.y);
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.20f green:0.30f blue:1.00f alpha:1.00f].CGColor);
    CGContextFillPath(context);
}
@end
