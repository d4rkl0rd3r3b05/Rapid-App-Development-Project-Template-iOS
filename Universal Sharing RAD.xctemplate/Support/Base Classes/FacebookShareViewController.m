//
//  FacebookShareViewController.m
//  Movie Quiz
//
//  Created by Mayank on 23/01/15.
//  Copyright (c) 2015 Infoedge. All rights reserved.
//

#import "FacebookShareViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "SIAlertView.h"
#import "MBProgressHUD.h"

@interface FacebookShareViewController ()<MBProgressHUDDelegate>
{
    MBProgressHUD *hud;
    
    NSString *postingStartLabelText;
    NSString *postingStartDetailLabelText;
    NSString *postTitle;
    NSString *postType;
    NSString *postDescription;
    NSString *postObject;
    NSString *postAction;
    NSString *postingFinishedLabelText;
    NSString *postingErrorAlertText;
}
@end

@implementation FacebookShareViewController

-(id)initWithPostingStartLabelText:(NSString *)argPostingStartLabelText
       postingStartDetailLabelText:(NSString *)argPostingStartDetailLabelText
                     postImageName:(NSString *)argPostImageName
                         postTitle:(NSString *)argPostTitle
                          postType:(NSString *)argPostType
                   postDescription:(NSString *)argPostDescription
                        postObject:(NSString *)argPostObject
                        postAction:(NSString *)argPostAction
          postingFinishedLabelText:(NSString *)argPostingFinishedLabelText
             postingErrorAlertText:(NSString *)argPostingErrorAlertText
{
    postingStartLabelText =  argPostingStartLabelText;
    postingStartDetailLabelText = argPostingStartDetailLabelText;
    self.postImageName = argPostImageName;
    postTitle = argPostTitle;
    postType = argPostType;
    postDescription = argPostDescription;
    postObject = argPostObject;
    postAction = argPostAction;
    postingFinishedLabelText = argPostingFinishedLabelText;
    postingErrorAlertText = argPostingErrorAlertText;

    return [super init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFBSessionStateChangeWithNotification:) name:@"SessionStateChangeNotification" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    hud = nil;
}

- (IBAction)shareOnFacebook:(id)sender {
    if ([FBSession activeSession].state != FBSessionStateOpen &&
        [FBSession activeSession].state != FBSessionStateOpenTokenExtended) {
            [APP_DELEGATE openActiveSessionWithPermissions:@[@"public_profile", @"publish_actions"] allowLoginUI:YES];
    }else{
        [self stageImageForPosting];
    }
}

-(void)handleFBSessionStateChangeWithNotification:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    
    FBSessionState sessionState = [[userInfo objectForKey:@"state"] integerValue];
    NSError *error = [userInfo objectForKey:@"error"];
    
    if (error || (sessionState == FBSessionStateClosed || sessionState == FBSessionStateClosedLoginFailed)) {
        [self displaySharingErrorAlert];
    }else{
        [self stageImageForPosting];
    }
}

- (void)stageImageForPosting
{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = postingStartLabelText;
    hud.detailsLabelText = postingStartDetailLabelText;

    // stage an image
    [FBRequestConnection startForUploadStagingResourceWithImage:(self.postImage?self.postImage:[UIImage imageNamed:self.postImageName]) completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error) {
            [self postOpenGraphObject:[self createOpenGraphObject:result]];
        } else {
            [self displaySharingErrorAlert];
        }
    }];
}

-(NSMutableDictionary<FBOpenGraphObject> *)createOpenGraphObject:(id) result
{
    NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
    
    // specify that this Open Graph object will be posted to Facebook
    object.provisionedForPost = YES;
    
    object[@"title"] = postTitle;
    object[@"type"] = postType;
    object[@"description"] = postDescription;
    object[@"image"] = @[@{@"url": [result objectForKey:@"uri"], @"user_generated" : @"false" }];
    
    return object;
}

-(void)postOpenGraphObject:(NSMutableDictionary<FBOpenGraphObject> *)graphObject
{
    // Post custom object
    [FBRequestConnection startForPostOpenGraphObject:graphObject completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error) {
            NSString *objectId = [result objectForKey:@"id"];
            
            // create an Open Graph action
            id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
            [action setObject:objectId forKey:postObject];
            [action setObject:@"true" forKey:@"fb:explicitly_shared"];
            
            // create action referencing user owned object
            [FBRequestConnection startForPostWithGraphPath:postAction graphObject:action completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if(!error) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    hud = nil;
                    
                    hud = [[MBProgressHUD alloc] initWithView:self.view];
                    [self.view addSubview:hud];
                    
                    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]];
                    
                    // Set custom view mode
                    hud.mode = MBProgressHUDModeCustomView;
                    
                    hud.delegate = self;
                    hud.labelText = postingFinishedLabelText;
                    
                    [hud show:YES];
                    [hud hide:YES afterDelay:3];
                    
                    if ([postType isEqualToString:@"ultimatemoviequiz:movie_quiz"]) {
                        [Utility increaseTotalScoreForUser:kCREDITS_EARNED_BY_FACEBOOK_SHARING];
                    }
                    
                } else {
                    [self displaySharingErrorAlert];
                }
            }];
            
        } else {
            [self displaySharingErrorAlert];
        }
    }];
}

-(void)displaySharingErrorAlert
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    hud = nil;
    
    SIAlertView *sharingErrorAlert = [[SIAlertView alloc] initWithTitle:postingErrorAlertText andMessage:@"Please retry with proper internet connection."];
    
    [sharingErrorAlert addButtonWithTitle:@"Ok"
                                     type:SIAlertViewButtonTypeDestructive
                                  handler:^(SIAlertView *alert) {
                                      [alert dismissAnimated:YES];
                                  }];
    
    sharingErrorAlert.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [sharingErrorAlert show];
    
    sharingErrorAlert = nil;
}

- (void)hudWasHidden:(MBProgressHUD *)argHud
{
    hud = nil;
}

@end
