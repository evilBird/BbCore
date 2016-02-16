//
//  BbGet.m
//  Pods
//
//  Created by Travis Henspeter on 2/14/16.
//
//

#import "BbGet.h"
#import "AFNetworking.h"

@interface BbGet ()

@property (nonatomic,strong)    AFHTTPSessionManager        *sessionManager;

@end


@implementation BbGet

+ (NSString *)symbolAlias
{
    return @"get";
}

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
    
    __weak BbGet *weakself = self;
    [hotInlet setOutputBlock:^(id value){
        [weakself.sessionManager GET:value parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [successOutlet setInputElement:responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [successOutlet setInputElement:error];
        }];
    }];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"GET";
    if (!arguments) {
        self.displayText = self.name;
        self.sessionManager = [AFHTTPSessionManager manager];
    }else{
        self.displayText = [NSString stringWithFormat:@"%@ %@",self.name,arguments];
        self.sessionManager = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:arguments]];
    }
}

- (void)cleanup
{
    [self.sessionManager invalidateSessionCancelingTasks:YES];
    _sessionManager = nil;
}

@end
