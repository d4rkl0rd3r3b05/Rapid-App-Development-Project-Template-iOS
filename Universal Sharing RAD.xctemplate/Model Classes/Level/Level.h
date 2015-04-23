//
//  Level.h
//  Logo Quiz
//
//  Created by Mayank on 01/12/14.
//  Copyright (c) 2014 Infoedge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Level : NSObject

@property int hitsNeededToUnlock;
@property int levelID;
@property int totalNumberOfQuestion;
@property int score;
@property int numberOfQuestionCompleted;
@property (nonatomic, retain) NSString * title;

@end
