//
//  SCMasterViewController.m
//  SoundcloudTest
//
//  Created by Christian Menschel on 24.08.13.
//  Copyright (c) 2013 tapwork. All rights reserved.
//

#import "SCMasterViewController.h"
#import "SCApiManager.h"
#import "SCTrack.h"
#import "SCTableViewCell.h"
#import "UIImage+Size.h"

static NSCache *kImageCache = nil;
static NSMutableSet *kImagePendingRequests = nil;
static NSString *const kSCTableViewCellIdentifier = @"SCTableViewCell";

@interface SCMasterViewController () {
    NSMutableArray *_tracks;
    NSOperationQueue *_imageLoadingQueue;
}
@end

@implementation SCMasterViewController

#pragma mark - init & dealloc

+ (void)initialize
{
    if (self == [SCMasterViewController class])
    {
        kImageCache = [[NSCache alloc] init];
        kImagePendingRequests = [[NSMutableSet alloc] init];
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(presentLoginView)
                                                     name:SCApiManagerCouldNotRefreshSessionNotification
                                                   object:nil];
        
        _imageLoadingQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - view life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]
                                           initWithTitle:NSLocalizedString(@"Logout", @"")
                                           style:UIBarButtonItemStylePlain
                                           target:self action:@selector(logout:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    [self.tableView registerClass:[SCTableViewCell class] forCellReuseIdentifier:kSCTableViewCellIdentifier];
    
    
    if ([SCApiManager sharedInstance].hasSession == YES)
    {
        [self loadTracks];
    }
    else
    {
        //
        // we need to dispatch this async, when view information if self is ready
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentLoginView];
        });
    }
}

- (void)presentLoginView
{
    SCLoginViewController *loginVC = [[SCLoginViewController alloc] init];
    loginVC.delegate = self;
    [self presentViewController:loginVC animated:YES completion:nil];
}

#pragma mark - Actions
- (void)logout:(id)sender
{
    [[SCApiManager sharedInstance] logout];
    [self presentLoginView];
}

- (void)loadTracks
{
    __weak __typeof(&*self)weakSelf = self;
    
    [[SCApiManager sharedInstance] requestTracksWithCompletion:^(NSArray *tracks) {
        _tracks = [NSMutableArray arrayWithArray:tracks];
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - SCLoginViewControllerDelegate
- (void)loginViewController:(SCLoginViewController*)loginVC didLogin:(BOOL)success;
{
    if (success)
    {
        [loginVC dismissViewControllerAnimated:YES completion:nil];
        [self loadTracks];
    }
}

- (void)loginViewControllerDidCancel:(SCLoginViewController*)loginVC
{
    [loginVC dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - memory management


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    // we are using NSCache for image caching
    // so that guy will be purged anyway when we get memory warnings
}



#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [_tracks count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCTableViewCell *cell = (SCTableViewCell*)[tableView dequeueReusableCellWithIdentifier:kSCTableViewCellIdentifier
                                                                              forIndexPath:indexPath];
    
    SCTrack *track = _tracks[indexPath.row];
    cell.trackTitleLabel.text = [track title];
    if ([kImageCache objectForKey:track.waveformURL])
    {
        [cell setWaveformImage:[kImageCache objectForKey:track.waveformURL]];
    }
    else
    {
        [cell setWaveformImage:nil];
    }
    return cell;
}

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadImagesAtIndexPath:indexPath];
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCTrack *track = _tracks[indexPath.row];
    if ([[UIApplication sharedApplication] canOpenURL:track.soundcloudAppURI])
    {
        [[UIApplication sharedApplication] openURL:track.soundcloudAppURI];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:track.permalinkURL];
    }
    
}

#pragma mark - Cell Image Loading
- (void)loadImagesAtIndexPath:(NSIndexPath*)indexPath
{
    SCTrack *track = _tracks[indexPath.row];
    NSURL *url = track.waveformURL;
    
    //
    // only load when not in cache or not pending yet
    //
    if (url != nil &&
        [kImageCache objectForKey:url] == nil &&
        NO == [kImagePendingRequests containsObject:url])
    {
        [kImagePendingRequests addObject:url];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url]
                                           queue:_imageLoadingQueue
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (data)
                                   {
                                       SCTableViewCell *cell = (SCTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
                                       UIImage *image = [UIImage imageWithData:data];
                                       //
                                       // We need to resize the image because it is definitely too lage (I have seen something with 1800x300)
                                       //
                                       CGFloat scale = [UIScreen mainScreen].scale;
                                       CGSize imageSize = CGSizeMake(self.tableView.bounds.size.width*scale,
                                                                     self.tableView.rowHeight*scale);
                                       image = [image scaledCopyOfSize:imageSize];
                                       
                                       if (image)
                                       {
                                           [kImageCache setObject:image forKey:url];
                                           [kImagePendingRequests removeObject:url];
                                           dispatch_async(dispatch_get_main_queue(),
                                                          ^{
                                                              [cell setWaveformImage:image];
                                                          });
                                       }
                                   }
                                   
                               }];
    }
}


@end
