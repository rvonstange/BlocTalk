//
//  NewChatViewController.h
//  AnyoneThere?Final
//
//  Created by Robert von Stange on 11/17/15.
//  Copyright © 2015 Robert von Stange. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import "JSQMessages.h"


@interface NewChatViewController : JSQMessagesViewController <UIActionSheetDelegate>

@property (strong, nonatomic) PFUser* currentUser;
@property (strong, nonatomic) PFUser* otherUser;

@end
