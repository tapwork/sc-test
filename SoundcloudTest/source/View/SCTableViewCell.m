//
//  SCTableViewCell.m
//  SoundcloudTest
//
//  Created by Christian Menschel on 26.08.13.
//  Copyright (c) 2013 tapwork. All rights reserved.
//

#import "SCTableViewCell.h"


@implementation SCTableViewCell
{
    UIImageView *_waveformImageView;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _waveformImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _waveformImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_waveformImageView];
        
        _trackTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _trackTitleLabel.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
        _trackTitleLabel.textColor = [UIColor whiteColor];
        [_waveformImageView addSubview:_trackTitleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _waveformImageView.frame = self.bounds;
    _trackTitleLabel.frame = CGRectMake(0,
                                        floorf(_waveformImageView.frame.size.height/2),
                                        _waveformImageView.frame.size.width,
                                        floorf(_waveformImageView.frame.size.height/2));
}

- (void)setWaveformImage:(UIImage *)waveformImage
{
    if (NO == [_waveformImageView.image isEqual:waveformImage])
    {
        _waveformImageView.image = waveformImage;
        if (waveformImage)
        {
            self.backgroundColor = [UIColor colorWithRed:1.0 green:88.0/255.0 blue:0.0 alpha:1.0];
        }
        else
        {
            self.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0];
        }
        
        [self setNeedsLayout];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
