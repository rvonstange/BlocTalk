//
//  UsersTableViewController.m
//  
//
//  Created by Robert von Stange on 11/16/15.
//
//

#import "UsersTableViewController.h"
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import "NewChatViewController.h"
#import "AppDelegate.h"
#import "SettingsViewController.h"

@interface UsersTableViewController ()
@property (strong, nonatomic) NSArray* userArray;

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *arrConnectedDevices;
@property (nonatomic, strong) NSString *localUsername;

@end

@implementation UsersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"username"];
    
    PFQuery* userQuery = [PFUser query];
    self.userArray = [userQuery findObjects];
    
    _arrConnectedDevices = [[NSMutableArray alloc] init];

    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    if (![[PFUser currentUser][@"displayName"]  isEqual: @""]) {
//        [[_appDelegate mcManager] setupPeerAndSessionWithDisplayName:[PFUser currentUser][@"displayName"]];
//    }
//    else {
        [[_appDelegate mcManager] setupPeerAndSessionWithDisplayName:[PFUser currentUser].username];
 //   }
    [[_appDelegate mcManager] advertiseSelf:YES];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
}

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    _localUsername = peerDisplayName;
    NSLog(@"i am in peer");
    
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            [_arrConnectedDevices addObject:peerDisplayName];
        }
        else if (state == MCSessionStateNotConnected){
            if ([_arrConnectedDevices count] > 0) {
                int indexOfPeer = [_arrConnectedDevices indexOfObject:peerDisplayName];
                [_arrConnectedDevices removeObjectAtIndex:indexOfPeer];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - browser for devices methods

- (IBAction)browseForDevices:(id)sender {
    [[_appDelegate mcManager] setupMCBrowser];
    [[[_appDelegate mcManager] browser] setDelegate:self];
    [self presentViewController:[[_appDelegate mcManager] browser] animated:YES completion:nil];
}

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
    NewChatViewController* conversation = [[NewChatViewController alloc] init];
    conversation.currentUser = [PFUser currentUser];
    PFQuery *user = [[PFUser query] whereKey:@"username" equalTo:_localUsername];
    NSLog(@"i am in peerasdf");
    NSLog(@"%@",_localUsername);
    conversation.otherUser = [user findObjects][0];
    conversation.localChat = YES;
    NSLog(@"i am in browse");
    [self.navigationController pushViewController:conversation animated:NO];
}


-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"username" forIndexPath:indexPath];
    PFUser* temp = self.userArray[indexPath.row];
    cell.textLabel.text = temp.username;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser* user = self.userArray[indexPath.row];
    NewChatViewController* conversation = [[NewChatViewController alloc] init];
    conversation.currentUser = [PFUser currentUser];
    conversation.otherUser = user;
    conversation.localChat = NO;
    
    [self.navigationController pushViewController:conversation animated:NO];
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
