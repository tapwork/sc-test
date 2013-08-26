//
//  SCTableViewCell.h
//  SoundcloudTest
//
//  Created by Christian Menschel on 26.08.13.
//  Copyright (c) 2013 tapwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCTableViewCell : UITableViewCell

@property (nonatomic, readonly) UILabel *trackTitleLabel;

- (void)setWaveformImage:(UIImage *)waveformImage;

@end
