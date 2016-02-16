//
//  BbGetImage.m
//  Pods
//
//  Created by Travis Henspeter on 2/14/16.
//
//

#import "BbGetImage.h"
#import <UIKit/UIKit.h>
#import "AFImageDownloader.h"
#import "UIImageView+AFNetworking.h"

@interface BbGetImage ()

@property (nonatomic,strong)    AFHTTPSessionManager    *sessionManager;
@property (nonatomic,strong)    AFImageDownloader       *imageDownloader;
@property (nonatomic,strong)    UIImageView             *myImageView;

@end

@implementation BbGetImage

- (void)setupPorts
{
    BbInlet *hotInlet = [[BbInlet alloc]init];
    hotInlet.hot = YES;
    [self addChildEntity:hotInlet];
    
    __block BbOutlet *successOutlet = [[BbOutlet alloc]init];
    [self addChildEntity:successOutlet];
    
    __block BbOutlet *failureOutlet = [[BbOutlet alloc]init];
    [self addChildEntity:failureOutlet];
    
    [hotInlet setInputBlock:^(id value){
        id outputValue = nil;
        if ([value isKindOfClass:[NSString class]]) {
            outputValue = value;
        }else if ([value isKindOfClass:[NSArray class]]){
            NSArray *arr = value;
            if ([arr.firstObject isKindOfClass:[NSString class]]) {
                outputValue = arr.firstObject;
            }
        }
        
        return outputValue;
    }];

    __weak BbGetImage *weakself = self;
    [hotInlet setOutputBlock:^(id value){
        NSURL *url = [NSURL URLWithString:value];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [weakself.imageDownloader downloadImageForURLRequest:request success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull responseObject) {
            [successOutlet setInputElement:responseObject];

        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
            [failureOutlet setInputElement:error];

        }];
            
    }];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"GET Image";
    self.displayText = self.name;
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    self.sessionManager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:config];
    self.sessionManager.responseSerializer = [AFImageResponseSerializer serializer];
    self.imageDownloader = [[AFImageDownloader alloc]initWithSessionManager:self.sessionManager downloadPrioritization:AFImageDownloadPrioritizationFIFO maximumActiveDownloads:4 imageCache:[[AFAutoPurgingImageCache alloc] init]];
    
}

+ (NSString *)symbolAlias
{
    return @"get image";
}

@end
