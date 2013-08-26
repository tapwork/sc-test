//
//  SCLoginViewController.h
//  SoundcloudTest
//
//  Created by Christian Menschel on 25.08.13.
//  Copyright (c) 2013 tapwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCLoginViewControllerDelegate;

@interface SCLoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) id <SCLoginViewControllerDelegate> delegate;

@end


@protocol SCLoginViewControllerDelegate <NSObject>

- (void)loginViewController:(SCLoginViewController*)loginVC didLogin:(BOOL)success;

@optional
- (void)loginViewControllerDidCancel:(SCLoginViewController*)loginVC;

@end