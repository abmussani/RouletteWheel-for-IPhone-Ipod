//
//  ViewController.m
//  ABMRouletteWheelSample
//
//  Created by Abdul Basit on 29/06/2014.
//  Copyright (c) 2014 Abdul Basit. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    [self showSpinButton];
    [self showRouletteWheel];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showRouletteWheel
{
    _rouletteWheel = [[ABMRouletteWheel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 298/2, 50, 298, 298)];
    [_rouletteWheel setFriction: 1.5];
    [_rouletteWheel setStaticWoodImage:@"roulette-vc-roulette-bg"];
    [_rouletteWheel setWheelImage:@"roulette_wheel_image" withRadius:110];
    [_rouletteWheel setBallImage:@"small_ball" withRadius:123];
    
    [self.view addSubview: _rouletteWheel];
}

-(void) showSpinButton
{
    UIButton *spinbutton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [spinbutton setFrame:CGRectMake(self.view.frame.size.width/2 - 60, self.view.frame.size.height -100, 120, 30)];
    [spinbutton setTitle:@"Spin the wheel" forState:UIControlStateNormal];
    [spinbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [spinbutton addTarget:self action:@selector(onReleaseSpinButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview: spinbutton];
    
}

-(void) onReleaseSpinButton
{
    if(_rouletteWheel.isWheelRotating == NO)
    {
        [_rouletteWheel startRotatingWheel];
    }
}

@end
