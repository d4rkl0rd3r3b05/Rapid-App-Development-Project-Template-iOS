//
//  AppDelegate.h
//  Movie Quiz
//
//  Created by Mayank on 16/12/14.
//  Copyright (c) 2014 Infoedge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(void)openActiveSessionWithPermissions:(NSArray *)permissions allowLoginUI:(BOOL)allowLoginUI;

@end

