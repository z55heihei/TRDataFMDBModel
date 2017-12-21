//
//  TRDataFMDBModel+FileStorage.h
//  BasePackage
//
//  Created by ZYW on 17/5/3.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import "TRDataFMDBModel.h"

@interface TRDataFMDBModel (FileStorage)

/**
 保存图片

 @param URL 图片URL
 @param path 保存路径
 */
+ (UIImage *)saveImageFileFromURL:(NSString *)URL
                            path:(NSString *)path;

/**
 获取存储路径
 @param imageURL 图片URL
 */
+ (NSString *)getPathImageURL:(NSURL *)imageURL;

@end
