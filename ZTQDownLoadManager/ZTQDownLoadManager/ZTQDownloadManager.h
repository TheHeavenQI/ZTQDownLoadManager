//
//  ZTQDownloadManager.h
//  ZTQNotificationShowView
//
//  Created by Ztq on 2017/6/9.
//  Copyright © 2017年 jiafakeji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

#define RootFielPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

#define DownLoadFilePath(fileName) [RootFielPath stringByAppendingPathComponent:fileName]

#define ZTQDownFilesPlist [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"downloadFiles.plist"]

#define AlreadyDownloadLenth(fileName) [[[NSFileManager defaultManager] attributesOfItemAtPath:DownLoadFilePath(fileName) error:nil][@"NSFileSize"] integerValue]

#define ZTQMD5String(urlString) ({ const char* character = [urlString UTF8String]; \
    unsigned char result[CC_MD5_DIGEST_LENGTH]; \
    CC_MD5(character, (CC_LONG)strlen(character), result); \
    NSMutableString *md5String = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH]; \
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) \
    { \
        [md5String appendFormat:@"%02x",result[i]]; \
    } \
    md5String ? md5String: @"null"; \
})

typedef void(^successHandler)(NSString * _Nonnull filePath);
typedef void(^failureHandler)(NSError * _Nullable error);
typedef void(^progressHandler)(NSProgress * _Nonnull downloadProgress);

@interface ZTQDownloadManager : NSObject

/**
 输出流
 */
@property (strong, nonatomic, readonly) NSOutputStream * _Nullable stream;

/**
 请求
 */
@property (strong, nonatomic, readonly) NSURLSession * _Nullable session;

/**
 任务
 */
@property (strong, nonatomic, readonly) NSURLSessionDataTask * _Nullable task;

/**
 下载的总长
 */
@property (assign, nonatomic, readonly) NSInteger totleLenth;

/**
 已下载的长度
 */
@property (assign, nonatomic, readonly) NSInteger downloadLenth;

@property (copy, nonatomic) successHandler _Nullable success;

@property (copy, nonatomic) failureHandler _Nullable failure;

@property (copy, nonatomic) progressHandler _Nullable progresshandler;

/**
 获取单例对象

 @return            唯一单例对象
 */
+ (instancetype _Nonnull)shareManager;

/**
 下载任意文件
 
 @param url                 文件路径
 @param fileName            保存的文件名
 @param header              是否需要配置header
 @param customHeaderField   自定义header的key
 @param progress            下载进度
 @param success             下载成功的回调
 @param failure             下载失败的回调
 @return                    返回当前下载的任务
 */
+ (NSURLSessionDataTask * _Nullable)downloadWithURL:(NSString * _Nullable)url
                                           fileName:(NSString * _Nullable)fileName
                                             header:(NSDictionary *_Nullable)header
                                  customHeaderField:(NSString * _Nullable)customHeaderField
                                           progress:(progressHandler _Nullable)progress
                                     successHandler:(successHandler _Nullable)success
                                     failureHandler:(failureHandler _Nullable)failure;




@end

