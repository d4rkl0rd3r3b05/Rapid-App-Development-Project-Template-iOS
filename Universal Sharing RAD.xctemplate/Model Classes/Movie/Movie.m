//
//  Movie.m
//  Movie Quiz
//
//  Created by Mayank on 17/12/14.
//  Copyright (c) 2014 Infoedge. All rights reserved.
//

#import "Movie.h"

@implementation Movie

-(void) generateMovieType:(NSString *)movieType
{
    if ([movieType isEqualToString:@"QuestionType1Pic1Movie"]) {
        self.movieType = kSingle;
    }else if([movieType isEqualToString:@"Characters"]){
        self.movieType = kCharacter;
    }else if([movieType isEqualToString:@"Villains"]){
        self.movieType = kVillain;
    }else{
        self.movieType = kGroup;
    }
}


@end
