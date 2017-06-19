//
//  ZTQDownloadManager.m
//  ZTQNotificationShowView
//
//  Created by Ztq on 2017/6/9.
//  Copyright © 2017年 jiafakeji. All rights reserved.
//

#import "ZTQDownloadManager.h"

@interface ZTQDownloadManager () <NSURLSessionDataDelegate>

@property (strong, nonatomic, readwrite) NSOutputStream * stream;

@property (strong, nonatomic, readwrite) NSURLSession * session;

@property (strong, nonatomic, readwrite) NSURLSessionDataTask * task;

@property (assign, nonatomic, readwrite) NSInteger totleLenth;

@property (assign, nonatomic, readwrite) NSInteger downloadLenth;

@property (copy, nonatomic, readwrite) NSString *urlString;

@property (strong, nonatomic, readwrite) NSDictionary *customHeader;

@property (copy, nonatomic, readwrite) NSString *customHeaderField;

@property (copy, nonatomic, readwrite) NSString *fileName;

@property (copy, nonatomic, readwrite) NSString *customHeaderString;

@end

@implementation ZTQDownloadManager

#pragma mark - public methods

+ (instancetype)shareManager {
    static ZTQDownloadManager *m;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        m = [[ZTQDownloadManager alloc] init];
    });
    return m;
}

+ (NSURLSessionDataTask *)downloadWithURL:(NSString *)url
                                 fileName:(NSString *)fileName
                                   header:(NSDictionary *)header
                        customHeaderField:(NSString * _Nullable)customHeaderField
                                 progress:(progressHandler _Nullable)progress
                           successHandler:(successHandler _Nullable)success
                           failureHandler:(failureHandler _Nullable)failure
{
    NSURL *URL;
    if (url.length == 0) {
        NSError *error =[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:@{NSLocalizedFailureReasonErrorKey:@"请求地址错误"}];
        if (failure) {
            failure(error);
        }
        return nil;
    }
    
    if ([url hasPrefix:@"http"]) {
        URL = [NSURL URLWithString:url];
    }else {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", url]];
    }
    
    [ZTQDownloadManager shareManager].urlString = URL.absoluteString;
    [ZTQDownloadManager shareManager].fileName = fileName;
    [ZTQDownloadManager shareManager].customHeader = header;
    [ZTQDownloadManager shareManager].customHeaderField = customHeaderField;
    
    [ZTQDownloadManager shareManager].progresshandler = progress;
    [ZTQDownloadManager shareManager].success = success;
    [ZTQDownloadManager shareManager].failure = failure;
    [[ZTQDownloadManager shareManager] configDataTask];
    [[ZTQDownloadManager shareManager].task resume];
    
    return [ZTQDownloadManager shareManager].task;
    
}

+ (void)cancelDownload {
    
    if (![ZTQDownloadManager shareManager].task) {
        return;
    }
    
    [[ZTQDownloadManager shareManager].task cancel];
    [[NSFileManager defaultManager] removeItemAtPath:DownLoadFilePath([ZTQDownloadManager shareManager].fileName) error:nil];
    [[ZTQDownloadManager shareManager].stream close];
    
    // 删除数据
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:ZTQDownFilesPlist];
    [dic removeObjectForKey:DownLoadFilePath([ZTQDownloadManager shareManager].fileName)];
    [dic writeToFile:ZTQDownFilesPlist atomically:YES];
    
    [ZTQDownloadManager shareManager].stream = nil;
    [ZTQDownloadManager shareManager].task = nil;
    // 不保留上次信息
    [ZTQDownloadManager shareManager].urlString = nil;
    [ZTQDownloadManager shareManager].fileName = nil;
    [ZTQDownloadManager shareManager].customHeader = nil;
    [ZTQDownloadManager shareManager].customHeaderField = nil;
    
}

+ (void)pauseDownload {
    if ([ZTQDownloadManager shareManager].task) {
        [[ZTQDownloadManager shareManager].task suspend];
    }
}

+ (void)continueDownload {
    if ([ZTQDownloadManager shareManager].task) {
        [[ZTQDownloadManager shareManager].task resume];
    }
}

#pragma mark - private methods

- (void)configDataTask {
    if (self.task) {
        return;
    }
    // 获得文件总长度
    NSInteger totalLength = [[[NSDictionary dictionaryWithContentsOfFile:ZTQDownFilesPlist] objectForKey:ZTQMD5String(self.urlString)] integerValue];
    // 请求同一个文件，判断下载文件长度；如果没下载过此文件，totalLength = 0
    if (totalLength && AlreadyDownloadLenth(self.fileName) == totalLength) {
        NSLog(@"文件已经下载过.");
        return ;
    }
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    
    if (self.customHeaderString.length > 0 && self.customHeaderField.length > 0) {
        [req setValue:self.customHeaderString forHTTPHeaderField:self.customHeaderField];
    }
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", AlreadyDownloadLenth(self.fileName)];
    [req setValue:range forHTTPHeaderField:@"Range"];
    self.task = [self.session dataTaskWithRequest:req];
}

#pragma mark - NSURLSessionDataDelegate

/**
 接收到服务器响应

 @param session             当前请求
 @param dataTask            当前请求的任务对象
 @param response            服务器响应
 @param completionHandler   成功回调
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    completionHandler(NSURLSessionResponseAllow);
    
    if (self.fileName.length == 0) {
        self.fileName = response.suggestedFilename;
    }
    
    self.stream = [NSOutputStream outputStreamToFileAtPath:DownLoadFilePath(self.fileName) append:YES];
    [self.stream open];
    
    self.totleLenth = [((NSHTTPURLResponse *)response).allHeaderFields[@"Content-Length"] integerValue] + AlreadyDownloadLenth(self.fileName);
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:ZTQDownFilesPlist];
    // 字典可能为空
    if (dict == nil) {
        dict = [NSMutableDictionary dictionary];
    }
    // 写入文件
    dict[DownLoadFilePath(self.fileName)] = @(self.totleLenth);
    [dict writeToFile:ZTQDownFilesPlist atomically:YES];
    
}

/**
 将要进行请求

 @param session             当前请求
 @param dataTask            当前请求的任务对象
 @param streamTask          TCP / IP连接的主机名和端口或一个网络服务对象
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask {
    
}

/**
 任务下载中

 @param session             当前请求
 @param dataTask            当前请求的任务对象
 @param data                接收的数据流
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    [self.stream write:[data bytes] maxLength:data.length];
    self.downloadLenth = AlreadyDownloadLenth(self.fileName);
    // 计算进度
    
    NSProgress *progress = [NSProgress progressWithTotalUnitCount:self.totleLenth];
    progress.completedUnitCount = self.downloadLenth;
    NSLog(@"count:\n%ld", AlreadyDownloadLenth(self.fileName));
    NSLog(@"%f",1.0 * self.downloadLenth / self.totleLenth);
    if (self.progresshandler) {
        self.progresshandler(progress);
    }
}

/**
 下载完成

 @param session             当前下载请求
 @param task                当前请求的任务对象
 @param error               失败
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    [self.stream close];
    self.stream = nil;
    self.task = nil;
    // 不保留上次信息
    self.urlString = nil;
    self.fileName = nil;
    self.customHeader = nil;
    self.customHeaderField = nil;
    if (error) {
        if (self.failure) {
            self.failure(error);
        }
        return;
    }
    self.success(DownLoadFilePath(self.fileName));
}

#pragma mark - getter

- (NSURLSession *)session {
    if (!_session) {
        _session = ({
            NSURLSession *s = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
            s;
        });
    }
    return _session;
}


- (NSString *)customHeaderString {
    if (!_customHeaderString) {
        _customHeaderString = ({
            if (self.customHeader.count == 0) {
                return nil;
            }
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.customHeader
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                         encoding:NSUTF8StringEncoding];
            jsonString;
        });
    }
    return _customHeaderString;
}

@end
