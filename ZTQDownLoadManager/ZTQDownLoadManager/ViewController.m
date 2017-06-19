//
//  ViewController.m
//  ZTQDownLoadManager
//
//  Created by Ztq on 2017/6/19.
//  Copyright © 2017年 ZTQ. All rights reserved.
//

#import "ViewController.h"

#import "ZTQDownloadManager.h"

@interface ViewController ()

@property (strong, nonatomic) UIProgressView *p;

@end

@implementation ViewController

{
    BOOL _isLoad;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _isLoad = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 100, 40);
    button.center = CGPointMake(self.view.center.x, self.view.center.y);
    button.backgroundColor = [UIColor whiteColor];
    [button setTitle:@"开始下载" forState:UIControlStateNormal];

    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(startDownload:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton * button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    button1.frame = CGRectMake(0, 0, 100, 40);
    button1.center = CGPointMake(self.view.center.x, self.view.center.y + 40);
    button1.backgroundColor = [UIColor whiteColor];
    [button1 setTitle:@"取消下载" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(cancelDL) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton * button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    button2.frame = CGRectMake(0, 0, 100, 60);
    button2.center = CGPointMake(self.view.center.x, self.view.center.y + 80);
    button2.backgroundColor = [UIColor whiteColor];
    [button2 setTitle:@"暂停下载" forState:UIControlStateNormal];
    
    [button2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(pauseDownload:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    [self.view addSubview:self.p];
    
}

- (void)startDownload:(UIButton *)btn {
    
    if (_isLoad) {
        [ZTQDownloadManager continueDownload];
        return;
    }
    
    [ZTQDownloadManager downloadWithURL:@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V5.5.1.dmg" fileName:@"test" header:nil customHeaderField:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"downloadProgress:%@\n\nprogress:%f", downloadProgress,1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.p.progress = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
        });
    } successHandler:^(NSString * _Nonnull filePath) {
        NSLog(@"downloadProgress:%@", filePath);
    } failureHandler:^(NSError * _Nullable error) {
        NSLog(@"downloadProgress:%@", error);
    }];
    _isLoad = YES;
}

- (void)pauseDownload:(UIButton *)btn {
    [ZTQDownloadManager pauseDownload];
    _isLoad = YES;
}

- (void)cancelDL {
    [ZTQDownloadManager cancelDownload];
    dispatch_async(dispatch_get_main_queue(), ^{
       self.p.progress = 0.0;
    });
    _isLoad = NO;
}

#pragma mark - getter

- (UIProgressView *)p {
    if (!_p) {
        _p = ({
            UIProgressView *p = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 200, 2)];
            p.progressViewStyle = UIProgressViewStyleDefault;
            p.center = CGPointMake(self.view.center.x, self.view.center.y - 80);
            p;
        });
    }
    return _p;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
