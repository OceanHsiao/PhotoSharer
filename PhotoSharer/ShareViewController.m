//
//  ShareViewController.m
//  PhotoSharer
//
//  Created by Ocean on 2016-10-09.
//  Copyright © 2016 Ocean. All rights reserved.
//

#import "ShareViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <FBSDKLoginKit/FBSDKLoginManagerLoginResult.h>
#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>
#import <FBSDKShareKit/FBSDKShareAPI.h>
#import <FBSDKShareKit/FBSDKShareOpenGraphAction.h>
#import <FBSDKShareKit/FBSDKSharePhoto.h>
#import <FBSDKShareKit/FBSDKSharePhotoContent.h>
#import <FBSDKShareKit/FBSDKHashtag.h>
#import <FBSDKShareKit/FBSDKShareOpenGraphContent.h>

#import "Social/Social.h"
#import <Accounts/Accounts.h>


#define kOFFSET_FOR_KEYBOARD 200.0

@interface ShareViewController () <FBSDKSharingDelegate>

@end

@implementation ShareViewController
@synthesize imgSharePhotoView, imgSharePhoto, txtFieldHashtag, mainScrollView, fbDialog;

- (void)viewDidLoad {
  [super viewDidLoad];

  if (imgSharePhoto)
    self.imgSharePhotoView.image = imgSharePhoto;
  
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                 initWithTarget:self
                                 action:@selector(dismissKeyboard)];
  
  [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction) sharePhotoOntoFacebook:(id)sender {
  if (![FBSDKAccessToken currentAccessToken]) {
    NSLog(@"do login");
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
                 fromViewController:self
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                              if (error) {
                                // Process error
                                NSLog(@"Process error");
                              } else if (result.isCancelled) {
                                // Handle cancellations
                              } else {
                                if ([result.grantedPermissions containsObject:@"public_profile"]) {
                                  NSLog(@"with public_profile");
                                  [self doShareWithFaceBook];
                                } else {
                                  NSLog(@"without public_profile");
                                }
                              }
                            }];
  } else {
    [self doShareWithFaceBook];
  }
}

- (void) doShareWithFaceBook {

  FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc]init];
  
  FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc]init];
  photo.image = imgSharePhoto;
  //photo.userGenerated = YES;
  content.photos = @[photo];
  if (txtFieldHashtag.text)
    content.hashtag = [FBSDKHashtag hashtagWithString:[NSString stringWithFormat:@"#%@",txtFieldHashtag.text]];
  
  fbDialog = [[FBSDKShareDialog alloc] init];
  
  /***************************************************************************************
   1. If the dialog mode sets FBSDKShareDialogModeShareSheet, there would be an error:
   ---------------------------------------------------------------------------------
   2016-10-05 12:57:46.169 FaceBookLogin[16460:3463864] -canOpenURL: failed for
   URL: "fbapi20150629:/" - error: "This app is not allowed to query for scheme fbapi20150629"
   ---------------------------------------------------------------------------------
   Also,the hash tag would not work for FBSDKShareDialogModeShareSheet mode...
   
   2. If you don't set mode before canShow call, canShow would always return YES
   
   3. typedef NS_ENUM(NSUInteger, FBSDKShareDialogMode)
   {
   FBSDKShareDialogModeAutomatic = 0,  //abstract Acts with the most appropriate mode that is available.
   FBSDKShareDialogModeNative,         //Displays the dialog in the main native Facebook app.
   FBSDKShareDialogModeShareSheet,     //Displays the dialog in the iOS integrated share sheet.
   FBSDKShareDialogModeBrowser,        //Displays the dialog in Safari.
   FBSDKShareDialogModeWeb,            //Displays the dialog in a UIWebView within the app.
   FBSDKShareDialogModeFeedBrowser,    //Displays the feed dialog in Safari.
   FBSDKShareDialogModeFeedWeb,        //Displays the feed dialog in a UIWebView within the app.
   };
   ***************************************************************************************/
  fbDialog.mode = FBSDKShareDialogModeAutomatic;
  
  if ([fbDialog canShow] && [[FBSDKAccessToken currentAccessToken] hasGranted:@"public_profile"]) {
    fbDialog.fromViewController = self;
    fbDialog.shareContent = content;
    fbDialog.delegate = self;
    
    [fbDialog show];
    
  } else {
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Error"
                                 message:@"can't show the share dialog box."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                  //Handle your yes please button action here
                                  
                                }];
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
  }
}

#pragma mark - FBSDKSharingDelegate

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
  NSLog(@"completed share:%@", results);
  fbDialog = nil;
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
  NSLog(@"sharing error:%@", error);
  fbDialog = nil;
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
  NSLog(@"share cancelled");
  fbDialog = nil;
}

- (IBAction) sharePhotoOntoTwitter:(id)sender {
  SLComposeViewController *twitterController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
  
  /**
   ServiceType:
    SLServiceTypeTwitter;
    SLServiceTypeFacebook;
    SLServiceTypeSinaWeibo;
   **/
  if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
  {
    SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
      
      [twitterController dismissViewControllerAnimated:YES completion:nil];
      
      switch(result){
        case SLComposeViewControllerResultCancelled:
        default:
        {
          NSLog(@"Cancelled.....");
          
        }
          break;
        case SLComposeViewControllerResultDone:
        {
          NSLog(@"Posted....");
        }
          break;
      }};
    
    [twitterController addImage:imgSharePhoto];

    [twitterController setCompletionHandler:completionHandler];
    [self presentViewController:twitterController animated:YES completion:nil];
  }
}

#pragma mark - Keyboard & ScrollView Content move
-(void)keyboardWillShow {
  [self setViewMovedUp:YES];
}

-(void)keyboardWillHide {
  [self setViewMovedUp:NO];
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
  if (movedUp) {
    CGPoint newOffset = CGPointMake(0, kOFFSET_FOR_KEYBOARD);
    [self.mainScrollView setContentOffset: newOffset animated: YES];
  } else {
    CGPoint newOffset = CGPointMake(0, 0);
    [self.mainScrollView setContentOffset: newOffset animated: YES];
  }
}


- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  // register for keyboard notifications
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHide)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sharingStatus) name:ACAccountStoreDidChangeNotification object:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  // unregister for keyboard notifications while not visible.
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillShowNotification
                                                object:nil];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillHideNotification
                                                object:nil];
  
  [[NSNotificationCenter defaultCenter] removeObserver:ACAccountStoreDidChangeNotification];
}

- (void)sharingStatus {
  if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
    NSLog(@"service available");
  } else {
    NSLog(@"service NOT available");
  }
}

-(void)dismissKeyboard {
  [self.txtFieldHashtag resignFirstResponder];
}


@end
