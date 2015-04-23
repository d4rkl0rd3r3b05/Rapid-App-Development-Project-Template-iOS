//
//  QuestionViewController.m
//  Movie Quiz
//
//  Created by Mayank on 17/12/14.
//  Copyright (c) 2014 Infoedge. All rights reserved.
//

#import "QuestionViewController.h"
#import <AdColony/AdColony.h>
#import <objc/runtime.h>
#import "SIAlertView.h"


@interface QuestionViewController()<UIGestureRecognizerDelegate>
{
    NSArray *movies;
    
    NSMutableString *userAnswer;
    NSString *correctAnswer;
    
    NSMutableString *filledCharacterString;
    
    int userAnswerOffset;
    
    LeadboltOverlay *topBannerAd;
    LeadboltOverlay *bottomBannerAd;
    LeadboltOverlay *interstitialAd;
    
    BOOL hasStateBeenSavedForCurrentMovieType;
    BOOL hasHintBeenSavedForCurrentMovieType;
    BOOL hasFillCharacterSavedForCurrentMovieType;
}

@property (weak, nonatomic) IBOutlet UIImageView *movieImage;
@property (weak, nonatomic) IBOutlet UIView *groupImageView;
@property (weak, nonatomic) IBOutlet UIView *movieNameVew;
@property (weak, nonatomic) IBOutlet UIView *optionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *optionViewBottomMargin;
@property (weak, nonatomic) IBOutlet UIView *movieOptionsView;
@property (weak, nonatomic) IBOutlet UIButton *fillMovieCharButton;
@property (weak, nonatomic) IBOutlet UIButton *showMovieOptionsButton;

@end

static int levelIndex;
static char const * const movieButtonValue = "MOVIE_BUTTON_VALUE";


@implementation QuestionViewController

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithPostingStartLabelText:@"Wait"
                    postingStartDetailLabelText:@"Connecting to facebook"
                                  postImageName:nil
                                      postTitle:@"Can you guess this movie?"
                                       postType:@"video.movie"
                                postDescription:@"Try the ULTIMATE MOVIE QUIZ(FREE) game on appstore."
                                     postObject:@"movie"
                                     postAction:@"/me/ultimatemoviequiz:ask"
                       postingFinishedLabelText:@"Successfully posted."
                          postingErrorAlertText:@"Unable to post"];
    
    if(self = [super initWithCoder:aDecoder])
    {
        // Do something
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    hasStateBeenSavedForCurrentMovieType = [Utility isStateSavedForMovieType:self.categoryType];
    hasHintBeenSavedForCurrentMovieType = [Utility isHintSavedForMovieType:self.categoryType];
    hasFillCharacterSavedForCurrentMovieType = [Utility isFillCharacterSavedForMovieType:self.categoryType];
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        if (self.view.frame.size.height > 480) {
            self.optionViewBottomMargin.constant = 61;
        }else{
            self.optionViewBottomMargin.constant = 5;
        }
    }
    
    movies = [DBHelper moviesForType:self.categoryType];
    
    if (self.categoryType == kGroup) {
        self.groupImageView.hidden = NO;
        self.movieImage.hidden = YES;
    }else{
        self.groupImageView.hidden = YES;
        self.movieImage.hidden = NO;
    }
    
    //Setting levelIndex as -1 for initiating value fill logic a common nextButtonClicked method
    levelIndex = -1;
    
    [self nextButtonClicked:YES];
    [self initializeMovieOptionsWithPreset:YES];
    [self initializeMovieNameWithFillCharacterPreset:YES];
    
    //Top Banner Ad
    topBannerAd = [LeadboltOverlay createAdWithSectionid:@"735418131" view:[[UIApplication sharedApplication] delegate].window];
    
    //Bottom Banner Ad
    bottomBannerAd = [LeadboltOverlay createAdWithSectionid:@"547140084" view:[[UIApplication sharedApplication] delegate].window];
    
    //Interstitial Ad
    interstitialAd = [LeadboltOverlay createAdWithSectionid:@"305520730" view:[[UIApplication sharedApplication] delegate].window];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [topBannerAd loadAd];
    if (self.view.frame.size.height > 480)
    {
        [bottomBannerAd loadAd];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [topBannerAd destroyAd];
    [bottomBannerAd destroyAd];
    [interstitialAd destroyAd];
    
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

- (UIImage *) screenshot
{
    // Define the dimensions of the screenshot you want to take (the entire screen in this case)
    CGSize size =  self.groupImageView.frame.size;
    
    // Create the screenshot
    UIGraphicsBeginImageContext(size);
    
    // Put everything in the current view into the screenshot
    if (self.categoryType == kGroup) {
        [[self.groupImageView layer] renderInContext:UIGraphicsGetCurrentContext()];
    }else{
        [[self.movieImage layer] renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    // Save the current image context info into a UIImage
    UIImage *screenShotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Scale to Facebook post size
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(300, 300), NO, 0.0);
    [screenShotImage drawInRect:CGRectMake(0, 0, 300, 300)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return newImage;
}

- (void)nextButtonClicked:(BOOL) isInitialLoad
{
    if (!isInitialLoad) {
        [Utility markHintSavedForMovieType:self.categoryType savedState:NO];
        hasHintBeenSavedForCurrentMovieType = NO;
    }
    
    
    levelIndex++;
    if (levelIndex >= movies.count) {
        levelIndex = 0;
    }
    
    userAnswer = nil;
    userAnswerOffset = 0;
    self.postImage = nil;
    self.postImageName = nil;
    
    if (self.categoryType == kGroup) {
        for (UIImageView *childImageView in self.groupImageView.subviews) {
            childImageView.image = [UIImage imageNamed:((Movie *)movies[levelIndex]).movieImages[childImageView.tag]];
        }
    }else{
        self.movieImage.image = [UIImage imageNamed:((Movie *)movies[levelIndex]).movieImages[0]];
    }
    
    
    
    for (UIView *previousMovie in self.movieNameVew.subviews) {
        [previousMovie removeFromSuperview];
    }
    for (UIView *previousMovieOption in self.optionView.subviews) {
        [previousMovieOption removeFromSuperview];
    }
    
    
    correctAnswer = [[((Movie *)movies[levelIndex]).answer stringByReplacingOccurrencesOfString:@" " withString:@""] uppercaseString];
    
    [self createMovieNameObjects:((Movie *)movies[levelIndex]).answer];
    [self createOptionObjects:[Utility getIncorrectQuestionString:((Movie *)movies[levelIndex]).answer]];
}

-(void)initializeMovieOptionsWithPreset:(BOOL) isValueToBePreset
{
     NSArray *savedMovieOptions = [[NSUserDefaults standardUserDefaults] objectForKey:savedMovieState(self.categoryType)];
    
    if (!isValueToBePreset || !savedMovieOptions || !hasStateBeenSavedForCurrentMovieType) {
        self.movieOptionsView.hidden = YES;
        self.optionView.hidden = NO;
        self.movieNameVew.hidden = NO;
        self.fillMovieCharButton.enabled = YES;
        self.showMovieOptionsButton.enabled = YES;
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:savedMovieState(self.categoryType)];
        [Utility markStateAsSavedForMovieType:self.categoryType savedState:NO];
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:correctMovieOptionTag(self.categoryType)];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:incorrectMovieOptionTag(self.categoryType)];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        self.movieOptionsView.hidden = NO;
        self.optionView.hidden = YES;
        self.movieNameVew.hidden = YES;
        self.fillMovieCharButton.enabled = NO;
        self.showMovieOptionsButton.enabled = NO;
        
        /*
         *Setting Current Movie Options Value same as the preset value scrambled array so that it can be
         *used while comparing options in Movie Option Clicked later on.
         */
        ((Movie *)movies[levelIndex]).movieOptions = nil;
        ((Movie *)movies[levelIndex]).movieOptions = [NSMutableArray arrayWithArray:savedMovieOptions];
        
        
        NSNumber *currentAnswerTag = [[NSUserDefaults standardUserDefaults] objectForKey:correctMovieOptionTag(self.categoryType)];
        NSNumber *incorrectAnswerTag = [[NSUserDefaults standardUserDefaults] objectForKey:incorrectMovieOptionTag(self.categoryType)];
        
        for (int index = 0; index < 3; index++) {
            UIButton *currentButton = ((UIButton *)[self.movieOptionsView viewWithTag:(index+1)*10]);
            [currentButton setTitle:savedMovieOptions[index] forState:UIControlStateNormal];
            
            if (currentAnswerTag) {
                currentButton.enabled = NO;
                [(UIButton *)[self.movieOptionsView viewWithTag:[currentAnswerTag intValue]] setBackgroundImage:[UIImage imageNamed:@"multiplechoiceGreen_button"] forState:UIControlStateDisabled];
                
                if (incorrectAnswerTag) {
                    [(UIButton *)[self.movieOptionsView viewWithTag:[incorrectAnswerTag intValue]] setBackgroundImage:[UIImage imageNamed:@"multiplechoiceRed_button"] forState:UIControlStateDisabled];
                }
            }else{
                currentButton.enabled = YES;
                [currentButton setBackgroundImage:nil forState:UIControlStateDisabled];
            }
            
            [currentButton setBackgroundImage:[UIImage imageNamed:@"multiplechoice_button"] forState:UIControlStateNormal];
            [currentButton addTarget:self action:@selector(movieOptionsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            currentButton = nil;
        }
        
        if (currentAnswerTag) {
            if (incorrectAnswerTag) {
                [self markCurrentQuestionIncorrect:YES];
            }else{
                [self markCurrentQuestionCorrect];
            }
        }
        currentAnswerTag = nil;
        incorrectAnswerTag = nil;
    }

    
    savedMovieOptions = nil;
}

-(void)initializeMovieNameWithFillCharacterPreset:(BOOL) isValueToBePreset
{
    NSString *savedMovieFillCharacter = [[NSUserDefaults standardUserDefaults] objectForKey:savedMovieFillCharacter(self.categoryType)];
    
    if (!isValueToBePreset || !savedMovieFillCharacter || !hasFillCharacterSavedForCurrentMovieType) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:savedMovieFillCharacter(self.categoryType)];
        [Utility markFillCharacterAsSavedForMovieType:self.categoryType savedState:NO];
        hasFillCharacterSavedForCurrentMovieType = NO;
        filledCharacterString = nil;
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        userAnswer = nil;
        userAnswer = [NSMutableString stringWithString:savedMovieFillCharacter];
        
        
        for (int index=0; index<userAnswer.length; index++) {
            unichar currentChar =  [userAnswer characterAtIndex:index];
            if (currentChar && currentChar != '\0' && currentChar != ' ') {
                UIButton *currentMovieCharButton = (UIButton *)[self.movieNameVew viewWithTag:(20 + index)];
                
                [currentMovieCharButton setTitle:[NSString stringWithFormat:@"%c",currentChar] forState:UIControlStateNormal];
                
                currentMovieCharButton.tag = 5000;
                currentMovieCharButton.enabled = NO;
                
                currentMovieCharButton = nil;
            }
        }
        NSUInteger nextPlaceHolderPosition = [userAnswer rangeOfString:@" "].location;
        if (nextPlaceHolderPosition != NSNotFound) {
            userAnswerOffset = (int)nextPlaceHolderPosition;
        }else{
            //Question has been incorrectly attempted
            [self markCurrentQuestionIncorrect:NO];
        }
    }
    
    savedMovieFillCharacter = nil;
}

#pragma mark - Movie Name View Creation
- (void)createMovieNameObjects:(NSString*)argAnswer
{
    int xOffset = 0;
    int yOffset = 0;
    
    
    NSArray *wordsInAnswer = [argAnswer componentsSeparatedByString:@" "];
    
    yOffset = (self.movieNameVew.frame.size.height - wordsInAnswer.count*(BUTTON_SIZE + BUTTON_SPACING) + BUTTON_SPACING)/2;
    
    int nameButtonTag = 0;
    
    for (NSString *currentWord in wordsInAnswer) {
        xOffset = (self.movieNameVew.frame.size.width - currentWord.length*(BUTTON_SIZE + BUTTON_SPACING) + BUTTON_SPACING)/2;
        for (int index = 0; index < currentWord.length; index++) {
            UIButton *currentButton = [[UIButton alloc] initWithFrame:CGRectMake(xOffset, yOffset, BUTTON_SIZE, BUTTON_SIZE)];
            [currentButton setBackgroundImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
            [currentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            [currentButton addTarget:self action:@selector(movieButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            currentButton.tag = 20 + nameButtonTag++;
            
            objc_setAssociatedObject(currentButton, movieButtonValue, [NSNumber numberWithInt:currentButton.tag], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            [self.movieNameVew addSubview:currentButton];
            
            xOffset += BUTTON_SIZE + BUTTON_SPACING;
        }
        
        yOffset += BUTTON_SIZE + BUTTON_SPACING;
    }
    
    
}

- (void)movieButtonClicked:(id)sender
{
    NSString *currentSelectedMovieChar = [((UIButton *) sender) titleForState:UIControlStateNormal];
    
    int currentSelectedMovieCharTag = (int)[(NSNumber *)objc_getAssociatedObject(sender, movieButtonValue) integerValue];
    
    if (userAnswerOffset > currentSelectedMovieCharTag - 20) {
        userAnswerOffset = currentSelectedMovieCharTag - 20;
    }
    
    
    
    if (!userAnswer || userAnswer.length == 0 || !currentSelectedMovieChar || [currentSelectedMovieChar isEqualToString:@""]) {
        return;
    }
    
    [self.optionView viewWithTag:((UIView *)sender).tag].hidden = NO;
    ((UIView *)sender).tag = currentSelectedMovieCharTag;
    
    [(UIButton *)sender setTitle:@"" forState:UIControlStateNormal];
    [userAnswer replaceCharactersInRange:NSMakeRange(currentSelectedMovieCharTag - 20, 1) withString:@" "];
    
    
    currentSelectedMovieChar = nil;
}

#pragma mark - Option View Creation
- (void)createOptionObjects:(NSString*)argOptionString
{
    int xOffset = (self.optionView.frame.size.width - (kMAX_LENGTH_OPTION_STRING/2)*(OPTION_BUTTON_SIZE + OPTION_BUTTON_SPACING) + OPTION_BUTTON_SPACING)/2;
    int yOffset = (self.optionView.frame.size.height - 2*OPTION_BUTTON_SIZE - OPTION_BUTTON_SPACING)/2;
    
    for (int index = 0; index < argOptionString.length; index++) {
        UIButton *currentButton = [[UIButton alloc] initWithFrame:CGRectMake(xOffset, yOffset, OPTION_BUTTON_SIZE, OPTION_BUTTON_SIZE)];
        [currentButton setBackgroundImage:[UIImage imageNamed:@"keypad"] forState:UIControlStateNormal];
        [currentButton setTitle:[NSString stringWithFormat:@"%c",[argOptionString characterAtIndex:index]] forState:UIControlStateNormal];
        [currentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        
        //Setting dynamic tag for the option button to implement quick undo
        currentButton.tag = 100 + index;
        [currentButton addTarget:self action:@selector(optionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self.optionView addSubview:currentButton];
        
        xOffset += OPTION_BUTTON_SIZE + OPTION_BUTTON_SPACING;
        if (xOffset >= (self.optionView.frame.size.width +(kMAX_LENGTH_OPTION_STRING/2)*(OPTION_BUTTON_SIZE + OPTION_BUTTON_SPACING) - OPTION_BUTTON_SPACING)/2) {
            xOffset = (self.optionView.frame.size.width - (kMAX_LENGTH_OPTION_STRING/2)*(OPTION_BUTTON_SIZE + OPTION_BUTTON_SPACING) + OPTION_BUTTON_SPACING)/2;
            yOffset += OPTION_BUTTON_SIZE + OPTION_BUTTON_SPACING;
        }
    }
}

- (void)optionButtonClicked:(id)sender
{
    UIButton *currentMovieCharButton = (UIButton *)[self.movieNameVew viewWithTag:(20 + userAnswerOffset)];
    
    if (!currentMovieCharButton) {
        return;
    }
    
    ((UIView *)sender).hidden = YES;
    NSString *currentSelectedChar = ((UIButton *) sender).titleLabel.text;
    
    if (!userAnswer) {
        userAnswer = [NSMutableString stringWithString:[[NSString string] stringByPaddingToLength:correctAnswer.length withString:@" " startingAtIndex:0]];
    }
    
    [currentMovieCharButton setTitle:currentSelectedChar forState:UIControlStateNormal];
    
    currentMovieCharButton.tag = ((UIButton *) sender).tag;
    
    [userAnswer replaceCharactersInRange:NSMakeRange(userAnswerOffset, 1) withString:currentSelectedChar];
    
    currentSelectedChar = nil;
    currentMovieCharButton = nil;
    
    if ([userAnswer isEqualToString:correctAnswer]) {
        [self markCurrentQuestionCorrect];
    }else{
        NSUInteger nextPlaceHolderPosition = [userAnswer rangeOfString:@" "].location;
        if (nextPlaceHolderPosition != NSNotFound) {
            userAnswerOffset = (int)nextPlaceHolderPosition;
        }else{
            //Question has been incorrectly attempted
            [self markCurrentQuestionIncorrect:NO];
        }
    }
}

-(void)markCurrentQuestionCorrect
{
    SIAlertView *noMoreHintsAlert = [[SIAlertView alloc] initWithTitle:@"Correct" andMessage:nil];
    
    [noMoreHintsAlert addButtonWithTitle:@"Try Next"
                                    type:SIAlertViewButtonTypeCancel
                                 handler:^(SIAlertView *alert) {
                                     [alert dismissAnimated:YES];
                                     [Utility markQuestionCorrectForMovieType:self.categoryType];
                                     [self nextButtonClicked:NO];
                                     [self initializeMovieOptionsWithPreset:NO];
                                     [self initializeMovieNameWithFillCharacterPreset:NO];
                                 }];
    
    noMoreHintsAlert.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [noMoreHintsAlert show];
    
    noMoreHintsAlert = nil;
}

-(void)markCurrentQuestionIncorrect:(BOOL)isToBeProgressed
{
    //Vibrate Animation
    if (!isToBeProgressed) {
        [CATransaction begin];
        CABasicAnimation *animation =
        [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setDuration:0.05];
        [animation setRepeatCount:8];
        [animation setAutoreverses:YES];
        [animation setDelegate:self];
        [animation setFromValue:[NSValue valueWithCGPoint:
                                 CGPointMake([self.movieNameVew center].x - 2.0f, [self.movieNameVew center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint:
                               CGPointMake([self.movieNameVew center].x + 2.0f, [self.movieNameVew center].y)]];
        [[self.movieNameVew layer] addAnimation:animation forKey:@"position"];
        [CATransaction commit];
        [Utility markQuestionIncorrectForMovieType:self.categoryType isToBeProgressed:isToBeProgressed];
    }else{
        SIAlertView *noMoreHintsAlert = [[SIAlertView alloc] initWithTitle:@"Incorrect" andMessage:nil];
        
        [noMoreHintsAlert addButtonWithTitle:@"Try Next"
                                        type:SIAlertViewButtonTypeCancel
                                     handler:^(SIAlertView *alert) {
                                         [alert dismissAnimated:YES];
                                         [Utility markQuestionIncorrectForMovieType:self.categoryType isToBeProgressed:isToBeProgressed];
                                         [self nextButtonClicked:NO];
                                         [self initializeMovieOptionsWithPreset:NO];
                                         [self initializeMovieNameWithFillCharacterPreset:NO];
                                     }];
        
        noMoreHintsAlert.transitionStyle = SIAlertViewTransitionStyleBounce;
        
        [noMoreHintsAlert show];
        
        noMoreHintsAlert = nil;
    }
}

- (IBAction)showMovieOptionsClicked:(id)sender
{
    if (![Utility checkForSufficientCredits:kPOINTS_REQUIRED_FOR_MOVIE_OPTIONS]) {
        [self showInsufficientCreditAlert:kPOINTS_REQUIRED_FOR_MOVIE_OPTIONS];
        return;
    }
    
    SIAlertView *showMovieOptionsAlert = [[SIAlertView alloc] initWithTitle:nil andMessage:[NSString stringWithFormat:@"Show the movie options requires %d credits.", kPOINTS_REQUIRED_FOR_MOVIE_OPTIONS]];
    
    [showMovieOptionsAlert addButtonWithTitle:@"Cancel"
                                      type:SIAlertViewButtonTypeDestructive
                                   handler:^(SIAlertView *alert) {
                                       [alert dismissAnimated:YES];
                                   }];
    [showMovieOptionsAlert addButtonWithTitle:@"Show"
                                      type:SIAlertViewButtonTypeCancel
                                   handler:^(SIAlertView *alert) {
                                       [alert dismissAnimated:YES];
                                       
                                       self.movieOptionsView.hidden = NO;
                                       self.optionView.hidden = YES;
                                       self.movieNameVew.hidden = YES;
                                       self.fillMovieCharButton.enabled = NO;
                                       self.showMovieOptionsButton.enabled = NO;
                                       
                                       for (int index = 0; index < 3; index++) {
                                           UIButton *currentButton = ((UIButton *)[self.movieOptionsView viewWithTag:(index+1)*10]);
                                           [currentButton setTitle:((Movie *)movies[levelIndex]).movieOptions[index] forState:UIControlStateNormal];
                                           [currentButton setBackgroundImage:[UIImage imageNamed:@"multiplechoice_button"] forState:UIControlStateNormal];
                                           [currentButton setBackgroundImage:nil forState:UIControlStateDisabled];
                                           [currentButton addTarget:self action:@selector(movieOptionsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                                           currentButton.enabled = YES;
                                           
                                           currentButton = nil;
                                       }
                                       
                                       [[NSUserDefaults standardUserDefaults] setObject:((Movie *)movies[levelIndex]).movieOptions forKey:savedMovieState(self.categoryType)];
                                       [Utility markStateAsSavedForMovieType:self.categoryType savedState:YES];
                                       
                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                       
                                   }];
    
    showMovieOptionsAlert.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [showMovieOptionsAlert show];
    
    showMovieOptionsAlert = nil;
}

-(void)movieOptionsButtonClicked:(id)sender
{
    for (int index = 0; index < 3; index++) {
        ((UIButton *)[self.movieOptionsView viewWithTag:(index+1)*10]).enabled = NO;
    }
    
    int correctOptionPosition = [((Movie *)movies[levelIndex]).movieOptions indexOfObject:((Movie *)movies[levelIndex]).answer] + 1;
    
    [(UIButton *)[self.movieOptionsView viewWithTag:correctOptionPosition*10] setBackgroundImage:[UIImage imageNamed:@"multiplechoiceGreen_button"] forState:UIControlStateDisabled];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:correctOptionPosition*10] forKey:correctMovieOptionTag(self.categoryType)];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIButton *selectedOptionButton = (UIButton *)sender;
    if (selectedOptionButton.tag != correctOptionPosition*10) {
        [selectedOptionButton setBackgroundImage:[UIImage imageNamed:@"multiplechoiceRed_button"] forState:UIControlStateDisabled];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:selectedOptionButton.tag] forKey:incorrectMovieOptionTag(self.categoryType)];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self markCurrentQuestionIncorrect:YES];
    }else{
        [self markCurrentQuestionCorrect];
    }
    
    selectedOptionButton = nil;
}

- (IBAction)showMoviePlotClicked:(id)sender
{
    if (!hasHintBeenSavedForCurrentMovieType && ![Utility checkForSufficientCredits:kPOINTS_REQUIRED_FOR_HINT]) {
        [self showInsufficientCreditAlert: kPOINTS_REQUIRED_FOR_HINT];
        return;
    }
    
    if (hasHintBeenSavedForCurrentMovieType) {
        [self displayMoviePlot];
    }else{
        
        SIAlertView *showMoviePlotAlert = [[SIAlertView alloc] initWithTitle:nil andMessage:[NSString stringWithFormat:@"Show the movie plot requires %d credits.", kPOINTS_REQUIRED_FOR_HINT]];
        
        [showMoviePlotAlert addButtonWithTitle:@"Cancel"
                                          type:SIAlertViewButtonTypeDestructive
                                       handler:^(SIAlertView *alert) {
                                           [alert dismissAnimated:YES];
                                       }];
        [showMoviePlotAlert addButtonWithTitle:@"Show"
                                          type:SIAlertViewButtonTypeCancel
                                       handler:^(SIAlertView *alert) {
                                           [alert dismissAnimated:YES];
                                           
                                           hasHintBeenSavedForCurrentMovieType = YES;
                                           
                                           [Utility markHintSavedForMovieType:self.categoryType savedState:YES];
                                           [self displayMoviePlot];
                                           
                                       }];
        
        showMoviePlotAlert.transitionStyle = SIAlertViewTransitionStyleBounce;
        
        [showMoviePlotAlert show];
        
        showMoviePlotAlert = nil;
    }
}

- (IBAction)fillCharButtonClicked:(id)sender
{
    __block UIButton *currentMovieCharButton = (UIButton *)[self.movieNameVew viewWithTag:(20 + userAnswerOffset)];
    
    if (!currentMovieCharButton) {
        return;
    }
    
    if (![Utility checkForSufficientCredits:kPOINTS_REQUIRED_FOR_FILL_CHARACTER]) {
        [self showInsufficientCreditAlert: kPOINTS_REQUIRED_FOR_FILL_CHARACTER];
        return;
    }
    
    SIAlertView *showMovieFillCharacterAlert = [[SIAlertView alloc] initWithTitle:nil andMessage:[NSString stringWithFormat:@"Show a correct letter requires %d credits.", kPOINTS_REQUIRED_FOR_FILL_CHARACTER]];
    
    [showMovieFillCharacterAlert addButtonWithTitle:@"Cancel"
                                               type:SIAlertViewButtonTypeDestructive
                                            handler:^(SIAlertView *alert) {
                                                [alert dismissAnimated:YES];
                                            }];
    [showMovieFillCharacterAlert addButtonWithTitle:@"Show"
                                               type:SIAlertViewButtonTypeCancel
                                            handler:^(SIAlertView *alert) {
                                                [alert dismissAnimated:YES];
                                                
                                                NSString *currentSelectedChar = [NSString stringWithFormat:@"%c",[correctAnswer characterAtIndex:userAnswerOffset]];
                                                
                                                if(!filledCharacterString)
                                                {
                                                    filledCharacterString = [NSMutableString stringWithString:[[NSString string] stringByPaddingToLength:correctAnswer.length withString:@" " startingAtIndex:0]];
                                                }
                                                
                                                [filledCharacterString replaceCharactersInRange:NSMakeRange(userAnswerOffset, 1) withString:currentSelectedChar];
                                                [[NSUserDefaults standardUserDefaults] setObject:filledCharacterString forKey:savedMovieFillCharacter(self.categoryType)];
                                                
                                                [Utility markFillCharacterAsSavedForMovieType:self.categoryType savedState:YES];
                                                
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                

                                                
                                                if (!userAnswer) {
                                                    userAnswer = [NSMutableString stringWithString:[[NSString string] stringByPaddingToLength:correctAnswer.length withString:@" " startingAtIndex:0]];
                                                }
                                                
                                                [currentMovieCharButton setTitle:currentSelectedChar forState:UIControlStateNormal];
                                                
                                                currentMovieCharButton.tag = 5000;
                                                currentMovieCharButton.enabled = NO;
                                                
                                                [userAnswer replaceCharactersInRange:NSMakeRange(userAnswerOffset, 1) withString:currentSelectedChar];
                                                
                                                currentSelectedChar = nil;
                                                currentMovieCharButton = nil;
                                                
                                                if ([userAnswer isEqualToString:correctAnswer]) {
                                                    [self markCurrentQuestionCorrect];
                                                }else{
                                                    NSUInteger nextPlaceHolderPosition = [userAnswer rangeOfString:@" "].location;
                                                    if (nextPlaceHolderPosition != NSNotFound) {
                                                        userAnswerOffset = (int)nextPlaceHolderPosition;
                                                    }else{
                                                        //Question has been incorrectly attempted
                                                        [self markCurrentQuestionIncorrect:NO];
                                                    }
                                                }
                                                
                                            }];
    
    showMovieFillCharacterAlert.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [showMovieFillCharacterAlert show];
    
    showMovieFillCharacterAlert = nil;
}

- (IBAction)shareOnFacebookClicked:(id)sender
{
    self.postImage = [self screenshot];
    self.postImageName = nil;
    
    [self shareOnFacebook:sender];
}

- (IBAction)closeButtonClicked:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)showInsufficientCreditAlert:(int)requiredCredits
{
    SIAlertView *notEnoughCredit = [[SIAlertView alloc] initWithTitle:nil andMessage:[NSString stringWithFormat:@"Not sufficient credits.(%d credits required)",requiredCredits]];
    
    [notEnoughCredit addButtonWithTitle:@"Cancel"
                                   type:SIAlertViewButtonTypeDestructive
                                handler:^(SIAlertView *alert) {
                                    [alert dismissAnimated:YES];
                                }];
    [notEnoughCredit addButtonWithTitle:@"Earn Credits"
                                   type:SIAlertViewButtonTypeCancel
                                handler:^(SIAlertView *alert) {
                                    [alert dismissAnimated:YES];

                                    [self earnButtonClicked];
                                }];
    
    notEnoughCredit.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [notEnoughCredit show];
    
    notEnoughCredit = nil;
}

-(void)displayMoviePlot
{
    SIAlertView *plotAlert = [[SIAlertView alloc] initWithTitle:@"Plot" andMessage:((Movie *)movies[levelIndex]).hint];
    
    [plotAlert addButtonWithTitle:@"Ok"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                              [alert dismissAnimated:YES];
                          }];
    
    plotAlert.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [plotAlert show];
    
    plotAlert = nil;
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
                                    
                                    self.postImage = nil;
                                    self.postImageName = @"movie_quiz_app";
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

@end
