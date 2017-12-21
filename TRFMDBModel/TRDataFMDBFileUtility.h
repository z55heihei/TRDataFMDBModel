//
//  TRDataFMDBFileUtility.h
//  BasePackage
//
//  Created by ZYW on 17/5/3.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TRDataFMDBFileUtility : NSObject

+ (TRDataFMDBFileUtility *)shareInstance;

/**
 创建文件夹

 @param folderName 文件名称
 @param path 路径
 */
- (NSString *)creatFolder:(NSString *)folderName
                     path:(NSString *)path;

/**
 删除文件
 
 @param folderName 文件名称
 @param path 路径
 */
- (void)deleteFolder:(NSString *)folderName
                path:(NSString *)path;

/**
 
 @param filePath 文件路径
 */
- (void)deleteFile:(NSString *)filePath;

/**
 是否存在该文件夹

 @param folderName 文件夹名称
 */
- (BOOL)isFolderExists:(NSString *)folderName;

/**
 是否存在该文件

 @param fileName 文件名
 */
- (BOOL)isFileExists:(NSString *)fileName;

/**
 判断是否是图片

 @param extension 后缀名
 */
- (BOOL)isImage:(NSString *)extension;

/**
 判断是否是否是语音或者是视频文件

 @param fullPath 文件路径
 */
- (BOOL)isAudioVideo:(NSString *)fullPath;

/**
 判断是否是否是视频文件
 
 @param fullPath 文件路径
 */
- (BOOL)isVideo:(NSString *)fullPath;

/**
 判断是否是否是语音文件
 
 @param fullPath 文件路径
 */
- (BOOL)isAudio:(NSString *)fullPath;

/**
 判断是否是否是zip压缩包文件
 
 @param fullPath 文件路径
 */
- (BOOL)isZipFile:(NSString *)fullPath;

/**
 判断是否是否是rar压缩包文件
 
 @param fullPath 文件路径
 */
- (BOOL)isRarFile:(NSString *)fullPath;

/**
 判断是否是否是可读未损坏文件
 
 @param fullPath 文件路径
 */
- (BOOL)isReadableFile:(NSString *)fullPath;

/**
 拷贝文件从一个路径到另一个路径
 */
- (BOOL)isCopyFileAtPath:(NSString *)atPath toPath:(NSString *)topath;

/**
 保存数据库文件

 @param path 路径
 @param image 图片
 */
- (BOOL)saveImageFilePath:(NSString *)path
                    image:(UIImage *)image;

/**
 *  清空缓存
 */
+ (void)clearCacheComplete:(void(^)())completeblock;

/**
 *  某个路径下缓存大小
 *  @param path 路径
 */
+ (long long)cacheFileSize:(NSString *)path;

/**
 *  计算缓存大小
 *
 */
+ (NSString *)cacheTotalFileSize;

/**
 获取当前时间作文件名 （时间格式：yyyyMMddHHmmss）
 */
- (NSString *)getCurrentTimeAsFileName;


/**
 读取存储的图片

 @param filePath 图片路径
 */
- (UIImage *)readImageFilePath:(NSString *)filePath;

/**
 获取document路径
 */
- (NSString *)getDocumentPath;

/**
 获取Temp路径
 */
- (NSString *)getTempPath;

/**
 获取cache路径
 */
- (NSString *)getCachePath;

/**
 获取当前文件路径

 @param fileName 文件名
 */
- (NSString *)getCurrentPath:(NSString *)fileName;

/**
 通过key压缩打包文件

 @param key 标识符
 */
- (NSMutableDictionary *)findZipFileForKey:(NSString *)key;

@end
