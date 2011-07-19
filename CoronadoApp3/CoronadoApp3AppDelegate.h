//
//  CoronadoApp3AppDelegate.h
//  CoronadoApp3
//
//  Created by Sean OBrien on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoronadoApp3AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
