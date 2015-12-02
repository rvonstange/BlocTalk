//
//  ViewController.h
//  AnyoneThere?Final
//
//  Created by Robert von Stange on 11/10/15.
//  Copyright © 2015 Robert von Stange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface ViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

//@property (nonatomic, strong) UINavigationController *navVC;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *chatButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;

@end

