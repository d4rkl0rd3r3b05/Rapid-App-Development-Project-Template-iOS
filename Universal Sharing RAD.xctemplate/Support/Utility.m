//
//  Utility.m
//  Sample iOS Structure
//
//  Created by Mayank on 07/07/14.
//  Copyright (c) 2014 InfoEdge. All rights reserved.
//

#import "Utility.h"

#define USER_STATS_PLIST @"userStats"

@implementation Utility

static NSMutableDictionary *userStatsDictionary;
static NSString *userStatsPlistPath;

+(void)initializeUserStatsDictionary
{
    if (userStatsDictionary) {
        return;
    }
    
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentPath = [paths lastObject];
    
    NSURL *storeURL = [documentPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",USER_STATS_PLIST]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:USER_STATS_PLIST ofType:@"plist"]];
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
            NSLog(@"Error: Unable to copy user stats plist.");
        }
    }
    
    userStatsPlistPath = [storeURL path];
    userStatsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[storeURL path]];
}

+(int)numberOfQuestionsCompletedForMovieType:(FCMovieType)movieType
{
    return (int)[[userStatsDictionary valueForKeyPath:[NSString stringWithFormat:@"%@.question_correctly_answered",GetMovieTypeIdentifier(movieType)]] integerValue];
}

+(void)markQuestionCorrectForMovieType:(FCMovieType)movieType
{
    int currentQuestionLevel = [self numberOfQuestionsCompletedForMovieType:movieType];
    
    [userStatsDictionary setValue:[NSNumber numberWithInt:(currentQuestionLevel + 1)] forKeyPath:[NSString stringWithFormat:@"%@.question_correctly_answered",GetMovieTypeIdentifier(movieType)]];
    
//    int score = (currentQuestionLevel/20 + 1) * 2;
    [userStatsDictionary setValue:[NSNumber numberWithInt:([self totalScoreForUser] + 3)] forKey:@"total_score"];
    
    [userStatsDictionary writeToFile:userStatsPlistPath atomically:YES];
}

+(void)markQuestionIncorrectForMovieType:(FCMovieType)movieType isToBeProgressed:(BOOL)isToBeProgressed
{
    int currentQuestionLevel = [self numberOfQuestionsCompletedForMovieType:movieType];
    
    if (isToBeProgressed) {
        [userStatsDictionary setValue:[NSNumber numberWithInt:(currentQuestionLevel + 1)] forKeyPath:[NSString stringWithFormat:@"%@.question_correctly_answered",GetMovieTypeIdentifier(movieType)]];
    }
    
//    int score = -1*(currentQuestionLevel/30 + 1);
    [userStatsDictionary setValue:[NSNumber numberWithInt:([self totalScoreForUser] + 0)] forKey:@"total_score"];
    
    [userStatsDictionary writeToFile:userStatsPlistPath atomically:YES];
}

+(int)totalScoreForUser
{
    return (int)[[userStatsDictionary valueForKey:@"total_score"] integerValue];
}

+(void)increaseTotalScoreForUser:(int)scoreToIncrease
{
    [userStatsDictionary setValue:[NSNumber numberWithInt:([self totalScoreForUser] + scoreToIncrease)] forKey:@"total_score"];
    
    [userStatsDictionary writeToFile:userStatsPlistPath atomically:YES];
}

+(NSString *)getIncorrectQuestionString:(NSString *)argQuestionString
{
    @try {
        argQuestionString = [argQuestionString uppercaseString];

        NSMutableSet *questionStringSet = [NSMutableSet new];
        NSMutableArray *finalOptionArray = [NSMutableArray new];
        
        
        for (int index = 0; index < argQuestionString.length; index ++) {
            unichar currentCharacter = [argQuestionString characterAtIndex:index];
            
            if (![[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:currentCharacter]) {
                [questionStringSet addObject:[NSString stringWithFormat:@"%c", currentCharacter]];
                [finalOptionArray addObject:[NSString stringWithFormat:@"%c", currentCharacter]];
            }
        }
        
        
        NSMutableSet *alphabets = [NSMutableSet setWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
        
        //Get Mutually Exclusive Set of Alphabets
        [alphabets minusSet:questionStringSet];
        NSMutableArray *exclusiveAlphabetsArray = [[NSMutableArray alloc] initWithArray:[alphabets allObjects]];
        
        //Get number of Incorrect Alphabets to be mixed
        int remainingPlaces = (kMAX_LENGTH_OPTION_STRING - finalOptionArray.count);
        
        for (NSUInteger index = 0; index < remainingPlaces; index++) {
            int selectedIndex = arc4random() % exclusiveAlphabetsArray.count;
            [finalOptionArray addObject:[exclusiveAlphabetsArray objectAtIndex:selectedIndex]];
            [exclusiveAlphabetsArray removeObjectAtIndex:selectedIndex];
        }
        
        
        NSUInteger numberOfLetters = finalOptionArray.count;
        NSMutableString *finalResult = [NSMutableString string];
        for (NSUInteger index = 0; index < numberOfLetters; index++) {
            int selectedIndex = arc4random() % finalOptionArray.count;
            [finalResult appendString:[finalOptionArray objectAtIndex:selectedIndex]];
            [finalOptionArray removeObjectAtIndex:selectedIndex];
        }
        
        return finalResult;
    }
    @catch (NSException *exception) {
        return argQuestionString;
    }
}

+(void)resetProgress
{
    //Clearing all nsuserdefaults
    NSDictionary *defaultsDictionary = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    for (NSString *key in [defaultsDictionary allKeys]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    
    int userScore = [self totalScoreForUser];
    
    //Restoring User Stats Plist File
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentPath = [paths lastObject];
    
    NSURL *storeURL = [documentPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",USER_STATS_PLIST]];
    
    NSError* err = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]){
        if (![[NSFileManager defaultManager] removeItemAtURL:storeURL error:&err]) {
            NSLog(@"Error: Unable to delete user stats plist.");
        }
        err = nil;
    }
     
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:USER_STATS_PLIST ofType:@"plist"]];
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
            NSLog(@"Error: Unable to copy user stats plist.");
        }
    }
    
    userStatsPlistPath = [storeURL path];
    userStatsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[storeURL path]];
    
    [userStatsDictionary setValue:[NSNumber numberWithInt:userScore] forKey:@"total_score"];
    [userStatsDictionary writeToFile:userStatsPlistPath atomically:YES];
}

+(void)markHintSavedForMovieType:(FCMovieType)movieType savedState:(BOOL)savedState
{
    if (savedState) {
        [userStatsDictionary setValue:[NSNumber numberWithInt:([self totalScoreForUser] - kPOINTS_REQUIRED_FOR_HINT)] forKey:@"total_score"];
    }

    [userStatsDictionary setValue:[NSNumber numberWithBool:savedState] forKeyPath:[NSString stringWithFormat:@"%@.is_movie_hint_state_saved",GetMovieTypeIdentifier(movieType)]];
    
    [userStatsDictionary writeToFile:userStatsPlistPath atomically:YES];
}

+(BOOL)isHintSavedForMovieType:(FCMovieType)movieType
{
    return [(NSNumber *)[userStatsDictionary valueForKeyPath:[NSString stringWithFormat:@"%@.is_movie_hint_state_saved",GetMovieTypeIdentifier(movieType)]] boolValue];
}

+(void)markStateAsSavedForMovieType:(FCMovieType)movieType savedState:(BOOL)savedState
{
    if (savedState) {
        [userStatsDictionary setValue:[NSNumber numberWithInt:([self totalScoreForUser] - kPOINTS_REQUIRED_FOR_MOVIE_OPTIONS)] forKey:@"total_score"];
    }
    
    [userStatsDictionary setValue:[NSNumber numberWithBool:savedState] forKeyPath:[NSString stringWithFormat:@"%@.is_movie_option_state_saved",GetMovieTypeIdentifier(movieType)]];
    
    [userStatsDictionary writeToFile:userStatsPlistPath atomically:YES];
}

+(BOOL)isStateSavedForMovieType:(FCMovieType)movieType
{
    return [(NSNumber *)[userStatsDictionary valueForKeyPath:[NSString stringWithFormat:@"%@.is_movie_option_state_saved",GetMovieTypeIdentifier(movieType)]] boolValue];
}

+(void)markFillCharacterAsSavedForMovieType:(FCMovieType)movieType savedState:(BOOL)savedState
{
    if (savedState) {
        [userStatsDictionary setValue:[NSNumber numberWithInt:([self totalScoreForUser] - kPOINTS_REQUIRED_FOR_FILL_CHARACTER)] forKey:@"total_score"];
    }
    
    [userStatsDictionary setValue:[NSNumber numberWithBool:savedState] forKeyPath:[NSString stringWithFormat:@"%@.is_movie_fill_character_state_saved",GetMovieTypeIdentifier(movieType)]];
    
    [userStatsDictionary writeToFile:userStatsPlistPath atomically:YES];
}

+(BOOL)isFillCharacterSavedForMovieType:(FCMovieType)movieType
{
    return [(NSNumber *)[userStatsDictionary valueForKeyPath:[NSString stringWithFormat:@"%@.is_movie_fill_character_state_saved",GetMovieTypeIdentifier(movieType)]] boolValue];
}

+(BOOL)checkForSufficientCredits:(int)requiredCredits
{
    if (requiredCredits <=  [self totalScoreForUser]) {
        return YES;
    }else{
        return NO;
    }
}

@end
