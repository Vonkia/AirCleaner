//
//  PictureSelector.m
//  PictureSelector
//
//  Created by iwevon on 2017/8/13.
//  Copyright © 2017年 vonkia. All rights reserved.
//

#import "PictureSelector.h"
#import <objc/runtime.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIView+Layout.h"
#import "TZImageManager.h"
#import "TZLocationManager.h"
#import "TZImagePickerController.h"

static char *PictureSelectorKey = "PictureSelectorKey";
@interface PictureSelector () <TZImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

// 图片选择回调
@property (copy, nonatomic) void(^singleSelectBlock)(UIImage *picture);
@property (copy, nonatomic) void(^multiSelectBlock)(NSArray <UIImage *>*pictures);


@property (nonatomic, strong) UIImagePickerController *imagePickerVc;

//显示的控制器
@property (nonatomic, weak) UIViewController *viewController;
// 设置开关
@property (assign, nonatomic, getter=isShowTakePhotoBtn) BOOL showTakePhotoBtn;  ///< 在内部显示拍照按钮
@property (assign, nonatomic, getter=isSortAscending) BOOL sortAscending;     ///< 照片排列按修改时间升序
@property (assign, nonatomic, getter=isAllowPickingVideo) BOOL allowPickingVideo; ///< 允许选择视频
@property (assign, nonatomic, getter=isAllowPickingImage) BOOL allowPickingImage; ///< 允许选择图片
@property (assign, nonatomic, getter=isAllowPickingGif) BOOL allowPickingGif;
@property (assign, nonatomic, getter=isAllowPickingOriginalPhoto) BOOL allowPickingOriginalPhoto; ///< 允许选择原图
@property (assign, nonatomic, getter=isShowSheet) BOOL showSheet; ///< 显示一个sheet,把拍照按钮放在外面
@property (assign, nonatomic) NSUInteger maxCount;  ///< 照片最大可选张数，设置为1即为单选模式
@property (assign, nonatomic) NSUInteger columnNumber;
@property (assign, nonatomic, getter=isAllowCrop) BOOL allowCrop;
@property (assign, nonatomic, getter=isNeedCircleCrop) BOOL needCircleCrop;
@property (assign, nonatomic, getter=isAllowPickingMuitlpleVideo) BOOL allowPickingMuitlpleVideo;
@property (nonatomic, assign) CGFloat photoWidth; ///<导出图片的宽度，默认828像素宽
@end

@implementation PictureSelector

#pragma mark - public

/// 单选
+ (void)pictureSelectorWithVisible:(UIViewController *)viewController showSheet:(BOOL)showSheet singleSelectPhotoFinish:(void(^)(UIImage *picture))finishBlock {
    PictureSelector *selector = [[PictureSelector alloc] init];
    selector.viewController = viewController;
    selector.showSheet = showSheet;
    selector.singleSelectBlock = finishBlock;
    [selector showPhotoController];
}

/// 多选
+ (void)pictureSelectorWithVisible:(UIViewController *)viewController maxCount:(NSUInteger)maxCount multiSelectPhotoFinish:(void(^)(NSArray <UIImage *>*pictures))finishBlock {
    PictureSelector *selector = [[PictureSelector alloc] init];
    selector.viewController = viewController;
    selector.maxCount = maxCount;
    selector.multiSelectBlock = finishBlock;
    [selector showPhotoController];
}


- (void)showPhotoController {
    if (self.isShowSheet) {
        __weak typeof(self) weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf takePhoto];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"从手机相册上传" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf pushTZImagePickerController];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [weakSelf.viewController presentViewController:alertController animated:YES completion:nil];
    } else {
        [self pushTZImagePickerController];
    }
}

- (void)dealloc {
    NSLog(@"dealloc");
}


#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupSwitch];
    }
    return self;
}

- (void)setupSwitch {
    // 设置开关
    self.showTakePhotoBtn = NO;
    self.sortAscending = YES;     ///< 照片排列按修改时间升序
    self.allowPickingVideo = NO; ///< 允许选择视频
    self.allowPickingImage = YES; ///< 允许选择图片
    self.allowPickingGif = NO;
    self.allowPickingOriginalPhoto = NO; ///< 允许选择原图
    self.showSheet = NO; ///< 显示一个sheet,把拍照按钮放在外面
    self.maxCount = 1;  ///< 照片最大可选张数，设置为1即为单选模式
    self.columnNumber = 4;
    self.allowCrop = NO;
    self.needCircleCrop = NO;
    self.allowPickingMuitlpleVideo = NO;
    self.photoWidth = [UIScreen mainScreen].bounds.size.width;
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = self.viewController.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.viewController.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (iOS9Later) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}

- (void)setViewController:(UIViewController *)viewController {
    _viewController = viewController;
    //关联属性，强引用
    objc_setAssociatedObject(viewController, PictureSelectorKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - UIImagePickerController

- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) && iOS7Later) {
        // 无相机权限 做一个友好的提示
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        if (iOS7Later) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self takePhoto];
                    });
                }
            }];
        } else {
            [self takePhoto];
        }
        // 拍照之前还需要检查相册权限
    } else if ([TZImageManager authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        alert.tag = 1;
        [alert show];
    } else if ([TZImageManager authorizationStatus] == 0) { // 未请求过相册权限
        [[TZImageManager manager] requestAuthorizationWithCompletion:^{
            [self takePhoto];
        }];
    } else {
        [self pushImagePickerController];
    }
}

// 调用相机
- (void)pushImagePickerController {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVc.sourceType = sourceType;
        if(iOS8Later) {
            _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        [self.viewController presentViewController:_imagePickerVc animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
        //照片排列按修改时间升序
        tzImagePickerVc.sortAscendingByModificationDate = self.isSortAscending;
        [tzImagePickerVc showProgressHUD];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        // save photo and get asset / 保存图片，获取到asset
        [[TZImageManager manager] savePhotoWithImage:image location:nil completion:^(NSError *error){
            if (error) {
                [tzImagePickerVc hideProgressHUD];
                NSLog(@"图片保存失败 %@",error);
            } else {
                [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES completion:^(TZAlbumModel *model) {
                    [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
                        [tzImagePickerVc hideProgressHUD];
                        TZAssetModel *assetModel = [models firstObject];
                        if (tzImagePickerVc.sortAscendingByModificationDate) {
                            assetModel = [models lastObject];
                        }
                        if (self.isAllowCrop) { // 允许裁剪,去裁剪
                            TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initCropTypeWithAsset:assetModel.asset photo:image completion:^(UIImage *cropImage, id asset) {
                                [self refreshCollectionViewWithAddedAsset:asset image:cropImage];
                            }];
                            imagePicker.needCircleCrop = self.isNeedCircleCrop;
                            imagePicker.circleCropRadius = 100;
                            [self.viewController presentViewController:imagePicker animated:YES completion:nil];
                        } else {
                            [self refreshCollectionViewWithAddedAsset:assetModel.asset image:image];
                        }
                    }];
                }];
            }
        }];
    }
}

- (void)refreshCollectionViewWithAddedAsset:(id)asset image:(UIImage *)image {

    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = asset;
        NSLog(@"location:%@",phAsset.location);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - TZImagePickerController

- (void)pushTZImagePickerController {
    if (self.maxCount <= 0) {
        return;
    }
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:self.maxCount columnNumber:self.columnNumber delegate:self pushPhotoPickerVc:YES];
    // imagePickerVc.navigationBar.translucent = NO;
    
#pragma mark - 五类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.allowTakePicture = self.isShowTakePhotoBtn; // 在内部显示拍照按钮
    // imagePickerVc.photoWidth = 1000;
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    // imagePickerVc.navigationBar.translucent = NO;
    
    // 3. Set allow picking video & photo & originalPhoto or not
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = self.isAllowPickingVideo;
    imagePickerVc.allowPickingImage = self.isAllowPickingImage;
    imagePickerVc.allowPickingOriginalPhoto = self.isAllowPickingOriginalPhoto;
    imagePickerVc.allowPickingGif = self.isAllowPickingGif;
    imagePickerVc.allowPickingMultipleVideo = self.isAllowPickingMuitlpleVideo; // 是否可以多选视频
    imagePickerVc.photoWidth = self.photoWidth; // 导出图片的宽度
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = self.isSortAscending;
    
    // imagePickerVc.minImagesCount = 3;
    // imagePickerVc.alwaysEnableDoneBtn = YES;
    
    // imagePickerVc.minPhotoWidthSelectable = 3000;
    // imagePickerVc.minPhotoHeightSelectable = 2000;
    
    /// 5. Single selection mode, valid when maxImagesCount = 1
    /// 5. 单选模式,maxImagesCount为1时才生效
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = self.isAllowCrop;
    imagePickerVc.needCircleCrop = self.isNeedCircleCrop;
    // 设置竖屏下的裁剪尺寸
    NSInteger left = 30;
    NSInteger widthHeight = self.viewController.view.tz_width - 2 * left;
    NSInteger top = (self.viewController.view.tz_height - widthHeight) / 2;
    imagePickerVc.cropRect = CGRectMake(left, top, widthHeight, widthHeight);
    // 设置横屏下的裁剪尺寸
    // imagePickerVc.cropRectLandscape = CGRectMake((self.view.tz_height - widthHeight) / 2, left, widthHeight, widthHeight);
    /*
     [imagePickerVc setCropViewSettingBlock:^(UIView *cropView) {
     cropView.layer.borderColor = [UIColor redColor].CGColor;
     cropView.layer.borderWidth = 2.0;
     }];*/
    
    //imagePickerVc.allowPreview = NO;
    
    imagePickerVc.isStatusBarDefault = NO;
#pragma mark - 到这里为止
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
    }];
    
    [self.viewController presentViewController:imagePickerVc animated:YES completion:nil];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        if (iOS8Later) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } else {
            NSURL *privacyUrl;
            if (alertView.tag == 1) {
                privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"];
            } else {
                privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"];
            }
            if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
                [[UIApplication sharedApplication] openURL:privacyUrl];
            } else {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"抱歉" message:@"无法跳转到隐私设置页面，请手动前往设置页面，谢谢" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
}


#pragma mark - TZImagePickerControllerDelegate

/// User click cancel button
/// 用户点击了取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    // NSLog(@"cancel");
}

// The picker should dismiss itself; when it dismissed these handle will be called.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    // 1.打印图片名字
    [self printAssetsName:assets];
    // 2.图片位置信息
    if (iOS8Later) {
        for (PHAsset *phAsset in assets) {
            NSLog(@"location:%@",phAsset.location);
        }
    }
    // 回调
    self.singleSelectBlock ? self.singleSelectBlock(photos.firstObject) : nil;
    self.multiSelectBlock ? self.multiSelectBlock(photos) : nil;
}

// If user picking a video, this callback will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    
}

// If user picking a gif image, this callback will be called.
// 如果用户选择了一个gif图片，下面的handle会被执行
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset {

}

// Decide album show or not't
// 决定相册显示与否
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(id)result {
    /*
     if ([albumName isEqualToString:@"个人收藏"]) {
        return NO;
     }
     if ([albumName isEqualToString:@"视频"]) {
        return NO;
     }*/
    return YES;
}

// Decide asset show or not't
// 决定asset显示与否
- (BOOL)isAssetCanSelect:(id)asset {
    /*
    if (iOS8Later) {
        PHAsset *phAsset = asset;
        switch (phAsset.mediaType) {
            case PHAssetMediaTypeVideo: {
                // 视频时长
                // NSTimeInterval duration = phAsset.duration;
                return NO;
            } break;
            case PHAssetMediaTypeImage: {
                // 图片尺寸
                if (phAsset.pixelWidth > 3000 || phAsset.pixelHeight > 3000) {
                    // return NO;
                }
                return YES;
            } break;
            case PHAssetMediaTypeAudio:
                return NO;
                break;
            case PHAssetMediaTypeUnknown:
                return NO;
                break;
            default: break;
        }
    } else {
        ALAsset *alAsset = asset;
        NSString *alAssetType = [[alAsset valueForProperty:ALAssetPropertyType] stringValue];
        if ([alAssetType isEqualToString:ALAssetTypeVideo]) {
            // 视频时长
            // NSTimeInterval duration = [[alAsset valueForProperty:ALAssetPropertyDuration] doubleValue];
            return NO;
        } else if ([alAssetType isEqualToString:ALAssetTypePhoto]) {
            // 图片尺寸
            CGSize imageSize = alAsset.defaultRepresentation.dimensions;
            if (imageSize.width > 3000) {
                // return NO;
            }
            return YES;
        } else if ([alAssetType isEqualToString:ALAssetTypeUnknown]) {
            return NO;
        }
    }
     */
    return YES;
}


#pragma mark - Private

/// 打印图片名字
- (void)printAssetsName:(NSArray *)assets {
    NSString *fileName;
    for (id asset in assets) {
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = (PHAsset *)asset;
            fileName = [phAsset valueForKey:@"filename"];
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = (ALAsset *)asset;
            fileName = alAsset.defaultRepresentation.filename;;
        }
        // NSLog(@"图片名字:%@",fileName);
    }
}

@end
