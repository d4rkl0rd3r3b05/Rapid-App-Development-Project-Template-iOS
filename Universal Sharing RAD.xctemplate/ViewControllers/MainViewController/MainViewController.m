//
//  MainViewController.m
//  Movie Quiz
//
//  Created by Mayank on 16/12/14.
//  Copyright (c) 2014 Infoedge. All rights reserved.
//

#import "MainViewController.h"
#import "CategoryViewController.h"

@interface MainViewController ()<UIGestureRecognizerDelegate>

@end


@implementation MainViewController


- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithPostingStartLabelText:@"Wait"
                    postingStartDetailLabelText:@"Connecting to facebook"
                                  postImageName:@"movie_quiz_app"
                                      postTitle:@"Guess the movies with ULTIMATE movie Quiz(Free)!"
                                       postType:@"ultimatemoviequiz:movie_quiz"
                                postDescription:@"Ultimate movie Quiz is a free game full of fun that consists on guessing the names of hundreds of bollywood movies."
                                     postObject:@"movie_quiz"
                                     postAction:@"/me/ultimatemoviequiz:play"
                       postingFinishedLabelText:@"Successfully shared."
                          postingErrorAlertText:@"Unable to share"];
    self.postImage = nil;
    
    if(self = [super initWithCoder:aDecoder])
    {
        // Do something
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

    [self.navigationController setNavigationBarHidden:NO];
    
    // Disable iOS 7 back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:CategoryViewController.class]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (IBAction)rateApp:(id)sender {
    NSString *urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",@"959394907"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    [Utility increaseTotalScoreForUser:kCREDITS_EARNED_BY_RATING];
}

@end
