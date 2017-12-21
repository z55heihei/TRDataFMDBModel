//
//  TRDataFMDBModel+FileStorage.m
//  BasePackage
//
//  Created by ZYW on 17/5/3.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import "TRDataFMDBModel+FileStorage.h"
#import "TRDataFMDBFileUtility.h"
#import <SDWebImage/SDWebImageManager.h>
#import "TRDataFMDBManager.h"

@implementation TRDataFMDBModel (FileStorage)

+ (UIImage *)saveImageFileFromURL:(NSString *)URL
                            path:(NSString *)path{
    __block UIImage *saveImage = nil;
	NSURL *imageURL = [NSURL URLWithString:URL];
    SDWebImageDownloaderProgressBlock  downloadBlock = ^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL){
        NSString *receivedSizeStr = [NSString stringWithFormat:@"%ld",(long)receivedSize];
        NSString *expectedSizeStr = [NSString stringWithFormat:@"%ld",(long)expectedSize];
        float progressValue = ([receivedSizeStr floatValue]/[expectedSizeStr floatValue]);
        if ([TRDataFMDBManager shareInstance].isDebugPrint) {
            NSLog(@"下载进度:%f %@ %@",progressValue,self.class, NSStringFromSelector(_cmd));
        }
    };

    SDWebImageDownloaderCompletedBlock completeBlcok = ^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished){
        if (image && finished) {
            //延迟一秒保存，区分文件名字
            NSString *fileName = [[imageURL absoluteString] lastPathComponent];
            NSString *filePth = [path stringByAppendingPathComponent:fileName];
            [[TRDataFMDBFileUtility shareInstance]saveImageFilePath:filePth
                                                        image:image];
            saveImage = image;
            if ([TRDataFMDBManager shareInstance].isDebugPrint) {
                NSLog(@"%@ %@ 图片保存成功!",self.class, NSStringFromSelector(_cmd));
            }
        }
        if (error) {
            if ([TRDataFMDBManager shareInstance].isDebugPrint) {
                NSLog(@"%@ %@ %@ \n下载失败！",self.class, NSStringFromSelector(_cmd),error);
            }
        }
    };
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:imageURL
											options:SDWebImageDownloaderContinueInBackground progress:downloadBlock 
											completed:completeBlcok];
    return saveImage;
}

+ (NSString *)getPathImageURL:(NSURL *)imageURL{
	//数据库路径
	NSString *DBPath = [[TRDataFMDBManager shareInstance] getDBStoragePath];
	//文件名
	NSString *fileName = [[imageURL absoluteString] lastPathComponent];
	//文件路径
	NSString *filePth = [DBPath stringByAppendingPathComponent:fileName];
	
	return filePth;
}

@end
