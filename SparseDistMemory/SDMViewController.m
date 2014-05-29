//
//  SDMViewController.m
//  SparseDistMemory
//
//  Created by Jon Como on 5/29/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "SDMViewController.h"

@import QuartzCore;

#import "SDMNetwork.h"

@interface SDMViewController ()
{
    SDMNetwork *network;
    int maxTime;
    
    UIImageView *output;
    
    UIButton *stepTime;
    UISlider *timeSlider;
    
    SDMNeuron *neuronDrawing;
    BOOL isErasing;
}

@end

@implementation SDMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    output = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    output.layer.magnificationFilter = kCAFilterNearest;
    [self.view addSubview:output];
    
    stepTime = [UIButton buttonWithType:UIButtonTypeSystem];
    [stepTime setTitle:@"Step Time" forState:UIControlStateNormal];
    stepTime.frame = CGRectMake(0, self.view.frame.size.width, 160, 44);
    [self.view addSubview:stepTime];
    [stepTime addTarget:self action:@selector(stepTime) forControlEvents:UIControlEventTouchUpInside];
    
    timeSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 320 + 44, 320-40, 44)];
    [timeSlider addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:timeSlider];
    
    network = [[SDMNetwork alloc] initWithSize:SDMSizeMake(16 * 16, 16)];
    network.showsPredictions = YES;
    maxTime = 16;
    
    [self render];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)stepTime
{
    [network processState];
    
    [self render];
}

-(void)timeChanged:(UISlider *)slider
{
    int time = round(slider.value * maxTime);
    
    if (network.time != time)
    {
        network.time = time;
        
        [self render];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self.view];
    
    SDMNeuron *neuron = [self neuronAtLocation:location];
    isErasing = neuron.isActive;
    
    [self touchedLocation:location];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self.view];
    
    [self touchedLocation:location];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    neuronDrawing = nil;
}

-(void)touchedLocation:(CGPoint)location
{
    SDMNeuron *neuron = [self neuronAtLocation:location];
    
    if (neuronDrawing != neuron)
    {
        neuronDrawing = neuron;
        
        if (isErasing){
            neuron.isActive = NO;
        }else{
            neuron.isActive = YES;
        }
    }
    
    [self render];
}

-(SDMNeuron *)neuronAtLocation:(CGPoint)location
{
    int sideLength = sqrt(network.size.length);
    
    //convert to index
    int x = (int)(location.x / self.view.frame.size.width * sideLength);
    int y = (int)(location.y / self.view.frame.size.width * sideLength);
    
    int index = x + y * sideLength;
    return [network neuronAtLevel:0 index:index];
}

-(void)render
{
    [UIView performWithoutAnimation:^{
        [stepTime setTitle:[NSString stringWithFormat:@"StepTime (%i)", network.time] forState:UIControlStateNormal];
    }];
    
    output.image = [network imageFromLevel:0];
    float ratio = network.time / (float)maxTime;
    [timeSlider setValue:ratio animated:YES];
}

@end
