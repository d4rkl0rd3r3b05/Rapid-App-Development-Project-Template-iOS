//
//  CategoryViewController.m
//  Movie Quiz
//
//  Created by Mayank on 17/12/14.
//  Copyright (c) 2014 Infoedge. All rights reserved.
//

#import "CategoryViewController.h"
#import "QuestionViewController.h"
#import <AdColony/AdColony.h>
#import "SIAlertView.h"

@interface CategoryViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>
{
    LeadboltOverlay *bottomBannerAd;
}

@property (weak, nonatomic) IBOutlet UICollectionView *categoryCollectionView;

@end


@implementation CategoryViewController

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
    
    //Bottom Banner Ad
    bottomBannerAd = [LeadboltOverlay createAdWithSectionid:@"547140084" view:[[UIApplication sharedApplication] delegate].window];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
  
    UIButton *earnNavButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [earnNavButton setImage:[UIImage imageNamed:@"coins"] forState:UIControlStateNormal];
    earnNavButton.imageEdgeInsets = UIEdgeInsetsMake(25, 15, 40, 15);
    
    [earnNavButton addTarget:self action:@selector(earnButtonClicked)forControlEvents:UIControlEventTouchUpInside];
    [earnNavButton setFrame:CGRectMake(0, 0, 55, 90)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(3, 48, 50, 20)];
    [label setFont:[UIFont boldSystemFontOfSize:11]];
    [label setText:[NSString stringWithFormat:@"%d",[Utility totalScoreForUser]]];
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor:[UIColor redColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [earnNavButton addSubview:label];
    [earnNavButton setBackgroundImage:[UIImage imageNamed:@"hintsAvailable"] forState:UIControlStateNormal];
    UIBarButtonItem *creditbarButton = [[UIBarButtonItem alloc] initWithCustomView:earnNavButton];
    
    
    
    UIButton *resetButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    
    [resetButton addTarget:self action:@selector(resetButtonClicked:)forControlEvents:UIControlEventTouchUpInside];
    [resetButton setFrame:CGRectMake(0, 0, 40, 40)];
    [resetButton setBackgroundImage:[UIImage imageNamed:@"reset"] forState:UIControlStateNormal];
    UIBarButtonItem *resetBarButton = [[UIBarButtonItem alloc] initWithCustomView:resetButton];
    
    self.navigationItem.rightBarButtonItems = @[creditbarButton,resetBarButton];
    
//    self.navigationItem.rightBarButtonItem = barButton;
    
    earnNavButton = nil;
    label =  nil;
    creditbarButton = nil;
    resetBarButton = nil;
    resetButton = nil;
    
    
    [bottomBannerAd loadAd];
}

-(void)resetButtonClicked:(id)sender
{
    SIAlertView *resetAlert = [[SIAlertView alloc] initWithTitle:nil andMessage:@"Are you sure you want to reset."];
    
    [resetAlert addButtonWithTitle:@"Cancel"
                                      type:SIAlertViewButtonTypeCancel
                                   handler:^(SIAlertView *alert) {
                                       [alert dismissAnimated:YES];
                                   }];
    [resetAlert addButtonWithTitle:@"Reset"
                                      type:SIAlertViewButtonTypeDestructive
                                   handler:^(SIAlertView *alert) {
                                       [alert dismissAnimated:YES];

                                       [Utility resetProgress];
                                   }];
    
    resetAlert.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [resetAlert show];
    
    resetAlert = nil;
}

-(void)earnButtonClicked
{
    SIAlertView *earnCreditsAlert = [[SIAlertView alloc] initWithTitle:@"Earn Credits" andMessage:nil];
    
    [earnCreditsAlert addButtonWithTitle:@"Watch Video"
                                    type:SIAlertViewButtonTypeCancel
                                 handler:^(SIAlertView *alert) {
                                     [alert dismissAnimated:YES];
                                     
                                     [AdColony playVideoAdForZone:@"vz1eb2539adedf47b5ae" withDelegate:nil];
                                     [Utility increaseTotalScoreForUser:kCREDITS_EARNED_BY_VIDEO_AD];
                                 }];
    
    [earnCreditsAlert addButtonWithTitle:@"Share App on Facebook"
                                    type:SIAlertViewButtonTypeCancel
                                 handler:^(SIAlertView *alert) {
                                     [alert dismissAnimated:YES];
                                     
                                     [self shareOnFacebook:nil];
                                 }];
    [earnCreditsAlert addButtonWithTitle:@"Cancel"
                                    type:SIAlertViewButtonTypeDestructive
                                 handler:^(SIAlertView *alert) {
                                     [alert dismissAnimated:YES];
                                 }];
    
    
    earnCreditsAlert.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [earnCreditsAlert show];
    
    earnCreditsAlert = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [bottomBannerAd destroyAd];
    
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

#pragma  mark - Collection View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *categoryCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CATEGORY_CELL" forIndexPath:indexPath];
    
    NSString *categoryImage;
    switch (indexPath.row + 1) {
        case kVillain:
            categoryImage = @"villains";
            break;
        case kGroup:
            categoryImage = @"grouped";
            break;
        case kCharacter:
            categoryImage = @"character";
            break;
        case kSingle:
            categoryImage = @"single";
            break;
        default:
            break;
    }
    
    
    [(UIImageView *)[categoryCell viewWithTag:10] setImage:[UIImage imageNamed:categoryImage]];
    
    categoryCell.tag= indexPath.row + 1;
    
    return categoryCell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:QuestionViewController.class]) {
        ((QuestionViewController *)segue.destinationViewController).categoryType = ((UIView *)sender).tag;
    }
}

@end
