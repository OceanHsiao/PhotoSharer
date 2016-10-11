//
//  ViewController.h
//  PhotoSharer
//
//  Created by Ocean on 2016-10-09.
//  Copyright © 2016 Ocean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIImageView *imgPhotoView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *btnShare;
@property (nonatomic, strong) UIImage *imgPhoto;

- (IBAction)takePhoto:(id)sender;
- (IBAction)openAlbum:(id)sender;

/*** 3 Image Picker Controller Types:
 1. UIImagePickerControllerSourceTypeCamera
 2. UIImagePickerControllerSourceTypePhotoLibrary
 3. UIImagePickerControllerSourceTypeSavedPhotosAlbum
 ***/
- (BOOL) selectImgPickerControllerType: (UIImagePickerControllerSourceType)type;

- (IBAction)backToCamera:(UIStoryboardSegue *)seque;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

@end

