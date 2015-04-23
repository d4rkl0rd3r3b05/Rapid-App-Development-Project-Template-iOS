//
//  DBHelper.m
//  Logo Quiz
//
//  Created by Mayank on 02/12/14.
//  Copyright (c) 2014 Infoedge. All rights reserved.
//

#import "DBHelper.h"


#import "sqlite3.h"
#import "FMDatabase.h"
#import "Movie.h"

#define DATABASE_NAME @"Movies"

@implementation DBHelper

static FMDatabase *database;

+(void)initializeDatabase
{
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentPath = [paths lastObject];
    
    NSURL *storeURL = [documentPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",DATABASE_NAME ]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:DATABASE_NAME ofType:@"sqlite"]];
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
            NSLog(@"Error: Unable to copy preloaded database.");
        }
        
        preloadURL = nil;
        err = nil;
    }
    
    
    database = [FMDatabase databaseWithPath:[storeURL path]];
    [database openWithFlags:SQLITE_OPEN_READWRITE];
    
    paths = nil;
    documentPath = nil;
    storeURL = nil;
}

+(void)closeDatabase
{
    [database close];
}

+(NSArray *)moviesForType:(FCMovieType)movieType
{
    NSMutableArray *moviesForType;
    
    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM tQuestions WHERE sQuestionType = '%@' ORDER BY nLevelId LIMIT 400 OFFSET %d",GetMovieTypeIdentifier(movieType), [Utility numberOfQuestionsCompletedForMovieType:movieType]]];
    while([results next]) {
        Movie *currentMovie = [[Movie alloc] init];
        
        currentMovie.movieID = [results intForColumn:@"ixId"];
        currentMovie.levelID = [results intForColumn:@"nLevelId"];
        currentMovie.answer =  [results stringForColumn:@"sAnswer"];
        currentMovie.releasedYear = [results stringForColumn:@"sCategory"];
        [currentMovie generateMovieType:[results stringForColumn:@"sQuestionType"]];
        currentMovie.hint = [results stringForColumn:@"sHint"];
        currentMovie.movieImages = [[results stringForColumn:@"sImageNames"] componentsSeparatedByString:@","];
        currentMovie.trivia = [results stringForColumn:@"sTrivia"];
        
        NSMutableArray *movieOptions = [NSMutableArray arrayWithObjects:[results stringForColumn:@"sOption2"], [results stringForColumn:@"sOption3"], currentMovie.answer, nil];
        
        NSMutableArray *scrambledMovieOptions = [NSMutableArray new];
        for (NSUInteger index = 0; index < 3; index++) {
            int selectedIndex = arc4random() % movieOptions.count;
            [scrambledMovieOptions addObject:[movieOptions objectAtIndex:selectedIndex]];
            [movieOptions removeObjectAtIndex:selectedIndex];
        }
        currentMovie.movieOptions = scrambledMovieOptions;
        
        scrambledMovieOptions = nil;
        movieOptions = nil;
        

        if (!moviesForType) {
            moviesForType = [NSMutableArray new];
        }
        [moviesForType addObject:currentMovie];
        
        currentMovie = nil;
    }
    results = nil;
    
    return moviesForType;
}

//+(void)setNumberOfHintsAvailable:(int)numberOfHintsAvailable questionID:(int)questionID
//{
//    [database executeUpdate:@"UPDATE ZQUESTION SET ZIMAGE = ? where Z_PK = ?",[NSNumber numberWithInt:numberOfHintsAvailable], [NSNumber numberWithInt:questionID]];
//    [Utility incrementHintAvailCount];
//}
//
//+(void)markQuestionCorrectForQuestionID:(int)questionID
//{
//    [database executeUpdate:@"UPDATE ZQUESTION SET ZIMAGECOMPLETE = ? where Z_PK = ?",[NSNumber numberWithInt:1], [NSNumber numberWithInt:questionID]];
//}
//
//+(void)setUserAnswerIndex:(int)userAnswerIndex questionID:(int)questionID
//{
//    [database executeUpdate:@"UPDATE ZQUESTION SET Z_OPT = ? where Z_PK = ?",[NSNumber numberWithInt:userAnswerIndex], [NSNumber numberWithInt:questionID]];
//}


@end
