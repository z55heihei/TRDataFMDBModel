//
//  TRDataFMDBModel.h
//  BasePackage
//
//  Created by ZYW on 17/4/28.
//  Copyright © 2017年 ZYW. All rights reserved.
//  该类主要继承EXModel 获取基类属性 存储字段 数据库操作事务（CRUD）
#import <Foundation/Foundation.h>

@interface TRDataFMDBModel : NSObject

/**
 增加到数据库
*/
- (BOOL)addToDB;

/**
 更新数据库
 */
- (BOOL)updateToDB;

/**
 删除表中数据
 */
- (BOOL)deleteToDB;

/**
 删除表
 */
- (BOOL)deleteTable;

/**
 判断数据库中字段是否存在数据
 */
- (BOOL)checkColumnDataExist;

/**
 获取数据库保存地址
 */
- (NSString *)getDBPath;

/**
 获取存储的保存地址
 */
- (NSString *)getStoragePath;

/**
 设置主键
 */
- (NSString *)setPrimaryKey;


/** 
 判断表中是否存在某个数据

 @param name 主键
 @param value 主键值
 */
+ (BOOL)isExistDataInTableColumnName:(NSString *)name ColumnValue:(NSString *)value;

/**
 条件查询SQL语句

 @param format SQL语句
 */
+ (NSString *)findByConditions:(NSString *)format, ...;

/**
 通过SQL语句条件查找数据

 @param conditionsFormat 条件
 */
+ (NSMutableArray *)findDataArrayByConditions:(NSString *)conditionsFormat;


/**
 获取表中数据组装城数组
 */
+ (NSArray *)retrieveArray;

/**
 删除表所有数据
*/
+ (BOOL)deleteToDBRetrieve;

/**
 数组删除表数据
 
 @param retrieveArray 数组数据
 */
+ (BOOL)deleteToDBRetrieve:(NSArray *)retrieveArray;

/**
 删除数据库前几条

 @param num 数目
 */
+ (BOOL)deleteToDBNumlimit:(NSUInteger)num;

/**
 获取存储image路径
 
 @param imageURL 图片URL
 */
+ (NSString *)getImagePath:(NSString *)imageURL;

/**
 存储图片文件
 
 @param URL 图片URL
 */
+ (BOOL)storageImageFile:(NSString *)URL;

@end
