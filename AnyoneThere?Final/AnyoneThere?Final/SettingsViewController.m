//
//  SettingsViewController.m
//  AnyoneThere?Final
//
//  Created by Robert von Stange on 12/3/15.
//  Copyright © 2015 Robert von Stange. All rights reserved.
//

#import "SettingsViewController.h"
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import "ConversationsViewController.h"
#import "AppDelegate.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *displayName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confirmPass;

@property (nonatomic, strong) AppDelegate *appDelegate;


@end

@implementation SettingsViewController
- (IBAction)saveChanges:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    if (![self.displayName.text  isEqual: @""]) {
        currentUser[@"displayName"] = self.displayName.text;
        [currentUser saveInBackground];
    }
    else if (self.password.text != nil) {
        
    }
}
- (IBAction)logout:(id)sender {
    [PFUser logOut];

    NSLog(@"Logout Occurred");
    if (![PFUser currentUser]) {
        [self.navigationController popViewControllerAnimated:YES];
    }

}

- (IBAction)toggleVisibility:(id)sender{
    [_appDelegate.mcManager advertiseSelf:_swVisible.isOn];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    PFUser *currentUser = [PFUser currentUser];
    self.displayName.placeholder = currentUser[@"displayName"];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
