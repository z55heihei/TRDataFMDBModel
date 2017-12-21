//
//  TRDataFMDBModel.m
//  BasePackage
//
//  Created by ZYW on 17/4/28.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import "TRDataFMDBModel.h"
#import "TRDataFMDBManager.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "TRDataFMDBModel+FileStorage.h"

@interface TRDataFMDBModel()
/**
 创建表，一个EXModel对应一个表 表名为继承者类名
 */
- (BOOL)createTable;

/**
 是否存在表
 */
- (BOOL)isExistTable;

/**
 获取该Model属属性值
 */
- (NSMutableArray *)getModelPropertyValueArray:(Class)class;

@end

@implementation TRDataFMDBModel

- (instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString *)setPrimaryKey{
    return @"";
}

- (NSString *)getDBPath{
    return [[TRDataFMDBManager shareInstance] getDBPath];
}

- (NSString *)getStoragePath{
    return [[TRDataFMDBManager shareInstance] getDBStoragePath];
}

- (NSArray *)fetchPropertyList:(Class)class{
    unsigned int count = 0;
    //获取继承TRDataFMDB的类中属性
    //添加包含的属性
    //生成数组
    objc_property_t *propertyList = class_copyPropertyList(class, &count);
    NSMutableArray *mutableList = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int i = 0; i < count; i++ ) {
		objc_property_t property = propertyList[i];
		//获取属性类型等参数
		NSString *propertyType = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
		//判断是否是NSString类型
		if ([propertyType hasPrefix:@"T@\"NSString\""]) {
			const char *propertyName = property_getName(property);
			[mutableList addObject:[NSString stringWithUTF8String: propertyName]];
		}
    }
    free(propertyList);
    return [NSArray arrayWithArray:mutableList];
}

//通过字符串来创建该字符串的Setter方法，并返回
- (SEL)creatGetterWithPropertyName:(NSString *)propertyName{
    return NSSelectorFromString(propertyName);
}

- (NSMutableArray *)getModelPropertyValueArray:(Class)class{
    //获取实体类的属性名
    NSArray *array = [self fetchPropertyList:class];
    NSMutableArray *propertyValueArray = [NSMutableArray array];
    //遍历添加到数组中
    for (int i = 0; i < array.count; i ++) {
        //添加到数组中
        NSObject *returnValue = [self getPropertyVaule:array[i]];
		//判断是否为空，为空时置为空字符串
        if (!returnValue) {
            returnValue = @"";
        }
		[propertyValueArray addObject:returnValue];
    }
    return propertyValueArray;
}

- (NSObject *)getPropertyVaule:(NSString *)propertyName{
    //接收返回的值
    NSObject *__unsafe_unretained returnValue = nil;
    //获取get方法
    SEL getSel = [self creatGetterWithPropertyName:propertyName];
    if ([self respondsToSelector:getSel]) {
        //获得类和方法的签名
        NSMethodSignature *signature = [self methodSignatureForSelector:getSel];
        //从签名获得调用对象
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        //设置target
        [invocation setTarget:self];
        //设置selector
        [invocation setSelector:getSel];
        //调用
        [invocation invoke];
        //接收返回值
        [invocation getReturnValue:&returnValue];
    }
    return returnValue;
}

//判断是不是继承的类
- (BOOL)superClassfilter{
	return [NSStringFromClass([self superclass]) isEqualToString:NSStringFromClass([TRDataFMDBModel class])];
}

- (void)setCreateTableClass:(Class)class sqlstring:(NSMutableString *)sqlstring{
	NSArray *propertyArray = [self fetchPropertyList:class];
	//暂时全部保存为string类型
	[propertyArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		NSString *columnName = obj;
		//设置主键
		NSString *setPrimaryKey = [self setPrimaryKey];
		if ([setPrimaryKey length] > 0 && [columnName isEqualToString:setPrimaryKey]) {
			[sqlstring appendFormat:@"%@", [NSString stringWithFormat:@"%@ TEXT primary key,",columnName]];
		}else{
			[sqlstring appendFormat:@"%@", [NSString stringWithFormat:@"%@ TEXT,",columnName]];
		}
	}];
}

- (BOOL)createTable{
    //根据主键创建表
    __block BOOL isSuccess = NO;
    __weak typeof(self)blockSelf = self;
    [[TRDataFMDBManager shareInstance].fmDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *tableName = [NSString stringWithFormat:@"%@",NSStringFromClass([self class])];
        NSMutableString *sqlString = [[NSMutableString alloc] init];
        if([self superclass] != [NSObject class]){
			//获取子类属性sql
			[blockSelf setCreateTableClass:[self class] sqlstring:sqlString];
			
			//判断是否是继承的类，如果是，并且获取父类的属性，然后组装再生成表
			BOOL isHaveSuperClass = [self superClassfilter];
			if (!isHaveSuperClass) {
				[blockSelf setCreateTableClass:[self superclass] sqlstring:sqlString];
			}

			//sql语句去除，保持正确语句
            if (sqlString) {
                [sqlString deleteCharactersInRange:NSMakeRange([sqlString length]-1, 1)];
            }
          
			//创建表
            NSString *createTableSqlString = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@);",tableName,sqlString];
            isSuccess = [db executeUpdate:createTableSqlString];
            
            if (isSuccess) {
                if ([TRDataFMDBManager shareInstance].isDebugPrint) {
                    NSLog(@"%@ %@ 数据表创建成功!",self.class, NSStringFromSelector(_cmd));
                }
            }else{
                if ([TRDataFMDBManager shareInstance].isDebugPrint) {
                    NSLog(@"%@ %@ 数据表创建失败!",self.class, NSStringFromSelector(_cmd));
                }
            }
        }else{
            if ([TRDataFMDBManager shareInstance].isDebugPrint) {
                NSLog(@"%@ %@ 没有继承TRDataFMDBModel!",self.class, NSStringFromSelector(_cmd));
            }
        }
    }];
    return isSuccess;
}

- (BOOL)isExistTable{
	BOOL isExist = 	[[TRDataFMDBManager shareInstance].dbase tableExists:NSStringFromClass([self class])];
    return isExist;
}

- (BOOL)checkColumnDataExist{
    //判断是否已经插入
    __block BOOL isExist = NO;
    [[TRDataFMDBManager shareInstance].fmDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *primaryKey = [self setPrimaryKey];
        if (primaryKey) {
            NSString *tableName = [NSString stringWithFormat:@"%@",NSStringFromClass([self class])];
            NSString *querySql = [NSString stringWithFormat:@"SELECT COUNT(%@) AS countNum FROM %@ WHERE %@ = ?",primaryKey,tableName,primaryKey];
            NSObject *primaryValue = [self getPropertyVaule:primaryKey];
            FMResultSet *rs = [db executeQuery:querySql
                          withArgumentsInArray:@[primaryValue]];
            while ([rs next]) {
                NSInteger count = [rs intForColumn:@"countNum"];
                isExist = count > 0;
            }
        }
    }];
    
    if ([TRDataFMDBManager shareInstance].isDebugPrint) {
        if (isExist) {
            NSLog(@"%@ %@ 该数据已经存在",self.class, NSStringFromSelector(_cmd));
		}
    }
    
    return isExist;
}

- (void)setAddToDBClass:(Class)class insertNameSqlString:(NSMutableString *)insertNameSqlString insertValueSqlString:(NSMutableString *)insertValueSqlString{
	NSArray *propertyArray = [self fetchPropertyList:class];
	//遍历属性插入值
	[propertyArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		NSString *columnName = obj;
		//添加数据
		[insertNameSqlString appendFormat:@"%@", [NSString stringWithFormat:@"%@,",columnName]];
		[insertValueSqlString appendString:@"?,"];
	}];
}

- (BOOL)addToDB{
    //初始化开始创建表
    if (![self isExistTable]) {
        [self createTable];
    }
    
    //判断数据库表是否存在
    if (self != [TRDataFMDBModel self] && [self isExistTable]) {
        //判断是否存在这个字段的数据
		//存在做更新操作不进行添加操作
		if ([self checkColumnDataExist]) {
			[self updateToDB];
			return NO;
		}
		
        __block BOOL isSuccess = NO;
        NSString *tableName = [NSString stringWithFormat:@"%@",NSStringFromClass([self class])];
        NSMutableString *insertNameSqlString = [[NSMutableString alloc] init];
        NSMutableString *insertValueSqlString = [[NSMutableString alloc] init];
        		
		//判断是否是继承的类，如果是，并且获取父类的属性，然后组装再生成表
		BOOL isHaveSuperClass = [self superClassfilter];		

		//获取子类属性的值
		NSMutableArray *classpropertyArray = [self getModelPropertyValueArray:[self class]];
		if (!isHaveSuperClass) {
			//获取父类属性的值
			NSMutableArray *superClasspropertyArray = [self getModelPropertyValueArray:[self superclass]];
			[classpropertyArray addObjectsFromArray:superClasspropertyArray];
		}
		__block NSMutableArray *propertyValurArray = [NSMutableArray arrayWithArray:classpropertyArray];
		
		//获取子类属性sql
		[self setAddToDBClass:[self class] insertNameSqlString:insertNameSqlString insertValueSqlString:insertValueSqlString];	
		//获取子类属性sql
		if (!isHaveSuperClass) {
			[self setAddToDBClass:[self superclass] insertNameSqlString:insertNameSqlString insertValueSqlString:insertValueSqlString];
		}
		
        //去除SQL语句的逗号
        if (insertNameSqlString.length > 0) {
            [insertNameSqlString deleteCharactersInRange:NSMakeRange([insertNameSqlString length]-1, 1)];
        }
        //去除SQL语句的逗号
        if (insertValueSqlString.length > 0) {
            [insertValueSqlString deleteCharactersInRange:NSMakeRange([insertValueSqlString length]-1, 1)];
        }
        
        __block NSString *insertSqlString = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@);",tableName,insertNameSqlString,insertValueSqlString];

		//判断Model的属性值，是否赋值，并且执行插入操作
        if ([propertyValurArray count] > 0) {
            [[TRDataFMDBManager shareInstance].fmDBQueue inDatabase:^(FMDatabase *db) {		
                isSuccess = [db executeUpdate:insertSqlString
                         withArgumentsInArray:propertyValurArray];
            }];
        }else{
            if ([TRDataFMDBManager shareInstance].isDebugPrint) {
                NSLog(@"该Model还未赋值 %@ %@",self.class, NSStringFromSelector(_cmd));
            }
        }
        
        if (isSuccess) {
            if ([TRDataFMDBManager shareInstance].isDebugPrint) {
                NSLog(@"%@ %@ %@ 插入成功! ",[[TRDataFMDBManager shareInstance] getDBStoragePath],self.class, NSStringFromSelector(_cmd));
            }
        }else{
            if ([TRDataFMDBManager shareInstance].isDebugPrint) {
                NSLog(@"%@ %@ %@ 插入失败!",[[TRDataFMDBManager shareInstance] getDBStoragePath],self.class, NSStringFromSelector(_cmd));
            }
        }
        
        return isSuccess;
    }
    return NO;
}

- (void)setUpdateToDBClass:(Class)class updateSqlString:(NSMutableString *)updateSqlString{
	NSString *tableName = [NSString stringWithFormat:@"%@",NSStringFromClass([self class])];
	NSArray *propertyArray = [self fetchPropertyList:class];
	//遍历属性插入值
	[propertyArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		NSString *columnName = obj;
		//添加字段
		[self addParameter:columnName TableName:tableName];
		//更新
		[updateSqlString appendFormat:@"%@=?,", columnName];
	}];
}

- (BOOL)updateToDB{
	//判断是否存在表
	if (![self isExistTable]) {
		return NO;
	}

    __block BOOL isSuccess = NO;
    NSString *tableName = [NSString stringWithFormat:@"%@",NSStringFromClass([self class])];
    NSMutableString *updateKeySqlString = [[NSMutableString alloc] init];
	//获取子类属性sql
	[self setUpdateToDBClass:[self class] updateSqlString:updateKeySqlString];
	
	//判断是否是继承的类，如果是，并且获取父类的属性，然后组装再生成表
	BOOL isHaveSuperClass = [self superClassfilter];	
	if (!isHaveSuperClass) {
		//获取父类属性sql
		[self setUpdateToDBClass:[self superclass] updateSqlString:updateKeySqlString];
	}
	
    //去除SQL语句的逗号
    if (updateKeySqlString.length > 0) {
        [updateKeySqlString deleteCharactersInRange:NSMakeRange([updateKeySqlString length]-1, 1)];
    }
    
    //判断是否有主键
    //执行更新操作
    NSString *primaryKey = [self setPrimaryKey];
	__block NSString *updateSqlString;
	NSObject *primaryValue;
    if (primaryKey) {
		primaryValue = [self getPropertyVaule:primaryKey];
		updateSqlString = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = ?;", tableName, updateKeySqlString,primaryKey];
		
	}else{
        if ([TRDataFMDBManager shareInstance].isDebugPrint) {
            NSLog(@"%@ %@ 未设置主键!",self.class, NSStringFromSelector(_cmd));
        }
		updateSqlString = [NSString stringWithFormat:@"UPDATE %@ SET %@ ;", tableName, updateKeySqlString];
    }
	
	//获取子类属性的值
	NSMutableArray *classpropertyArray = [self getModelPropertyValueArray:[self class]];
	if (!isHaveSuperClass) {
		//获取父类属性的值
		NSMutableArray *superClasspropertyArray = [self getModelPropertyValueArray:[self superclass]];
		[classpropertyArray addObjectsFromArray:superClasspropertyArray];
	}
	__block NSMutableArray *propertyValurArray = [NSMutableArray arrayWithArray:classpropertyArray];
	
	if (primaryValue) {
		[propertyValurArray addObject:primaryValue];
	}
	
	[[TRDataFMDBManager shareInstance].fmDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
		isSuccess = [db executeUpdate:updateSqlString
				 withArgumentsInArray:propertyValurArray];
	}];
    
    if (isSuccess) {
        if ([TRDataFMDBManager shareInstance].isDebugPrint) {
            NSLog(@"%@ %@ %@ 更新成功!",[[TRDataFMDBManager shareInstance] getDBStoragePath],self.class, NSStringFromSelector(_cmd));
        }
    }else{
        if ([TRDataFMDBManager shareInstance].isDebugPrint) {
            NSLog(@"%@ %@ %@ 更新失败!",[[TRDataFMDBManager shareInstance] getDBStoragePath],self.class, NSStringFromSelector(_cmd));
        }
    }
    
    return isSuccess;
}

- (BOOL)deleteToDB{
    __block BOOL isSuccess = NO;
    NSString *tableName = [NSString stringWithFormat:@"%@",NSStringFromClass([self class])];
    NSString *primaryKey = [self setPrimaryKey];
    NSString *deleteSqlString = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",tableName,primaryKey];
    //判断是否有主键
    //执行更新操作
    if (primaryKey) {
        NSObject *primaryValue = [self getPropertyVaule:primaryKey];
        [[TRDataFMDBManager shareInstance].fmDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            isSuccess = [db executeUpdate:deleteSqlString
                     withArgumentsInArray:@[primaryValue]];
        }];
    }else{
        if ([TRDataFMDBManager shareInstance].isDebugPrint) {
            NSLog(@"%@ %@ 未设置主键!",self.class, NSStringFromSelector(_cmd));
        }
    }
    
    if (isSuccess) {
        if ([TRDataFMDBManager shareInstance].isDebugPrint) {
            NSLog(@"%@ %@ 删除数据成功!",self.class, NSStringFromSelector(_cmd));}

    }else{
        if ([TRDataFMDBManager shareInstance].isDebugPrint) {
            NSLog(@"%@ %@ 删除数据失败!",self.class, NSStringFromSelector(_cmd));
        }
    }
    
    return isSuccess;
}

- (BOOL)deleteTable{
    __block BOOL isSuccess = NO;
    NSString *tableName = [NSString stringWithFormat:@"%@",NSStringFromClass([self class])];
    NSString *deleteSqlString = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
    //删除表操作
    [[TRDataFMDBManager shareInstance].fmDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        isSuccess = [db executeUpdate:deleteSqlString];
    }];
    
    if (isSuccess) {
        if ([TRDataFMDBManager shareInstance].isDebugPrint) {
            NSLog(@"%@ %@ %@ 删除表成功!",[[TRDataFMDBManager shareInstance] getDBStoragePath],self.class, NSStringFromSelector(_cmd));
        }
    }else{
        if ([TRDataFMDBManager shareInstance].isDebugPrint) {
            NSLog(@"%@ %@ %@ 删除表失败!",[[TRDataFMDBManager shareInstance] getDBStoragePath],self.class, NSStringFromSelector(_cmd));
        }
    }
    
    return isSuccess;
}

+ (BOOL)deleteToDBRetrieve{
	return [self deleteToDBRetrieve:[self retrieveArray]];
}

+ (BOOL)deleteToDBRetrieve:(NSArray *)retrieveArray{
	BOOL isSuccess = NO;
	BOOL isExist = [[TRDataFMDBManager shareInstance] isExistTable:NSStringFromClass([self class])];
	if (!isExist) {
		if ([TRDataFMDBManager shareInstance].isDebugPrint) {
			NSLog(@"%@ %@ %@不存在表!",[[TRDataFMDBManager shareInstance] getDBStoragePath],self.class, NSStringFromSelector(_cmd));
		}
		return NO;
	}
	[retrieveArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		//获取移除对象
		TRDataFMDBModel *objectModel = obj;
		//移除
		[objectModel deleteToDB];
	}];
	return isSuccess;
}

+ (BOOL)deleteToDBNumlimit:(NSUInteger)num{
	__block BOOL isSuccess = NO;
	BOOL isExist = [[TRDataFMDBManager shareInstance] isExistTable:NSStringFromClass([self class])];
	if (!isExist) {
		if ([TRDataFMDBManager shareInstance].isDebugPrint) {
			NSLog(@"%@ %@ %@不存在表!",[[TRDataFMDBManager shareInstance] getDBStoragePath],self.class, NSStringFromSelector(_cmd));
		}
		return NO;
	}
	NSString *tableName = [NSString stringWithFormat:@"%@",NSStringFromClass([self class])];
	NSString *deleteSqlString = [NSString stringWithFormat:@"DELETE FROM %@ %@",tableName,[self findByConditions:@"limit %@",[NSString stringWithFormat:@"%lu",(unsigned long)num]]];
	
	[[TRDataFMDBManager shareInstance].fmDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
		isSuccess = [db executeUpdate:deleteSqlString];
	}];
	
	if (isSuccess) {
		if ([TRDataFMDBManager shareInstance].isDebugPrint) {
			NSLog(@"%@ %@ 删除数据成功!",self.class, NSStringFromSelector(_cmd));}
		
	}else{
		if ([TRDataFMDBManager shareInstance].isDebugPrint) {
			NSLog(@"%@ %@ 删除数据失败!",self.class, NSStringFromSelector(_cmd));
		}
	}
	return isSuccess;
}

+ (NSArray *)retrieveArray{
	//判断是否存在表
    BOOL isExist = [[TRDataFMDBManager shareInstance] isExistTable:NSStringFromClass([self class])];
    if (!isExist) {
        if ([TRDataFMDBManager shareInstance].isDebugPrint) {
            NSLog(@"%@ %@ %@不存在表!",[[TRDataFMDBManager shareInstance] getDBStoragePath],self.class, NSStringFromSelector(_cmd));
        }
        return nil;
    }
    __block NSMutableArray *returnArray = [NSMutableArray array];
    [[TRDataFMDBManager shareInstance].fmDBQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = [NSString stringWithFormat:@"%@",NSStringFromClass([self class])];
        NSString *searchSql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
        FMResultSet *resultSet = [db executeQuery:searchSql];
        //遍历读取数据库中数据
        while ([resultSet next]) {
            TRDataFMDBModel *objectModel = [self buildDataModel:resultSet];
            [returnArray addObject:objectModel];
            //释放
            FMDBRelease(objectModel);
        }
    }];
    return [NSArray arrayWithArray:returnArray];
}

+ (TRDataFMDBModel *)buildDataModel:(FMResultSet *)resultSet{
    TRDataFMDBModel *objectModel = [[self.class alloc] init];
    //获取Model下所有属性
    unsigned int count = 0;
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    NSMutableArray *mutableList = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int i = 0; i < count; i++ ) {
		objc_property_t property = propertyList[i];
		//获取属性类型等参数
		NSString *propertyType = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
		//判断是否是NSString类型
		if ([propertyType hasPrefix:@"T@\"NSString\""]) {
			const char *propertyName = property_getName(property);
			[mutableList addObject:[NSString stringWithUTF8String: propertyName]];
		}

    }
    free(propertyList);
    //遍历属性
    //数据库中数据对Model赋值
    //添加到数据库中
    [mutableList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = obj;
        NSString *value = [resultSet stringForColumn:key];
        [objectModel setValue:value forKey:key];
    }];
    return objectModel;
}

- (BOOL)addParameter:(NSString *)parameter TableName:(NSString *)table {
	@synchronized (self) {
		//判断字段是否存在
		if (![[TRDataFMDBManager shareInstance].dbase columnExists:parameter inTableWithName:table]) { //不存在 直接添加
			NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ text",table,parameter];
			return [[TRDataFMDBManager shareInstance].dbase executeUpdate:sql];
		}else {//存在就直接返回NO
			return NO;
		}
	}
}

+ (BOOL)isExistDataInTableColumnName:(NSString *)name ColumnValue:(NSString *)value{
    BOOL isExist = NO;
    NSString *conditionsFormat = [self findByConditions:@"WHERE %@=%@",name,value];
    NSMutableArray *results = [self findDataArrayByConditions:conditionsFormat];
    if (results.count > 0) {
        return YES;
    }
    return isExist;
}

+ (BOOL)storageImageFile:(NSString *)URL{
    UIImage *image = nil;
    if (URL) {
        NSString *DBPath = [[TRDataFMDBManager shareInstance] getDBStoragePath];
        if (DBPath) {
            image = [self saveImageFileFromURL:URL
                                          path:DBPath];
        }
    }
    return image == nil;
}

+ (NSString *)getImagePath:(NSString *)imageURL{
    if (imageURL) {
        return [self getPathImageURL:[NSURL URLWithString:imageURL]];
    }
    return nil;
}

//参考：http://www.numbergrinder.com/2008/12/variable-arguments-varargs-in-objective-c/
+ (NSString *)findByConditions:(NSString *)format, ...{
    va_list args;
    va_start(args, format);
    NSString *conditionsFormat = [[NSString alloc] initWithFormat:format
                                                      locale:[NSLocale currentLocale]
                                                    arguments:args];
    va_end(args);
    return conditionsFormat;
}

+ (NSMutableArray *)findDataArrayByConditions:(NSString *)conditionsFormat{
	//判断是否存在表
	BOOL isExist = [[TRDataFMDBManager shareInstance] isExistTable:NSStringFromClass([self class])];
	if (!isExist) {
		if ([TRDataFMDBManager shareInstance].isDebugPrint) {
			NSLog(@"%@ %@ %@不存在表!",[[TRDataFMDBManager shareInstance] getDBStoragePath],self.class, NSStringFromSelector(_cmd));
		}
		return nil;
	}
    __block NSMutableArray *returnArray = [NSMutableArray array];
    [[TRDataFMDBManager shareInstance].fmDBQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ %@",tableName,conditionsFormat];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            TRDataFMDBModel *objectModel = [[self.class alloc] init];
            //获取Model下所有属性
            unsigned int count = 0;
            objc_property_t *propertyList = class_copyPropertyList([self class], &count);
            NSMutableArray *mutableList = [NSMutableArray arrayWithCapacity:count];
            for (unsigned int i = 0; i < count; i++ ) {
				objc_property_t property = propertyList[i];
				//获取属性类型等参数
				NSString *propertyType = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
				//判断是否是NSString类型
				if ([propertyType hasPrefix:@"T@\"NSString\""]) {
					const char *propertyName = property_getName(property);
					[mutableList addObject:[NSString stringWithUTF8String: propertyName]];
				}
            }
            free(propertyList);
            //遍历属性
            //数据库中数据对Model赋值
            //添加到数据库中
            [mutableList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *key = obj;
                NSString *value = [resultSet stringForColumn:key];
                [objectModel setValue:value forKey:key];
            }];

            [returnArray addObject:objectModel];
            FMDBRelease(model);
        }
    }];
    return returnArray;
}

@end
