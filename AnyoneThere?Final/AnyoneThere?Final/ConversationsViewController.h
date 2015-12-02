//
//  ConversationsViewController.h
//  AnyoneThere?Final
//
//  Created by Robert von Stange on 11/10/15.
//  Copyright © 2015 Robert von Stange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>


@interface ConversationsViewController : UITableViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *chatButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;

@property (weak, nonatomic) UINavigationController *navVC;

-(void) newChat:(id)sender;

@end
