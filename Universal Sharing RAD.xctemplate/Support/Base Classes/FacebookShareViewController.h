//
//  FacebookShareViewController.h
//  Movie Quiz
//
//  Created by Mayank on 23/01/15.
//  Copyright (c) 2015 Infoedge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookShareViewController : UIViewController

@property NSString *postImageName;
@property UIImage *postImage;





- (IBAction)shareOnFacebook:(id)sender;
-(id)initWithPostingStartLabelText:(NSString *)postingStartLabelText
       postingStartDetailLabelText:(NSString *)postingStartDetailLabelText
                     postImageName:(NSString *)postImageName
                         postTitle:(NSString *)postTitle
                          postType:(NSString *)postType
                   postDescription:(NSString *)postDescription
                        postObject:(NSString *)postObject
                        postAction:(NSString *)postAction
          postingFinishedLabelText:(NSString *)postingFinishedLabelText
             postingErrorAlertText:(NSString *)postingErrorAlertText;


@end
