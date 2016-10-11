//
//  ViewController.m
//  PhotoSharer
//
//  Created by Ocean on 2016-10-09.
//  Copyright © 2016 Ocean. All rights reserved.
//

#import "ViewController.h"
#include "ShareViewController.h"

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation ViewController
@synthesize imgPhotoView, imgPhoto, btnShare;

- (void)viewDidLoad {
  [super viewDidLoad];
  [btnShare setEnabled:NO];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


- (IBAction)takePhoto:(id)sender {
  if(![self selectImgPickerControllerType:UIImagePickerControllerSourceTypeCamera]) {
    NSLog(@"No Camera");
  }
}

- (IBAction)openAlbum:(id)sender {
  [self selectImgPickerControllerType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) selectImgPickerControllerType: (UIImagePickerControllerSourceType)type
{
  BOOL res = YES;
  UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];

  if ( type == UIImagePickerControllerSourceTypeCamera &&
      [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
  } else if (type == UIImagePickerControllerSourceTypePhotoLibrary &&
      [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  } else if (type == UIImagePickerControllerSourceTypeSavedPhotosAlbum &&
             [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
  } else
    return NO;
  
  imagePicker.delegate = self;
  
  [self presentViewController:imagePicker animated:YES completion:NULL];
  return res;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
  UIImage *image = info[UIImagePickerControllerOriginalImage];
  self.imgPhotoView.image = image;
  self.imgPhoto = image;
  
  [btnShare setEnabled:YES];

  [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)backToCamera:(UIStoryboardSegue *)seque{
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"shareVC"]) {
    ShareViewController *shareVC = [segue destinationViewController];
    shareVC.imgSharePhoto = imgPhoto;
    shareVC.imgSharePhotoView.image = imgPhoto;
  }
}
@end
