//
//  ViewController.m
//  theremin
//
//  Created by McCall Bliss on 2/1/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

+ (void)initialize {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonClicked:(id)sender {
    NSLog(@"Button pressed: %@", [sender currentTitle]);
    //instvc.key = "ChangedKey"
}

@end
