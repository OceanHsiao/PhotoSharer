//
//  ShareViewController.h
//  PhotoSharer
//
//  Created by Ocean on 2016-10-09.
//  Copyright © 2016 Ocean. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBSDKShareDialog;
@interface ShareViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIImageView *imgSharePhotoView;
@property (nonatomic, weak) IBOutlet UITextField *txtFieldHashtag;
@property (nonatomic, weak) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, strong) UIImage *imgSharePhoto;
@property (nonatomic, strong) FBSDKShareDialog *fbDialog;

- (IBAction) sharePhotoOntoFacebook:(id)sender;
- (IBAction) sharePhotoOntoTwitter:(id)sender;
- (void) doShareWithFaceBook;


@end
