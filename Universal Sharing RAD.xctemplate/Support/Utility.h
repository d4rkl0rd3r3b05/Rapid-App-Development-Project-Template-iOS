//
//  Utility.h
//  Sample iOS Structure
//
//  Created by Mayank on 07/07/14.
//  Copyright (c) 2014 InfoEdge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Movie.h"

//NSUserDefault keys
#define savedMovieState(movieType) [NSString stringWithFormat:@"%d_MOVIE_OPTIONS_ORDER",movieType]
#define correctMovieOptionTag(movieType) [NSString stringWithFormat:@"%d_CORRECT_MOVIE_OPTION_TAG",movieType]
#define incorrectMovieOptionTag(movieType) [NSString stringWithFormat:@"%d_INCORRECT_MOVIE_OPTION_TAG",movieType]

#define savedMovieFillCharacter(movieType) [NSString stringWithFormat:@"%d_MOVIE_FILL_CHARACTER_STRING",movieType]

@interface Utility : NSObject


+(void)initializeUserStatsDictionary;
+(int)numberOfQuestionsCompletedForMovieType:(FCMovieType)movieType;
+(void)markQuestionCorrectForMovieType:(FCMovieType)movieType;
+(void)markQuestionIncorrectForMovieType:(FCMovieType)movieType isToBeProgressed:(BOOL)isToBeProgressed;
+(int)totalScoreForUser;
+(void)increaseTotalScoreForUser:(int)scoreToIncrease;
+(void)resetProgress;
+(void)markStateAsSavedForMovieType:(FCMovieType)movieType savedState:(BOOL)savedState;
+(BOOL)isStateSavedForMovieType:(FCMovieType)movieType;
+(void)markHintSavedForMovieType:(FCMovieType)movieType savedState:(BOOL)savedState;
+(BOOL)isHintSavedForMovieType:(FCMovieType)movieType;
+(void)markFillCharacterAsSavedForMovieType:(FCMovieType)movieType savedState:(BOOL)savedState;
+(BOOL)isFillCharacterSavedForMovieType:(FCMovieType)movieType;

+(NSString *)getIncorrectQuestionString:(NSString *)argQuestionString;

+(BOOL)checkForSufficientCredits:(int)requiredCredits;

@end
