//
//  PCFileDownloadManager.m
//  WineHound
//
//  Created by Mark Turner on 27/02/2014.
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

////

#import <AFNetworking/AFNetworking.h>
#import "PCFileDownloadManager.h"

@interface PCFileDownloadManager ()
@property (nonatomic,weak) AFHTTPRequestOperation * downloadOperation;
@end

@implementation PCFileDownloadManager

#pragma mark
#pragma mark

- (void)cancel
{
    [self.downloadOperation cancel];
}

- (void)downloadURL:(NSURL *)url
      progressBlock:(void(^)(CGFloat progress))progressBlock
         completion:(void(^)(NSString * filePath, NSError * error))completion
{
    NSString * filePath = [self filePathForURL:url];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == YES) {
        if (completion != nil) {
            completion(filePath,nil);
        }
    } else {
        NSURLRequest * urlRequest = [[NSURLRequest alloc] initWithURL:url];
        if (_downloadOperation == nil) {
            
            if ([AFHTTPRequestOperation canProcessRequest:urlRequest]) {
                
                NSString * tempDownloadDirectory = [[[self class] _tempDirectory] stringByAppendingString:@"temp"];
                NSError * createDirectoryError = nil;
                BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:tempDownloadDirectory
                                                         withIntermediateDirectories:NO
                                                                          attributes:nil
                                                                               error:&createDirectoryError];
                if (success == NO) {
                    NSLog(@"Create directory failure: %@",createDirectoryError);
                }
                
                NSString * tempDownloadPath = [tempDownloadDirectory stringByAppendingPathComponent:[[url absoluteString] md5]];
                void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSFileManager * fileManager = [NSFileManager defaultManager];
                    if ([fileManager fileExistsAtPath:filePath] == YES) {
                        NSError * error = nil;
                        [fileManager removeItemAtPath:filePath error:&error];
                    }
                    
                    NSError * transferError = nil;
                    if ([fileManager moveItemAtPath:tempDownloadPath toPath:filePath error:&transferError] == TRUE) {
                        if (completion != nil) {
                            completion(filePath,nil);
                        }
                    } else {
                        NSLog(@"Unable to move file: %@",transferError);
                        if (completion != nil) {
                            completion(nil,transferError);
                        }
                    }
                    //Clean up temp download directory
                    [fileManager removeItemAtPath:tempDownloadDirectory error:nil];
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
                                                 }];
                
                [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:tempDownloadPath append:NO]];
                [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                    //NSLog(@"Download pogress: %lu - %lld - %lld",(unsigned long)bytesRead,totalBytesRead,totalBytesExpectedToRead);
                    if (progressBlock != nil) {
                        progressBlock((float)totalBytesRead/(float)totalBytesExpectedToRead);
                    }
                }];
                
                _downloadOperation = operation;
                
                [operation start];
                
            } else {
                NSLog(@"Download is already in operation");
            }
        }
    }
}

#pragma mark

- (NSString *)filePathForURL:(NSURL *)url
{
    NSString * pathExtension = [[url absoluteString] pathExtension];
    NSString * md5 = [[[url absoluteString] md5] stringByAppendingPathExtension:pathExtension];
    return  [[[self class] _tempDirectory] stringByAppendingPathComponent:md5];
}

+ (NSString *)_tempDirectory
{
    NSString * tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"downloads"];
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


@end
