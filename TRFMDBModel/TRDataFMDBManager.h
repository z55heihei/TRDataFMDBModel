//
//  TRDataFMDBManager.h
//  BasePackage
//
//  Created by ZYW on 17/4/28.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
#import "TRDataFMDBFileUtility.h"

@interface TRDataFMDBManager : NSObject

/**
 * 数据库
 */
@property (nonatomic,strong) FMDatabase *dbase;

/**
 * 数据库队列
 */
@property (nonatomic,strong) FMDatabaseQueue *fmDBQueue;

/**
 是否需要debug打印（默认打开）
 */
@property (nonatomic,assign) BOOL isDebugPrint;

/**
 创建数据库单例
 */
+ (TRDataFMDBManager *)shareInstance;

/**
 获取数据库对象
 */
- (FMDatabase *)getDatabase;

/**
 获取数据库队列
 */
- (FMDatabaseQueue *)getDBQueue;

/**
 获取数据保存地址
 */
- (NSString *)getDBPath;

/**
 获取存储路径
 */
- (NSString *)getDBStoragePath;


/**
 判断是否存在表

 @param tableName 表名字
 */
- (BOOL)isExistTable:(NSString *)tableName;

/**
 是否打印debug数据库操作

 @param isDebug 开关
 */
- (void)setDebugPrint:(BOOL)isDebug;

/**
 删除数据库中的所有表
 */
- (void)dropAllTableOfDB;

/**
 提示数据库是否存在且可添加字段

 @param columnName 字段名
 @param table 表名
 */
- (void)alterItemTableToAddFilterColunm:(NSString *)columnName
                             addToTable:(NSString *)table;

/**
 判断是否数据库可添加字段

 @param columnName 字段名
 @param table 表名
 */
- (BOOL)checkFilterColumnExists:(NSString *)columnName
                      fromTable:(NSString *)table;

/**
 提示数据库是否可添加字段
 
 @param columnName 字段名
 @param table 表名
 */
- (void)alterItemTableToAddColumn:(NSString *)columnName
                       addToTable:(NSString *)table;

@end
