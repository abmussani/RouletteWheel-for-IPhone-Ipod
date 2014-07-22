//
//  ABMRouletteWheel.h
//  RestaurantRoulette
//
//  Created by Abdul Basit on 28/06/2014.
//  Copyright (c) 2014 Gaditek. All rights reserved.
//

#import <UIKit/UIKit.h>



#ifdef DEBUG
    #define DEBUG_LOG(...) NSLog(__VA_ARGS__)
#else
    #define DEBUG_LOG(...)
#endif

#define WHEEL_NUMBER_RADIUS    0
#define TOTAL_NUMBER_OF_SLOTS_ON_WHEEL 38
#define WHEEL_ANGULAR_VELOCITY 500
#define degreeToRadian(_degree) (_degree * M_PI/180)
#define radianToDegree(_radian) (_radian * 180/M_PI)


@protocol ABMRouletteWheelDelegate <NSObject>

-(void) didRouletteWheelStart;
-(void) didRouletteWheelStop:(CGFloat) number;

@end

@interface ABMRouletteWheel : UIView
{
    CGRect _frame;
    CGFloat _ballRadius;
    CGFloat _wheelRadius;
    UIImageView *_staticWoodImage;
    UIImageView *_wheelImage;
    UIImageView *_ballImage;
    UIImageView *_resultantBallImage;
    
    CGFloat _wheelAngle;
    CGFloat _wheelAngularVelocity;
    
    
    NSDate *_lastWheelRotationDate;
    
    id<ABMRouletteWheelDelegate> delegate;
    int _randomSlotNumber;
    
    CADisplayLink *displayLoopHandler;
}

@property (nonatomic, readonly) BOOL isWheelRotating;
@property (nonatomic, assign) long friction;
@property (nonatomic, assign) id<ABMRouletteWheelDelegate> delegate;


/* set frame of control */
-(id)initWithFrame:(CGRect) frame;

/* set image of static wooden piece. It will be a static image on which ball will rotate for first three time */
-(void) setStaticWoodImage:(NSString*) staticWoodImageName;

/* set image of wheel. This will part will rotate as roulette wheel begin to rotate */
-(void) setWheelImage:(NSString*) wheelImageName withRadius:(CGFloat) radius;

/* set image of ball. Radius will define at what distance from origin, ball should make a circle */
-(void) setBallImage:(NSString*) ballImageName withRadius:(CGFloat) ballRadius;

/* Begin rotation of roulette wheel*/
-(void) startRotatingWheel;



@end
