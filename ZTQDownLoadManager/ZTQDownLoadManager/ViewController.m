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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [ZTQDownloadManager downloadWithURL:@"" fileName:@"" header:nil customHeaderField:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } successHandler:^(NSString * _Nonnull filePath) {
        
    } failureHandler:^(NSError * _Nullable error) {
        
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
