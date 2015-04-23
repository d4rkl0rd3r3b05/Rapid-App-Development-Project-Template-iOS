//
//  LevelCollectionViewCell.m
//  Logo Quiz
//
//  Created by Mayank on 03/12/14.
//  Copyright (c) 2014 Infoedge. All rights reserved.
//

#import "LevelCollectionViewCell.h"

@interface LevelCollectionViewCell()

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *attemptedLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *lockView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfHintsRequired;

@end


@implementation LevelCollectionViewCell

-(void)setAssociatedLevel:(Level *)associatedLevel
{
    _associatedLevel = associatedLevel;
    
//    self.levelTitleLabel.text = associatedLevel.title;
//    self.attemptedLabel.text = [NSString stringWithFormat:@"%d/%d",[Utility numberOfQuestionsCompletedForLevel:associatedLevel.title], associatedLevel.totalNumberOfQuestion];
//    self.scoreLabel.text = [NSString stringWithFormat:@"%d",[Utility scoreForLevel:associatedLevel.title]];
//    
//    int totalCompletedQuestionsForUser = associatedLevel.hitsNeededToUnlock - [Utility totalCompletedQuestionsForUser];
//    if (totalCompletedQuestionsForUser > 0) {
//        self.lockView.hidden = NO;
//        self.numberOfHintsRequired.text = [NSString stringWithFormat:@"%d hits needed to unlock.", totalCompletedQuestionsForUser];
//    }else{
//        self.lockView.hidden = YES;
//    }

}

@end
