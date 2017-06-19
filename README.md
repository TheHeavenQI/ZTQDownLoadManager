# ZTQDownLoadManager
自定义下载，可实现断点下载，并缓存

### 调用方式

```
[ZTQDownloadManager downloadWithURL:@"" fileName:@"" header:nil customHeaderField:@"" progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } successHandler:^(NSString * _Nonnull filePath) {
        
    } failureHandler:^(NSError * _Nullable error) {
        
    }];

```