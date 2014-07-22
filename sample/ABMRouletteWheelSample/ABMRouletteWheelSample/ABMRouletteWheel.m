//
//  ABMRouletteWheel.m
//  RestaurantRoulette
//
//  Created by Abdul Basit on 28/06/2014.
//  Copyright (c) 2014 Gaditek. All rights reserved.
//

#import "ABMRouletteWheel.h"


@interface ABMRouletteWheel (Private)

-(void) startDisplayTimer;
-(void) stopDisplayTimer;
-(void) startBallAnimation;
-(void) rotateWheel:(id) sender;
-(void) setWheelAngle:(CGFloat) wheelAngle;
-(CGPoint) getOriginPoint;
-(void) stopRouletteWheel;
-(void) setResultantBallImage:(int) slotNumber;

@end



@implementation ABMRouletteWheel

@synthesize delegate;

#pragma -
#pragma Initialize

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _frame = frame;
    }
    return self;
}

#pragma mark -
#pragma mark Dealloc

-(void) dealloc
{
    [_staticWoodImage release];
    _staticWoodImage = nil;
    
    [_wheelImage release];
    _wheelImage = nil;
    
    [_ballImage release];
    _ballImage = nil;
    
    [_resultantBallImage release];
    _resultantBallImage = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Origin Point

-(CGPoint) getOriginPoint
{
    return CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

#pragma -
#pragma Static wood image

-(void)setStaticWoodImage:(NSString *)staticWoodImageName
{
    if(_staticWoodImage != nil)
    {
        [_staticWoodImage release];
        _staticWoodImage = nil;
    }
    _staticWoodImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:staticWoodImageName]];
    [_staticWoodImage setFrame:CGRectMake(0, 0, _frame.size.width, _frame.size.height)];
    
    [self addSubview: _staticWoodImage];
}

#pragma -
#pragma Wheel Image

-(void) setWheelImage:(NSString*) wheelImageName withRadius:(CGFloat) radius
{
    _wheelRadius = radius;
    
    if(_wheelImage != nil)
    {
        [_wheelImage release];
        _wheelImage = nil;
    }
    _wheelImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:wheelImageName]];
    
    CGPoint originPoint = [self getOriginPoint];
    
    // put it at origin
    [_wheelImage setFrame:CGRectMake(originPoint.x - _wheelRadius,
                                     originPoint.y - _wheelRadius,
                                     _wheelRadius*2,
                                     _wheelRadius*2)];
    [self addSubview: _wheelImage];
}

#pragma -
#pragma Ball Image


-(void) setBallImage:(NSString *)ballImageName withRadius:(CGFloat)ballRadius
{
    _ballRadius = ballRadius;
    
    if(_ballImage != nil)
    {
        [_ballImage release];
        _ballImage = nil;
    }
    _ballImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:ballImageName]];
    [_ballImage setHidden: YES];
    [self addSubview: _ballImage];
    
    // set resultant ball image
    
    _resultantBallImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:ballImageName]];
    [_resultantBallImage setFrame:CGRectMake(0, 0, 10, 10)];
}

#pragma mark -
#pragma mark Timer


-(void) startDisplayTimer
{
    displayLoopHandler = [CADisplayLink displayLinkWithTarget:self selector:@selector(rotateWheel:)];
    [displayLoopHandler addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

-(void) stopDisplayTimer
{
    if(displayLoopHandler != nil)
    {
        [displayLoopHandler invalidate];
        displayLoopHandler = nil;
    }
}

#pragma mark -
#pragma mark Start Rotating Wheel animation Code

-(void) rotateWheel:(id) sender
{
    if(_isWheelRotating == YES)
    {
        NSDate * newDate = [NSDate date];
        NSTimeInterval passed = [newDate timeIntervalSinceDate: _lastWheelRotationDate];
        
        double angleReduction = self.friction * passed * ABS(_wheelAngularVelocity);
        if (_wheelAngularVelocity < 0) {
            _wheelAngularVelocity += angleReduction;
            if (_wheelAngularVelocity > 0)
                _wheelAngularVelocity = 0;
            
        } else if (_wheelAngularVelocity > 0) {
            _wheelAngularVelocity -= angleReduction;
            if (_wheelAngularVelocity < 0)
                _wheelAngularVelocity = 0;
        }
        
        if (ABS(_wheelAngularVelocity) < 0.01) _wheelAngularVelocity = 0;
        
        
        double useAngle = _wheelAngle;
        useAngle += _wheelAngularVelocity * passed;
        // limit useAngle to +/- 2*PI
        if (useAngle < 0) {
            while (useAngle < -2 * M_PI) {
                useAngle += 2 * M_PI;
            }
        } else {
            while (useAngle > 2 * M_PI) {
                useAngle -= 2 * M_PI;
            }
        }
        
        [self setWheelAngle: useAngle];
        
        [self setLastWheelRotationTime: newDate];
        
        if(_wheelAngularVelocity == 0)
        {
            [self stopRouletteWheel];
        }

    }
    else{
        // invalidate display loop
        [self stopDisplayTimer];
    }
}

-(void) setLastWheelRotationTime:(NSDate*)date
{
    if(_lastWheelRotationDate != nil)
    {
        [_lastWheelRotationDate release];
        _lastWheelRotationDate = nil;
    }
    
    if(date != nil)
        _lastWheelRotationDate = [date retain];
}

-(void) startRotatingWheel
{
    if(_isWheelRotating == NO)
    {
        DEBUG_LOG(@"Wheel --> Animation Started");
        
        _isWheelRotating = YES;
        
        // reset starting angular velocity of wheel
        _wheelAngularVelocity = WHEEL_ANGULAR_VELOCITY;
        
        // store last date of roulette wheel
        [self setLastWheelRotationTime: [NSDate date]];
        
        // generate random slot number
        _randomSlotNumber = arc4random() % TOTAL_NUMBER_OF_SLOTS_ON_WHEEL;
        DEBUG_LOG(@"Random slot --> %d", _randomSlotNumber);

        /// reset angle of wheel
        [self setWheelAngle: 0.0];
        
        // set resultnat ball position
        [self setResultantBallImage: _randomSlotNumber];
        
        // intialize timer
        [self startDisplayTimer];
        
        // intialize ball animation
        [self startBallAnimation];
        
        if([delegate respondsToSelector:@selector(didRouletteWheelStart)])
        {
            [delegate didRouletteWheelStart];
        }
    }
}

-(void) stopRouletteWheel
{
    DEBUG_LOG(@"Wheel --> Animation Stopped");
    
    [self stopDisplayTimer];
    
    _isWheelRotating = NO;
    
    if([delegate respondsToSelector:@selector(didRouletteWheelStop:)])
    {
        [delegate didRouletteWheelStop: _randomSlotNumber];
    }
}

#pragma mark -
#pragma mark Wheel Angle

-(void) setWheelAngle:(CGFloat)wheelAngle
{
    _wheelAngle = wheelAngle;
    [[_wheelImage layer] setTransform:CATransform3DMakeRotation(_wheelAngle, 0, 0, 1)];
}

#pragma mark -
#pragma mark Ball Animation

-(void)setResultantBallImage:(int)slotNumber
{
    [_resultantBallImage setFrame:CGRectMake(cos(degreeToRadian(slotNumber*360/TOTAL_NUMBER_OF_SLOTS_ON_WHEEL))*80.0 +110 - 10/2,
                                            sin(degreeToRadian(slotNumber*360/TOTAL_NUMBER_OF_SLOTS_ON_WHEEL))*80.0 +110 - 10/2,
                                            _resultantBallImage.frame.size.width,
                                            _resultantBallImage.frame.size.height)];
    [_resultantBallImage setHidden: YES];
    [_wheelImage addSubview: _resultantBallImage];
}

-(void) startBallAnimation
{
    DEBUG_LOG(@"Ball --> Animation Started");
    
    // get roulette wheel origii
    CGPoint origin = [self getOriginPoint];
    
    // place ball at middle right corner
    [_ballImage setFrame:CGRectMake(origin.x - (_ballImage.frame.size.width/2) + _ballRadius,
                                    origin.y - (_ballImage.frame.size.height/2),
                                    _ballImage.frame.size.width,
                                    _ballImage.frame.size.height)];
    [_ballImage setHidden:NO];
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [pathAnimation setDelegate:self];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = TRUE;
    pathAnimation.repeatCount = 1;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.duration = 4;
    
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    
    // apply transformation
    CGPathAddArc(curvedPath, NULL, origin.x, origin.y, _ballRadius, degreeToRadian(0), degreeToRadian(360), YES);
    CGPathAddArc(curvedPath, NULL, origin.x, origin.y, _ballRadius, degreeToRadian(0), degreeToRadian(360), YES);
    CGPathAddArc(curvedPath, NULL, origin.x, origin.y, _ballRadius, degreeToRadian(0), degreeToRadian(360), YES);
    
    // add curve path
    UIBezierPath *curve = [UIBezierPath bezierPath];
    
    CGPoint startPoint = CGPointMake(origin.x - (_ballImage.frame.size.width/2) + _ballRadius, origin.y - (_ballImage.frame.size.height/2));
    
    CGPoint endPoint = CGPointMake(origin.x - (_ballImage.frame.size.width/2),
                                   origin.y - (_ballImage.frame.size.height/2) +100);
    
    
    [curve moveToPoint:startPoint];
    
    CGPoint c1 = CGPointMake(startPoint.x -120, startPoint.y -250);
    CGPoint c2 = CGPointMake(endPoint.x -200, endPoint.y -50);
    
    // Draw a curve towards the end, using control points
    [curve addCurveToPoint:endPoint controlPoint1:c1 controlPoint2:c2];

    CGPathAddPath(curvedPath, nil, curve.CGPath);
    
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    
    [_ballImage.layer addAnimation:pathAnimation forKey:@"myCircleAnimation"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if(flag)
    {
        // remove ball from top view
        [_ballImage.layer removeAllAnimations];
        [_ballImage setHidden: YES];
        
        [_resultantBallImage setHidden: NO];
    }
}

/*
-(void) initializedRotatingTimer
{
    
}

-(void) rotateWheel:(id) sender
{
    if(isWheelRotating == YES)
    {
        NSDate * newDate = [NSDate date];
        NSTimeInterval passed = [newDate timeIntervalSinceDate:startWheelRotationDate];
        
        double angleReduction = self.friction * passed * ABS(wheelAngularVelocity);
        if (wheelAngularVelocity < 0) {
            wheelAngularVelocity += angleReduction;
            if (wheelAngularVelocity > 0)
                wheelAngularVelocity = 0;
            
        } else if (wheelAngularVelocity > 0) {
            wheelAngularVelocity -= angleReduction;
            if (wheelAngularVelocity < 0)
                wheelAngularVelocity = 0;
        }
        
        if (ABS(wheelAngularVelocity) < 0.01) wheelAngularVelocity = 0;
        
        
        double useAngle = wheelAngle;
        useAngle += wheelAngularVelocity * passed;
        // limit useAngle to +/- 2*PI
        if (useAngle < 0) {
            while (useAngle < -2 * M_PI) {
                useAngle += 2 * M_PI;
            }
        } else {
            while (useAngle > 2 * M_PI) {
                useAngle -= 2 * M_PI;
            }
        }
        
        [self setWheelAngle: useAngle];

        startWheelRotationDate = [newDate retain];
        
        if(wheelAngularVelocity == 0)
        {
            [self stopRotatingWheel];
        }
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if(flag)
    {
        // remove ball from top view
        [ballImage.layer removeAllAnimations];
        [ballImage removeFromSuperview];
        
        [resultantBalls[_randomNumber] setHidden:NO];
    }
}

-(void) startRotatingWheel
{
    isWheelRotating = YES;
    startWheelRotationDate = [NSDate date];
    
    wheelAngularVelocity = 500;
    [self setWheelAngle: 0.0];
    
    // generate random number on start
    _randomNumber = arc4random()%38;
    
    // start display loop
    displayLoopHandler = [CADisplayLink displayLinkWithTarget:self selector:@selector(rotateWheel:)];
    [displayLoopHandler addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    [self startBallMovement];
}

-(void) startBallMovement
{
    // reset ball position
    [ballImage setFrame:CGRectMake(self.frame.size.width - ballImage.frame.size.width/2 -25, self.frame.size.height/2, 15, 15)];
    [self addSubview: ballImage];
    
    // animation for ball
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [pathAnimation setDelegate:self];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = TRUE;
    pathAnimation.repeatCount = 1;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.duration = 4;
    
    CGMutablePathRef curvedPath = CGPathCreateMutable();

    // create a circle from this square, it could be the frame of an UIView
    // add circle path
    
    // apply transformation
    CGPathAddArc(curvedPath, NULL, self.frame.size.width/2, self.frame.size.height/2, self.frame.size.width/2 - 25, degreeToRadian(0), degreeToRadian(360), YES);
    CGPathAddArc(curvedPath, NULL, self.frame.size.width/2, self.frame.size.height/2, self.frame.size.width/2 - 25, degreeToRadian(0), degreeToRadian(360), YES);
    CGPathAddArc(curvedPath, NULL, self.frame.size.width/2, self.frame.size.height/2, self.frame.size.width/2 - 25, degreeToRadian(0), degreeToRadian(360), YES);
    
    // add curve path
    UIBezierPath *curve = [UIBezierPath bezierPath];
    
    CGPoint startPoint = CGPointMake(self.frame.size.width - ballImage.frame.size.width/2 -25, self.frame.size.height/2);
    
    CGPoint endPoint = CGPointMake(self.frame.size.width/2,self.frame.size.height - 70);
    
    
    [curve moveToPoint:startPoint];
    
    CGPoint c1 = CGPointMake(startPoint.x -120, startPoint.y -250);
    CGPoint c2 = CGPointMake(endPoint.x -200, endPoint.y -50);
    
    // Draw a curve towards the end, using control points
    [curve addCurveToPoint:endPoint controlPoint1:c1 controlPoint2:c2];
    
    
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path          = curve.CGPath;
    layer.strokeColor   = [UIColor whiteColor].CGColor;
    layer.lineWidth     = 1.0;
    layer.fillColor     = nil;
    
//    [self.layer addSublayer:layer];
    
    CGPathAddPath(curvedPath, nil, curve.CGPath);
    
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    
    [ballImage.layer addAnimation:pathAnimation forKey:@"myCircleAnimation"];
}

-(void) setWheelAngle:(double) angle
{
    wheelAngle = angle;
    [[wheelImage layer] setTransform:CATransform3DMakeRotation(angle, 0, 0, 1)];
}

-(void) stopRotatingWheel
{
    if (!displayLoopHandler) return;
    [displayLoopHandler invalidate];
    displayLoopHandler = nil;
    
    isWheelRotating = NO;
}
 */

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
