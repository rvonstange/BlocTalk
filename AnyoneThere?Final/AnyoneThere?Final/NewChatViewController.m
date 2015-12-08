//
//  NewChatViewController.m
//  AnyoneThere?Final
//
//  Created by Robert von Stange on 11/17/15.
//  Copyright © 2015 Robert von Stange. All rights reserved.
//

#import "NewChatViewController.h"

@interface NewChatViewController ()

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) PFObject *conversation;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubble;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubble;
@property (strong, nonatomic) JSQMessagesAvatarImage *incomingAvatar;
@property (strong, nonatomic) JSQMessagesAvatarImage *outgoingAvatar;

@end

@implementation NewChatViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![self.otherUser[@"displayName"]  isEqual: @""]) {
        self.title = self.otherUser[@"displayName"];
    }
    else {
        self.title = self.otherUser.username;
    }
    self.senderId = self.currentUser.objectId;
    self.senderDisplayName = self.currentUser.username;
    JSQMessagesBubbleImageFactory *bubbleFactory = [JSQMessagesBubbleImageFactory new];
    self.incomingBubble = [bubbleFactory  incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleRedColor]];
    self.outgoingBubble = [bubbleFactory  outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    self.incomingAvatar = nil;//[JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"User2"] diameter:64];
    self.outgoingAvatar = nil;//[JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"User1"] diameter:64];
    
    //Create new array for messages to be stored locally
    self.messages = [NSMutableArray array];
    
    PFQuery* convoQuery = [PFQuery queryWithClassName:@"Conversation"];
    [convoQuery whereKey:@"users" containsAllObjectsInArray:@[self.currentUser,self.otherUser]];
    //If the two users have already spoken before we will enter the if statement
    if (convoQuery.countObjects != 0) {
        //For now I am going to only allow two users to speak but later inside here we can make it work for groups
        self.conversation = [convoQuery findObjects][0];
        PFQuery* messageQuery = [PFQuery queryWithClassName:@"Messages"];
        [messageQuery whereKey:@"convoID" equalTo:self.conversation];
        for (PFObject* message in [messageQuery findObjects]){
            PFUser* user = message[@"messageSender"];
            JSQMessage* temp = [JSQMessage messageWithSenderId:user.objectId displayName:user.username text:message[@"message"]];
            [self.messages addObject:temp];
        }
    }
    else if (convoQuery.countObjects == 0) {
        NSLog(@"I started a new conversation");
        //Create a new conversation for Parse
        self.conversation = [PFObject objectWithClassName:@"Conversation"];
        self.conversation[@"users"] = @[self.currentUser,self.otherUser];
        //self.conversation.ACL
        [self.conversation saveInBackground];
    }
}

//-(void)returnToMain:(id)sender
//{
//    NSLog(@"Hello");
//}

#pragma mark - Auto Message

- (void)receiveAutoMessage
{
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(didFinishMessageTimer:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)didFinishMessageTimer:(NSTimer*)timer
{
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    JSQMessage *message = [JSQMessage messageWithSenderId:self.otherUser.objectId
                                              displayName:self.otherUser.username
                                                     text:@"Hello"];
    [self.messages addObject:message];
    [self finishReceivingMessageAnimated:YES];
}

#pragma mark - JSQMessagesViewController

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    JSQMessage *message = [JSQMessage messageWithSenderId:senderId
                                              displayName:senderDisplayName
                                                     text:text];
    
    PFObject *messageForParse = [PFObject objectWithClassName:@"Messages"];
    messageForParse[@"messageSender"] = self.currentUser;
    messageForParse[@"message"] = text;
    messageForParse[@"convoID"] = self.conversation;
    //NSLog(@"conversation:%@",self.conversation);
    [messageForParse saveInBackgroundWithBlock:^(BOOL success, NSError* _error){
        //self.conversation[@"lastMessage"] = text;
        //[self.conversation save];
    }];


    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewMessage" object:self];
    
    [self.messages addObject:message];
    [self finishSendingMessageAnimated:YES];
    [self receiveAutoMessage];
}

#pragma mark - JSQMessagesCollectionViewDataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubble;
    }
    return self.incomingBubble;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingAvatar;
    }
    return self.incomingAvatar;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.messages.count;
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
