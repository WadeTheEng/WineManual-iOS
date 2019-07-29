//
//  WHPDFViewController.m
//  WineHound
//
//  Created by Mark Turner on 30/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

@interface NSString (MD5)
- (NSString *)md5;
@end

static inline NSString *NSStringCCHashFunction(unsigned char *(function)(const void *data, CC_LONG len, unsigned char *md), CC_LONG digestLength, NSString *string)
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[digestLength];
    
    function(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:digestLength * 2];
    
    for (int i = 0; i < digestLength; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@implementation NSString (MD5)

- (NSString *)md5
{
    return NSStringCCHashFunction(CC_MD5, CC_MD5_DIGEST_LENGTH, self);
}

@end

#import <AFNetworking/AFNetworking.h>
/*
#import <QuickLook/QuickLook.h>
*/

#import "WHPDFViewController.h"
#import "WHProgressView.h"
#import "WHLoadingHUD.h"

@interface WHPDFViewController () //<QLPreviewControllerDelegate,QLPreviewControllerDataSource>
//@property (nonatomic,weak) QLPreviewController * quickLookViewController;
@property (nonatomic,weak) AFHTTPRequestOperation * downloadOperation;
@property (nonatomic,weak) UIWebView * webView;
@end

@implementation WHPDFViewController

#pragma mark 

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self download];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_downloadOperation cancel];
    [WHLoadingHUD dismiss];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat yOrigin =.0f;
    yOrigin += CGRectGetHeight(self.navigationController.navigationBar.bounds);
    yOrigin += [UIApplication sharedApplication].statusBarFrame.size.height;

    [_webView.scrollView setContentInset:(UIEdgeInsets){
        .top = 0.0,
    }];
    [_webView.scrollView setScrollIndicatorInsets:_webView.scrollView.contentInset];
    [_webView setFrame:(CGRect){
        .origin.x = 0.0,
        .origin.y = yOrigin,
        .size.width  = CGRectGetWidth(self.view.frame),
        .size.height = CGRectGetHeight(self.view.frame) - yOrigin,
    }];
    
//    [_quickLookViewController.view setFrame:(CGRect){
//        .origin.x = 0.0,
//        .origin.y = 0.0,
//        .size.width  = CGRectGetWidth(self.view.frame),
//        .size.height = CGRectGetHeight(self.view.frame),
//    }];
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

#pragma mark 
#pragma mark

- (void)download
{
    if (self.pdfURL != nil) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath] == YES) {
            [self _displayPDF];
        } else {
            NSString * filePath = self.filePath;
            
            NSURLRequest * urlRequest = [[NSURLRequest alloc] initWithURL:self.pdfURL];
            if (_downloadOperation == nil) {
                
                if ([AFHTTPRequestOperation canProcessRequest:urlRequest]) {
                    
                    NSString * tempDownloadDirectory = [[[self class] _tempDirectory] stringByAppendingString:@"temp"];

                    //If directory doesn't exist create it.
                    
                    //else delete contents.
                    
                    NSError * createDirectoryError = nil;
                    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:tempDownloadDirectory
                                                             withIntermediateDirectories:NO
                                                                              attributes:nil 
                                                                                   error:&createDirectoryError];
                    if (success == NO) {
                        NSLog(@"Create directory failure: %@",createDirectoryError);
                    }
                    
                    NSString * tempDownloadPath = [tempDownloadDirectory stringByAppendingPathComponent:[[self.pdfURL absoluteString] md5]];
                    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSFileManager * fileManager = [NSFileManager defaultManager];
                        
                        //remove file if already exists
                        if ([fileManager fileExistsAtPath:filePath] == YES) {
                            NSError * error = nil;
                            [fileManager removeItemAtPath:filePath error:&error];
                        }
                        
                        //transfer file from temp download dir
                        
                        NSError * transferError = nil;
                        if ([fileManager moveItemAtPath:tempDownloadPath
                                                 toPath:filePath
                                                  error:&transferError] == TRUE) {
                            [self _displayPDF];
                        } else {
                            NSLog(@"Unable to move file: %@",transferError);
                        }
                        
                        //Clean up temp download directory
                        [fileManager removeItemAtPath:tempDownloadDirectory error:nil];
                        
                        [WHProgressView dismiss];
                    };
                    
                    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
                    [operation setCompletionBlockWithSuccess:successBlock
                                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         NSLog(@"Error: %@", error);
                                                         if (error.code == NSURLErrorCancelled) {
                                                             /*
                                                              [SVProgressHUD dismiss];
                                                              */
                                                         }
                                                         
                                                         //Clean up temp download directory
                                                         [[NSFileManager defaultManager] removeItemAtPath:tempDownloadDirectory error:nil];
                                                         
                                                         [WHProgressView dismiss];
                                                     }];
                    
                    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:tempDownloadPath append:NO]];
                    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                        NSLog(@"PDF download pogress: %lu - %lld - %lld",(unsigned long)bytesRead,totalBytesRead,totalBytesExpectedToRead);
                        
                        [WHProgressView setProgress:((float)totalBytesRead/(float)totalBytesExpectedToRead)];
                    }];
                    
                    _downloadOperation = operation;

                    [operation start];
                    
                    [WHLoadingHUD dismiss];
                    [WHProgressView show];
                    
                } else {
                    NSLog(@"Download is already in operation");
                }   
            }
        }
    }
}

#pragma mark

- (NSString *)filePath
{
    NSString * md5 = [[[self.pdfURL absoluteString] md5] stringByAppendingPathExtension:@"pdf"];
    return  [[[self class] _tempDirectory] stringByAppendingPathComponent:md5];
}

+ (NSString *)_tempDirectory
{
    NSString * tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"pdf"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
        const char *tempDirectoryTemplateCString = [tempPath fileSystemRepresentation];
        char * tempDirectoryNameCString = (char *)malloc(strlen(tempDirectoryTemplateCString) + 1);
        strcpy(tempDirectoryNameCString, tempDirectoryTemplateCString);
        
        char *result = mkdtemp(tempDirectoryNameCString);
        if (!result)
        {
            NSLog(@"Directory creation failed");
        }
        
        NSString *tempDirectoryPath = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:tempDirectoryNameCString length:strlen(result)];
        free(tempDirectoryNameCString);
        
        return tempDirectoryPath;
    } else {
        return tempPath;
    }
}

- (void)_displayPDF
{
    if (_webView == nil) {
        NSURLRequest * pdfRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.filePath]];
        
        UIWebView * webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        [webView loadRequest:pdfRequest];
        [webView setScalesPageToFit:YES];
        [self.view addSubview:webView];
        
        _webView = webView;
    }
    
//    if (_quickLookViewController == nil) {
//        QLPreviewController* qlp = [[QLPreviewController alloc] init];
//        [qlp setDelegate:self];
//        [qlp setDataSource:self];
//        [qlp reloadData];
//        [qlp setAutomaticallyAdjustsScrollViewInsets:YES];
//    
//        [self addChildViewController:qlp];
//        [self.view addSubview:qlp.view];
//        
//        [qlp didMoveToParentViewController:self];
//        
//        _quickLookViewController = qlp;
//        
//        [self setNeedsStatusBarAppearanceUpdate];
//    }
}

#pragma mark 
#pragma mark QLPreviewControllerDataSource

//- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
//{
//    return 1;
//}
//
//- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
//{
//    return [NSURL fileURLWithPath:self.filePath];
//}

@end
