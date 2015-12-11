//
//  ConversationsViewController.m
//  AnyoneThere?Final
//
//  Created by Robert von Stange on 11/10/15.
//  Copyright © 2015 Robert von Stange. All rights reserved.
//

#import "ConversationsViewController.h"
#import "UsersTableViewController.h"
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import "MySignUpViewController.h"
#import "MyLogInViewController.h"
#import "NewChatViewController.h"

@interface ConversationsViewController ()

@property (strong, nonatomic) NSArray* conversations;

@end

@implementation ConversationsViewController
- (IBAction)settingsAction:(id)sender {

}
- (IBAction)newChat:(id)sender {
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNewMessage:)
                                                 name:@"NewMessage"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadChats:)
                                                 name:@"LoggedIn"
                                               object:nil];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"convo"];
    
    UINavigationController *navVC = [[UINavigationController alloc] init];
    self.navVC = navVC;
    if ([PFUser currentUser]){
        PFQuery* conQuery = [PFQuery queryWithClassName:@"Conversation"];
        [conQuery whereKey:@"users" containsAllObjectsInArray:@[[PFUser currentUser]]];
        self.conversations = [conQuery findObjects];
    }
    
}

-(void)receiveNewMessage:(NSNotification *) notification {
    [self.tableView reloadData];
}

-(void)loadChats:(NSNotification *) notification {
    PFQuery* conQuery = [PFQuery queryWithClassName:@"Conversation"];
    [conQuery whereKey:@"users" containsAllObjectsInArray:@[[PFUser currentUser]]];
    self.conversations = [conQuery findObjects];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([PFUser currentUser] == nil) { // No user logged in
        // Create the log in view controller
        MyLogInViewController *logInViewController = [[MyLogInViewController alloc] init];
        logInViewController.fields = PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsUsernameAndPassword;
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Create the sign up view controller
        MySignUpViewController *signUpViewController = [[MySignUpViewController alloc] init];
        signUpViewController.fields = PFSignUpFieldsDefault | PFSignUpFieldsAdditional;
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:NO completion:NULL];
    }
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversations.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"convo" forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"convo"];
    PFObject* temp = self.conversations[indexPath.row];
    NSArray* userArray = temp[@"users"];
    for (int i = 0; i < userArray.count; i++) {
        if (userArray[i] != [PFUser currentUser]) {
            PFQuery* userQuery = [PFUser query];
            PFUser* user = userArray[i];
            [userQuery whereKey:@"objectId" equalTo:user.objectId];
            PFUser* fullUserInfo = [userQuery findObjects][0];
            cell.textLabel.text = fullUserInfo.username;
            cell.detailTextLabel.text = temp[@"lastMessage"];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewChatViewController* conversation = [[NewChatViewController alloc] init];
    conversation.currentUser = [PFUser currentUser];
    
    NSArray *users = self.conversations[indexPath.row][@"users"];
    PFUser *firstUser = users[0];
    if (firstUser.objectId == [PFUser currentUser].objectId) {
        conversation.otherUser = users[1];
    }
    else {
        conversation.otherUser = users[0];
    }
    
    [self.navigationController pushViewController:conversation animated:NO];
    
}


#pragma mark - logIn

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoggedIn" object:self];
    
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:[error.localizedDescription capitalizedString]
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
    //[self.tableView reloadData];
}

#pragma mark - signUp

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil]; // Dismiss the PFSignUpViewController
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoggedIn" object:self];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

@end