//
//  TRDataFMDBFileUtility.m
//  BasePackage
//
//  Created by ZYW on 17/5/3.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import "TRDataFMDBFileUtility.h"
#include "sys/stat.h"

@implementation TRDataFMDBFileUtility

+ (TRDataFMDBFileUtility *)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static TRDataFMDBFileUtility *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSString *)getDocumentPath{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}

- (NSString *)getTempPath{
    return [[self getDocumentPath]stringByAppendingPathComponent:@"Temp"];
}

- (NSString *)getCachePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0) {
        NSString *cacheDirectory = [paths objectAtIndex:0];
        return cacheDirectory;
    }
    return nil;
}

- (NSString *)creatFolder:(NSString *)folderName
               path:(NSString *)path{
    NSString *folderPath = [NSString stringWithFormat:@"%@/%@",path, folderName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES) ){
        NSError *error;
        BOOL isSuccess = [fileManager createDirectoryAtPath:folderPath
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:&error];
        if (!isSuccess) {
            folderPath = nil;
        }
    }
    return folderPath;
}

- (void)deleteFolder:(NSString *)folderName
                path:(NSString *)path{
    NSString *directory = [NSString stringWithFormat:@"%@/%@",path, folderName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:directory error:nil];
}

- (NSString *)getDocumentPathS:(NSString *)AppendString{
    return [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:AppendString];
}

- (void)deleteFile:(NSString *)filePath{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
}

- (NSString *)getCurrentPath:(NSString *)fileName{
    return [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:fileName];
}

- (BOOL)isCopyFileAtPath:(NSString *)atPath toPath:(NSString *)topath{
    return [[NSFileManager defaultManager] copyItemAtPath:atPath toPath:topath error:nil];
}

- (BOOL)isFolderExists:(NSString *)folderName{
    NSString *directory = [NSString stringWithFormat:@"%@/%@",[self getDocumentPath], folderName];
    return [[NSFileManager defaultManager]fileExistsAtPath:directory];
}

- (BOOL)isFileExists:(NSString *)fileName{
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:fileName];
    return [[NSFileManager defaultManager]fileExistsAtPath:filePath];;
}

- (BOOL)isImage:(NSString *)fullPath{
    NSSet *fileTypeSet = [NSSet setWithObjects:@"jpg", @"png", @"bmp", @"jpeg", nil];
    return [fileTypeSet containsObject:[[fullPath pathExtension] lowercaseString]];
}

- (BOOL)isAudioVideo:(NSString *)fullPath{
    NSSet* fileTypeSet = [NSSet setWithObjects:@"mp3", @"mid", @"mp4", @"3pg", @"mov", @"avi", @"flv", @"rm", @"rmvb", @"ogg", @"wmv", @"m4v", @"wav", @"caf", @"m4v", @"aac", @"aiff", @"dvix",
                          nil];
    return [fileTypeSet containsObject:[[fullPath pathExtension] lowercaseString]];
}

- (BOOL)isVideo:(NSString *)fullPath{
    NSSet* fileTypeSet = [NSSet setWithObjects:@"mid", @"mp4", @"3pg", @"mov", @"avi", @"flv", @"rm", @"rmvb", @"ogg", @"wmv", @"m4v", @"m4v", @"aiff", @"dvix",
                          nil];
    return [fileTypeSet containsObject:[[fullPath pathExtension] lowercaseString]];
}

- (BOOL)isAudio:(NSString *)fullPath{
    NSSet* fileTypeSet = [NSSet setWithObjects:@"mp3", @"mid", @"wav", @"caf", @"m4v", @"aac", nil];
    return [fileTypeSet containsObject:[[fullPath pathExtension] lowercaseString]];
}

- (BOOL)isZipFile:(NSString *)fullPath{
    return [[[fullPath pathExtension] lowercaseString] isEqualToString:(@"zip")];
}

- (BOOL)isRarFile:(NSString *)fullPath{
    return [[[fullPath pathExtension] lowercaseString] isEqualToString:(@"rar")];
}

- (BOOL)isReadableFile:(NSString *)fullPath{
    NSSet* fileTypeSet = [NSSet setWithObjects:@"pdf", @"doc", @"txt", @"xls", @"ppt", @"rtf",
                          @"epub", @"htm", @"html", nil];
    return [fileTypeSet containsObject:[[fullPath pathExtension] lowercaseString]];
}

- (BOOL)saveImageFilePath:(NSString *)path
                    image:(UIImage *)image {
    BOOL isSuccess = NO;
    if (image && path) {
        NSData *imageData = UIImagePNGRepresentation(image);
        isSuccess = [imageData writeToFile:path atomically:NO];
    }
    return isSuccess;
}


+ (void)clearCacheComplete:(void(^)())completeblock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *directoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        
        NSArray *subpaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
        
        for (NSString *subPath in subpaths) {
            NSString *filePath = [directoryPath stringByAppendingPathComponent:subPath];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeblock) {
                completeblock();
            }
        });
    });
}

+ (long long)cacheFileSize:(NSString *)path{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]){
        return [[manager attributesOfItemAtPath:path error:nil] fileSize];
    }
    return 0 ;
}

+ (NSString *)cacheTotalFileSize{
    NSString *cacheTotalSize = @"";
    NSString *folderPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager * manager=[NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) {
        return 0 ;
    }
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator ];
    NSString * fileName;
    long long folderSize = 0 ;
    while ((fileName = [childFilesEnumerator nextObject ]) != nil ){
        NSString * fileAbsolutePath = [folderPath stringByAppendingPathComponent :fileName];
        folderSize += [ self cacheFileSize:fileAbsolutePath];
    }
    
    cacheTotalSize = [NSString stringWithFormat:@"%.2fM",folderSize/(1024.0 * 1024.0)];
    
    return cacheTotalSize;
}

- (NSString *)getCurrentTimeAsFileName{
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc]init];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    return [dateformat stringFromDate:[NSDate date]];
}

- (UIImage *)readImageFilePath:(NSString *)filePath{
    if (filePath) {
        return [UIImage imageWithContentsOfFile:filePath];
    }
    return nil;
}

- (NSMutableDictionary *)findZipFileForKey:(NSString *)key{
    NSMutableDictionary *pramsDict = [NSMutableDictionary dictionary];
    NSMutableArray *zipArray = [NSMutableArray array];
    NSMutableArray *pathArray = [NSMutableArray array];
    NSDirectoryEnumerator *enmerator = [[NSFileManager defaultManager] enumeratorAtPath:[self getDocumentPath]];
    for (NSString *relativePath in enmerator){
        if (enmerator.level == 1) {
            NSArray *array = [relativePath componentsSeparatedByString:@"/"];
            NSString *fileName = [[array lastObject] stringByReplacingOccurrencesOfString:key withString:@""];
            [zipArray addObject:fileName];
            [pathArray addObject:[self getCurrentPath:relativePath]];
        }
    }
    [pramsDict setObject:zipArray forKey:@"zipArray"];
    [pramsDict setObject:pathArray forKey:@"pathArray"];
    return pramsDict;
}

@end
