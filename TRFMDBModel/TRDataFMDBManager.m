//
//  TRDataFMDBManager.m
//  BasePackage
//
//  Created by ZYW on 17/4/28.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import "TRDataFMDBManager.h"

#define DB_FILE_FOLDER_NAME @"DB"

@interface TRDataFMDBManager ()

- (BOOL)initDatabase;

@end

@implementation TRDataFMDBManager

+ (TRDataFMDBManager *)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static TRDataFMDBManager *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[self alloc] init];
        if (nil != instance) {
            if (NO == [instance initDatabase]) {
                instance = nil;
                NSLog(@"%@ %@ 数据库初始化失败!",self.class, NSStringFromSelector(_cmd));
            }
        }
    });
    return instance;
}

- (FMDatabase *)getDatabase{
    return self.dbase;
}

- (FMDatabaseQueue*) getDBQueue{
    return self.fmDBQueue;
}

- (NSString *)getDBStoragePath{
    //获取cache文件夹路径
    NSString *DBFolderPath;
    NSString *documentDirectory = [[TRDataFMDBFileUtility shareInstance] getCachePath];
    if (documentDirectory) {
        //创建数据库文件夹
       DBFolderPath = [[TRDataFMDBFileUtility shareInstance] creatFolder:DB_FILE_FOLDER_NAME
                                                                               path:documentDirectory];
    }
    return DBFolderPath;
}

- (NSString *)dataBasePath{
    //获取应用名称
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appDisplayName = infoDictionary[@"CFBundleName"];
    NSString *dbPath;
    NSString *DBFolderPath = [self getDBStoragePath];
    if (DBFolderPath) {
        //创建数据库sqlite文件路径
        NSString *dbfileName = [NSString stringWithFormat:@"%@.sqlite",appDisplayName];
        dbPath = [DBFolderPath stringByAppendingPathComponent:dbfileName];
    }
    return dbPath;
}

- (BOOL)initDatabase{
    BOOL bRet = NO;
    NSString *dataBasePath = [self dataBasePath];
    self.dbase = [FMDatabase databaseWithPath:dataBasePath];
    //默认打开
    self.isDebugPrint = NO;
    if (self.dbase) {
        if ([self.dbase open]) {
            bRet = YES;
        }else {
            if (self.isDebugPrint) {
                NSLog(@"%@ %@ 不能打开数据库！",self.class, NSStringFromSelector(_cmd));
            }
            [self.dbase close];
        }
    }
    
    self.fmDBQueue = [FMDatabaseQueue databaseQueueWithPath:dataBasePath];
    if (nil == self.fmDBQueue){
        if (self.isDebugPrint) {
            NSLog(@"创建数据库错误！");
        }
    }
    
    return bRet;
}

- (NSString *)getDBPath{
    return [self dataBasePath];
}

- (void)alterItemTableToAddFilterColunm:(NSString *)columnName
                             addToTable:(NSString *)table{
    if ([self.dbase tableExists:table]) {
        if (![self checkFilterColumnExists:columnName
                                 fromTable:table]) {
            [self alterItemTableToAddColumn:columnName
                                 addToTable:table];
        }
    }
}

- (BOOL)isExistTable:(NSString *)tableName{
    BOOL isExistTable = NO;
    FMDatabase * db = [FMDatabase databaseWithPath:[self getDBPath]];
	BOOL canOpen = [db open];
    if (canOpen) {
        NSString * sql = [[NSString alloc]initWithFormat:@"select name from sqlite_master where type = 'table' and name = '%@'",tableName];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            NSString *name = [rs stringForColumn:@"name"];
            if ([name isEqualToString:tableName]){
                isExistTable = 1;
            }
        }
        [db close];
    }
    return isExistTable;
}

- (BOOL)checkFilterColumnExists:(NSString *)columnName
                      fromTable:(NSString *)table{
    __block BOOL returnBool = NO;
    [self.fmDBQueue inDatabase:^(FMDatabase *db) {
        [db open];
        FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"PRAGMA table_info(%@)", table]];
        while ([resultSet next]) {
            if ([[resultSet stringForColumn:@"name"] isEqualToString: columnName]) {
                returnBool = YES;
                break;
            }
        }
        [db close];
    }];
    
    return returnBool;
}

- (void)setDebugPrint:(BOOL)isDebug{
    self.isDebugPrint = isDebug;
}

- (void)alterItemTableToAddColumn:(NSString *)columnName
                       addToTable:(NSString *)table{
    NSString *alterSql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ TEXT DEFAULT ''", table,columnName, nil];
    [self.fmDBQueue inDatabase:^(FMDatabase *db) {
        [db open];
        
        if ([db executeUpdate:alterSql]) {
            if (self.isDebugPrint) {
                NSLog(@"%@ %@数据库是否可添加字段成功！",self.class, NSStringFromSelector(_cmd));
            }
        } else {
            if (self.isDebugPrint) {
                NSLog(@"%@ %@数据库是否可添加字段错误！",self.class, NSStringFromSelector(_cmd));
            }
        }
        [db close];
    }];
}

- (void)dropAllTableOfDB{
    [self.fmDBQueue inDatabase:^(FMDatabase* db){
        FMResultSet* set = [db executeQuery:@"select name from sqlite_master where type='table'"];
        NSMutableArray* dropTables = [NSMutableArray arrayWithCapacity:0];
        while ([set next]) {
            [dropTables addObject:[set stringForColumnIndex:0]];
        }
        [set close];
        for (NSString* tableName in dropTables) {
            NSString* dropTable = [NSString stringWithFormat:@"drop table %@",tableName];
            [db executeUpdate:dropTable];
        }
    }];
}


@end
