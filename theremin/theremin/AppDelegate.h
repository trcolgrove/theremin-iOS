//
//  AppDelegate.h
//  theremin
//
//  Created by McCall Bliss on 2/1/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdAudioController.h"
#import "PdDispatcher.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) PdAudioController *audioController;

@end
