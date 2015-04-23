//
//  DBHelper.h
//  Logo Quiz
//
//  Created by Mayank on 02/12/14.
//  Copyright (c) 2014 Infoedge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "Movie.h"


@interface DBHelper : NSObject

+(void)initializeDatabase;
+(void)closeDatabase;

+(NSArray *)moviesForType:(FCMovieType)movieType;

@end
