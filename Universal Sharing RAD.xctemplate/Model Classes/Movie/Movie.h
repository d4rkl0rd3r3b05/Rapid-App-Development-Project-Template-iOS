//
//  Movie.h
//  Movie Quiz
//
//  Created by Mayank on 17/12/14.
//  Copyright (c) 2014 Infoedge. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FCMovieType) {
    kCharacter = 1,
    kVillain = 2,
    kSingle = 3,
    kGroup = 4
};


@interface Movie : NSObject

@property int movieID;
@property int levelID;
@property NSString *answer;
@property NSString *releasedYear;
@property FCMovieType movieType;
@property NSString *hint;
@property NSArray *movieImages;
@property NSMutableArray *movieOptions;
@property NSString *trivia;

-(void) generateMovieType:(NSString *)movieType;

@end

