//
//  GMImagePickerController.m
//  GMPhotoPicker
//
//  Created by Guillermo Muntaner Perelló on 19/09/14.
//  Copyright (c) 2014 Guillermo Muntaner Perelló. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "GMImagePickerController.h"
#import "GMAlbumsViewController.h"
#import "GMGridViewController.h"
@import Photos;

@interface GMImagePickerController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>

@end

@implementation GMImagePickerController
- (id)init:(bool)allow_v withAssets: (NSArray*)preSelectedAssets delegate: (id<GMImagePickerControllerDelegate>) delegate
{
    if (self = [super init])
    {
        self.delegate = delegate;
        self.videoMaximumDuration = 15;
        _selectedAssets = [[NSMutableArray alloc] init];
        
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:preSelectedAssets options:nil];
        
        for (PHAsset *asset in fetchResult) {
            [_selectedAssets addObject: asset];
        }
        
        // _selectedAssets = [fetchResult copy];
        _allow_video = allow_v;
        
        _shouldCancelWhenBlur = YES;
        
        // Default values:
        _displaySelectionInfoToolbar = YES;
        _displayAlbumsNumberOfAssets = YES;
        _autoDisableDoneButton = YES;
        _allowsMultipleSelection = YES;
        _confirmSingleSelection = NO;
        _showCameraButton = NO;
        
        // Grid configuration:
        if([self.delegate respondsToSelector:@selector(assetsPickerControllerColumnInPortrait)] && [self.delegate respondsToSelector:@selector(assetsPickerControllerColumnInLandscape)]) {
            _colsInPortrait =  [self.delegate assetsPickerControllerColumnInPortrait];
            _colsInLandscape =  [self.delegate assetsPickerControllerColumnInLandscape];
        } else {
            NSOperatingSystemVersion ios10_0_1 = (NSOperatingSystemVersion){10, 0, 1};
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios10_0_1]) {
                    // iOS 8.0.1 and above logic
                    _colsInPortrait = 6;
                    _colsInLandscape = 10;
                } else {
                    // iOS 8.0.0 and below logic
                    _colsInPortrait = 4;
                    _colsInLandscape = 5;
                }
                
            }else{
                _colsInPortrait = 3;
                _colsInLandscape = 5;
            }
        }
        _minimumInteritemSpacing = 2.0;
        
        // Sample of how to select the collections you want to display:
        //        _customSmartCollections = @[@(PHAssetCollectionSubtypeSmartAlbumFavorites),
        //                                    @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
        //                                    @(PHAssetCollectionSubtypeSmartAlbumVideos),
        //                                    @(PHAssetCollectionSubtypeSmartAlbumSlomoVideos),
        //                                    @(PHAssetCollectionSubtypeSmartAlbumTimelapses),
        //                                    @(PHAssetCollectionSubtypeSmartAlbumBursts),
        //                                    @(PHAssetCollectionSubtypeSmartAlbumPanoramas)];
        _customSmartCollections = @[@(PHAssetCollectionSubtypeSmartAlbumFavorites),
                                    @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
                                    @(PHAssetCollectionSubtypeSmartAlbumPanoramas)];
        
        // If you don't want to show smart collections, just put _customSmartCollections to nil;
        //_customSmartCollections=nil;
        
        // Which media types will display
        //        _mediaTypes = @[@(PHAssetMediaTypeAudio),
        //                        @(PHAssetMediaTypeVideo),
        //                        @(PHAssetMediaTypeImage)];
        _mediaTypes = @[@(PHAssetMediaTypeImage)];
        self.preferredContentSize = kPopoverContentSize;
        
        // UI Customisation
        _pickerBackgroundColor = [UIColor whiteColor];
        _pickerTextColor = [UIColor darkTextColor];
        _pickerFontName = @"HelveticaNeue";
        _pickerBoldFontName = @"HelveticaNeue-Bold";
        _pickerFontNormalSize = 14.0f;
        _pickerFontHeaderSize = 17.0f;
        
        _navigationBarBackgroundColor = [UIColor whiteColor];
        _navigationBarTextColor = [UIColor darkTextColor];
        _navigationBarTintColor = [UIColor darkTextColor];
        
        _toolbarBarTintColor = [UIColor whiteColor];
        _toolbarTextColor = [UIColor darkTextColor];
        _toolbarTintColor = [UIColor darkTextColor];
        
        _pickerStatusBarStyle = UIStatusBarStyleDefault;
        _barStyle = UIBarStyleDefault;
        [self setupNavigationController];
    }
    return self;
}

- (id)init
{
    if (self = [super init]) {
        _selectedAssets = [[NSMutableArray alloc] init];
        
        // Default values:
        _displaySelectionInfoToolbar = YES;
        _displayAlbumsNumberOfAssets = YES;
        _autoDisableDoneButton = YES;
        _allowsMultipleSelection = YES;
        _confirmSingleSelection = NO;
        _showCameraButton = NO;
        
        // Grid configuration:
        if([self.delegate respondsToSelector:@selector(assetsPickerControllerColumnInPortrait)] && [self.delegate respondsToSelector:@selector(assetsPickerControllerColumnInLandscape)]) {
            _colsInPortrait =  [self.delegate assetsPickerControllerColumnInPortrait];
            _colsInLandscape =  [self.delegate assetsPickerControllerColumnInLandscape];
        } else {
            NSOperatingSystemVersion ios10_0_1 = (NSOperatingSystemVersion){10, 0, 1};
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios10_0_1]) {
                    // iOS 8.0.1 and above logic
                    _colsInPortrait = 6;
                    _colsInLandscape = 10;
                } else {
                    // iOS 8.0.0 and below logic
                    _colsInPortrait = 4;
                    _colsInLandscape = 5;
                }
                
            }else{
                _colsInPortrait = 3;
                _colsInLandscape = 5;
            }
        }
        
        _minimumInteritemSpacing = 2.0;
        
        // Sample of how to select the collections you want to display:
        _customSmartCollections = @[@(PHAssetCollectionSubtypeSmartAlbumFavorites),
                                    @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
                                    @(PHAssetCollectionSubtypeSmartAlbumVideos),
                                    @(PHAssetCollectionSubtypeSmartAlbumSlomoVideos),
                                    @(PHAssetCollectionSubtypeSmartAlbumTimelapses),
                                    @(PHAssetCollectionSubtypeSmartAlbumBursts),
                                    @(PHAssetCollectionSubtypeSmartAlbumPanoramas)];
        // If you don't want to show smart collections, just put _customSmartCollections to nil;
        //_customSmartCollections=nil;
        
        // Which media types will display
        _mediaTypes = @[@(PHAssetMediaTypeAudio),
                        @(PHAssetMediaTypeVideo),
                        @(PHAssetMediaTypeImage)];
        
        self.preferredContentSize = kPopoverContentSize;
        
        // UI Customisation
        _pickerBackgroundColor = [UIColor whiteColor];
        _pickerTextColor = [UIColor darkTextColor];
        _pickerFontName = @"HelveticaNeue";
        _pickerBoldFontName = @"HelveticaNeue-Bold";
        _pickerFontNormalSize = 14.0f;
        _pickerFontHeaderSize = 17.0f;
        
        _navigationBarBackgroundColor = [UIColor whiteColor];
        _navigationBarTextColor = [UIColor darkTextColor];
        _navigationBarTintColor = [UIColor darkTextColor];
        
        _toolbarBarTintColor = [UIColor whiteColor];
        _toolbarTextColor = [UIColor darkTextColor];
        _toolbarTintColor = [UIColor darkTextColor];
        
        _pickerStatusBarStyle = UIStatusBarStyleDefault;
        _barStyle = UIBarStyleDefault;
        // Save to the album
        

        
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Ensure nav and toolbar customisations are set. Defaults are in place, but the user may have changed them
    self.view.backgroundColor = _pickerBackgroundColor;
    
    _navigationController.toolbar.translucent = YES;
    _navigationController.toolbar.barTintColor = _toolbarBarTintColor;
    _navigationController.toolbar.tintColor = _toolbarTintColor;
    [(UIView*)[_navigationController.toolbar.subviews firstObject] setAlpha:0.75f];  // URGH - I know!
    
    _navigationController.navigationBar.backgroundColor = _navigationBarBackgroundColor;
    _navigationController.navigationBar.tintColor = _navigationBarTintColor;
    
    _navigationController.navigationBar.barStyle = _barStyle;
    _navigationController.navigationBar.barTintColor = _toolbarBarTintColor;
    
    NSDictionary *attributes;
    if (_useCustomFontForNavigationBar) {
        attributes = @{NSForegroundColorAttributeName : _navigationBarTextColor,
                       NSFontAttributeName : [UIFont fontWithName:_pickerBoldFontName size:_pickerFontHeaderSize]};
    } else {
        attributes = @{NSForegroundColorAttributeName : _navigationBarTextColor};
    }
    _navigationController.navigationBar.titleTextAttributes = attributes;
    
    [self updateToolbar];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _pickerStatusBarStyle;
}


#pragma mark - Setup Navigation Controller

//- (void)setupNavigationController
//{
//    GMAlbumsViewController *albumsViewController = [[GMAlbumsViewController alloc] init];
//    _navigationController = [[UINavigationController alloc] initWithRootViewController:albumsViewController];
//    _navigationController.delegate = self;
//    
//    _navigationController.navigationBar.translucent = YES;
//    [_navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    _navigationController.navigationBar.shadowImage = [UIImage new];
//    
//    [_navigationController willMoveToParentViewController:self];
//    [_navigationController.view setFrame:self.view.frame];
//    [self.view addSubview:_navigationController.view];
//    [self addChildViewController:_navigationController];
//    [_navigationController didMoveToParentViewController:self];
//    
//    if([self.delegate respondsToSelector:@selector(shouldSelectAllAlbumCell)]){
//        if([self.delegate respondsToSelector:@selector(controllerTitle)])
//            self.title = [self.delegate controllerTitle];
//        
//        if([self.delegate respondsToSelector:@selector(controllerCustomDoneButtonTitle)])
//            self.customDoneButtonTitle = [self.delegate controllerCustomDoneButtonTitle];
//        
//        if([self.delegate respondsToSelector:@selector(controllerCustomCancelButtonTitle)])
//            self.customCancelButtonTitle = [self.delegate controllerCustomCancelButtonTitle];
//        
//        if([self.delegate respondsToSelector:@selector(controllerCustomNavigationBarPrompt)])
//            self.customNavigationBarPrompt = [self.delegate controllerCustomNavigationBarPrompt];
//        
//        //        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
//        //        // Check if the user has access to photos
//        //        if (authStatus == PHAuthorizationStatusAuthorized) {
//        //            if([self.delegate shouldSelectAllAlbumCell]){
//        //                [albumsViewController selectAllAlbumsCell];
//        //            }
//        //        }
//    }
//}
- (void)setupNavigationController
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    GMAlbumsViewController *albumsViewController = [[GMAlbumsViewController alloc] init];
    if([self.delegate respondsToSelector:@selector(controllerTitle)]){
        albumsViewController.title = [self.delegate controllerTitle];
    }
    GMGridViewController *gridViewController = [[GMGridViewController alloc] initWithPicker:self];
    gridViewController.title = NSLocalizedStringFromTableInBundle(@"picker.table.all-photos-label",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class], @"All photos");
    
    //All album: Sorted by descending creation date.
    NSMutableArray *allFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *allFetchResultLabel = [[NSMutableArray alloc] init];
    {
        if(![self.mediaTypes isEqual:[NSNull null]] && self != nil){
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            if(_allow_video){
                _mediaTypes = @[@(PHAssetMediaTypeImage),@(PHAssetMediaTypeVideo)];
            }
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", self.mediaTypes];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsWithOptions:options];
            
            [allFetchResultArray addObject:assetsFetchResult];
            [allFetchResultLabel addObject:NSLocalizedStringFromTableInBundle(@"picker.table.all-photos-label",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class], @"All photos")];
        }
    }
    
    albumsViewController.collectionsFetchResultsAssets= @[allFetchResultArray];
    albumsViewController.collectionsFetchResultsTitles= @[allFetchResultLabel];
    
    
    gridViewController.assetsFetchResults = [[albumsViewController.collectionsFetchResultsAssets objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    
    _navigationController = [[UINavigationController alloc] initWithRootViewController:albumsViewController];
    _navigationController.delegate = self;
    
    
    //    _navigationController.navigationBar.translucent = YES;
    //    [_navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    //    _navigationController.navigationBar.shadowImage = [UIImage new];
    
    [_navigationController willMoveToParentViewController:self];
    [_navigationController.view setFrame:self.view.frame];
    [self.view addSubview:_navigationController.view];
    [self addChildViewController:_navigationController];
    [_navigationController didMoveToParentViewController:self];
    
    
    // Push GMGridViewController
    [_navigationController pushViewController:gridViewController animated:YES];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Only if OK was pressed do we want to completge the selection
        [self finishPickingAssets:self];
    }
}


#pragma mark - Select / Deselect Asset

- (void)selectAsset:(PHAsset *)asset
{
    [self.selectedAssets insertObject:asset atIndex:self.selectedAssets.count];
    [self updateDoneButton];
    
    if (!self.allowsMultipleSelection) {
        if (self.confirmSingleSelection) {
            NSString *message = self.confirmSingleSelectionPrompt ? self.confirmSingleSelectionPrompt : [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"picker.confirm.message",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"Do you want to select the image you tapped on?")];
            
            [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"picker.confirm.title",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"Are You Sure?")]
                                        message:message
                                       delegate:self
                              cancelButtonTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"picker.action.no",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"No")]
                              otherButtonTitles:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"picker.action.yes",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"Yes")], nil] show];
        } else {
            [self finishPickingAssets:self];
        }
    } else if (self.displaySelectionInfoToolbar || self.showCameraButton) {
        [self updateToolbar];
    }
}

- (void)deselectAsset:(PHAsset *)asset
{
    [self.selectedAssets removeObjectAtIndex:[self.selectedAssets indexOfObject:asset]];
    if (self.selectedAssets.count == 0) {
        [self updateDoneButton];
    }
    
    if (self.displaySelectionInfoToolbar || self.showCameraButton) {
        [self updateToolbar];
    }
}

- (void)updateDoneButton
{
    if (!self.allowsMultipleSelection) {
        return;
    }
    
    UINavigationController *nav = (UINavigationController *)self.childViewControllers[0];
    for (UIViewController *viewController in nav.viewControllers) {
        viewController.navigationItem.rightBarButtonItem.enabled = (self.autoDisableDoneButton ? self.selectedAssets.count > 0 : TRUE);
    }
}

- (void)updateToolbar
{
    if (!self.allowsMultipleSelection && !self.showCameraButton) {
        return;
    }
    
    UINavigationController *nav = (UINavigationController *)self.childViewControllers[0];
    for (UIViewController *viewController in nav.viewControllers) {
        NSUInteger index = 1;
        if (_showCameraButton) {
            index++;
        }
        [[viewController.toolbarItems objectAtIndex:index] setTitleTextAttributes:[self toolbarTitleTextAttributes] forState:UIControlStateNormal];
        [[viewController.toolbarItems objectAtIndex:index] setTitleTextAttributes:[self toolbarTitleTextAttributes] forState:UIControlStateDisabled];
        [[viewController.toolbarItems objectAtIndex:index] setTitle:[self toolbarTitle]];
        [viewController.navigationController setToolbarHidden:(self.selectedAssets.count == 0 && !self.showCameraButton) animated:YES];
    }
}


#pragma mark - User finish Actions

- (void)dismiss:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)]) {
        [self.delegate assetsPickerControllerDidCancel:self];
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)finishPickingAssets:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)]) {
        [self.delegate assetsPickerController:self didFinishPickingAssets:self.selectedAssets];
    }
}


#pragma mark - Toolbar Title

- (NSPredicate *)predicateOfAssetType:(PHAssetMediaType)type
{
    return [NSPredicate predicateWithBlock:^BOOL(PHAsset *asset, NSDictionary *bindings) {
        return (asset.mediaType == type);
    }];
}

- (NSString *)toolbarTitle
{
    if (self.selectedAssets.count == 0) {
        return nil;
    }
    
    NSPredicate *photoPredicate = [self predicateOfAssetType:PHAssetMediaTypeImage];
    NSPredicate *videoPredicate = [self predicateOfAssetType:PHAssetMediaTypeVideo];
    
    NSInteger nImages = [self.selectedAssets filteredArrayUsingPredicate:photoPredicate].count;
    NSInteger nVideos = [self.selectedAssets filteredArrayUsingPredicate:videoPredicate].count;
    
    if (nImages > 0 && nVideos > 0) {
        return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"picker.selection.multiple-items",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"%@ Items Selected" ), @(nImages + nVideos)];
    } else if (nImages > 1) {
        return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"picker.selection.multiple-photos",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"%@ Photos Selected"), @(nImages)];
    } else if (nImages == 1) {
        return NSLocalizedStringFromTableInBundle(@"picker.selection.single-photo",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"1 Photo Selected" );
    } else if (nVideos > 1) {
        return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"picker.selection.multiple-videos",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"%@ Videos Selected"), @(nVideos)];
    } else if (nVideos == 1) {
        return NSLocalizedStringFromTableInBundle(@"picker.selection.single-video",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"1 Video Selected");
    } else {
        return nil;
    }
}


#pragma mark - Toolbar Items

- (void)cameraButtonPressed:(UIBarButtonItem *)button
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Camera!"
                                                                       message:@"Sorry, this device does not have a camera."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                          }];
        [alert addAction:okAction];
        
        return;
    }
    
    // This allows the selection of the image taken to be better seen if the user is not already in that VC
    if (self.autoSelectCameraImages && [self.navigationController.topViewController isKindOfClass:[GMAlbumsViewController class]]) {
        [((GMAlbumsViewController *)self.navigationController.topViewController) selectAllAlbumsCell];
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    picker.videoMaximumDuration = self.videoMaximumDuration;
    if(_allow_video){
        picker.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
        picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    }else{
        picker.mediaTypes = @[(NSString *)kUTTypeImage];
    }
    picker.allowsEditing = self.allowsEditingCameraImages;

    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *popPC = picker.popoverPresentationController;
    popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popPC.barButtonItem = button;
    
    [self showViewController:picker sender:button];
}

- (NSDictionary *)toolbarTitleTextAttributes {
    return @{NSForegroundColorAttributeName : _toolbarTextColor,
             NSFontAttributeName : [UIFont fontWithName:_pickerFontName size:_pickerFontHeaderSize]};
}

- (UIBarButtonItem *)titleButtonItem
{
    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithTitle:self.toolbarTitle
                                                              style:UIBarButtonItemStylePlain
                                                             target:nil
                                                             action:nil];
    
    NSDictionary *attributes = [self toolbarTitleTextAttributes];
    [title setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [title setTitleTextAttributes:attributes forState:UIControlStateDisabled];
    [title setEnabled:NO];
    
    return title;
}

- (UIBarButtonItem *)spaceButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (UIBarButtonItem *)cameraButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonPressed:)];
}

- (NSArray *)toolbarItems
{
    UIBarButtonItem *camera = [self cameraButtonItem];
    UIBarButtonItem *title  = [self titleButtonItem];
    UIBarButtonItem *space  = [self spaceButtonItem];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    if (_showCameraButton && ([[self.navigationController childViewControllers] count] > 1) ) {
        [items addObject:camera];
    }
    [items addObject:space];
    [items addObject:title];
    [items addObject:space];
    
    return [NSArray arrayWithArray:items];
}


#pragma mark - Camera Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerEditedImage] ? : info[UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       @selector(image:finishedSavingWithError:contextInfo:),
                                       nil);
    }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        __block NSURL *movieUrl = info[UIImagePickerControllerMediaURL];
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        if ([PHObject class]) {
            __block PHAssetChangeRequest *assetRequest;
            __block PHObjectPlaceholder *placeholder;
            // Save to the album
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    
                    
                    assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:movieUrl];
                    placeholder = [assetRequest placeholderForCreatedAsset];
                } completionHandler:^(BOOL success, NSError *error) {
                    if (success) {
                        
                        NSLog(@"localIdentifier %@", placeholder.localIdentifier);
                        
                        dispatch_semaphore_signal(sema);
                    }
                    else {
                        NSLog(@"%@", error);
                        dispatch_semaphore_signal(sema);
                    }
                }];
                
            }];
        }
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Image Not Saved"
                                                                       message:@"Sorry, this device does not have a camera."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                          }];
        [alert addAction:okAction];
    }
    
    // Note: The image view will auto refresh as the photo's are being observed in the other VCs
}


- (BOOL)shouldAutorotate
{
    if ([self.delegate respondsToSelector:@selector(shouldAutorotate)]) {
        return [self.delegate shouldAutorotate];
    }
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([self.delegate respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        return [self.delegate supportedInterfaceOrientations];
    }
    return 1 << UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([self.delegate respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)]) {
        return [self.delegate shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
}
@end
