//
//  DDMsgServer.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDMsgServer.h"
#import "LoginEntity.h"
#import "DDLoginAPI.h"
#import "LoginEntity.h"
static int const timeOutTimeInterval = 10;

typedef void(^Success)(id object);
typedef void(^Failure)(id object);

@interface DDMsgServer(PrivateAPI)

- (void)n_receiveLoginMsgServerNotification:(NSNotification*)notification;
- (void)n_receiveLoginLoginServerNotification:(NSNotification*)notification;

@end

@implementation DDMsgServer
{
    Success _success;
    Failure _failure;
    
    BOOL _connecting;
    NSUInteger _connectTimes;
}
- (id)init
{
    self = [super init];
    if (self)
    {
        _connecting = NO;
        _connectTimes = 0;
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveLoginMsgServerNotification:) name:notificationLoginMsgServerSuccess object:nil];
    }
    return self;
}

-(void)checkUserID:(NSString*)userID token:(NSString*)token success:(void(^)(id object))success failure:(void(^)(id object))failure
{
    
    if (!_connecting)
    {
        NSString *clientVersion = [NSString stringWithFormat:@"MAC/%@-%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];

        
        NSArray* parameter = @[userID,token,clientVersion,[NSNumber numberWithInteger:USER_STATUS_ONLINE]];
        
        DDLoginAPI* api = [[DDLoginAPI alloc] init];
        [api requestWithObject:parameter Completion:^(id response, NSError *error) {
            if (!error)
            {
                LoginEntity* loginEntity = (LoginEntity*)response;
                if (loginEntity.result == 0)
                {
                    success(response);
                }
                else
                {
                    NSError* newError = [NSError errorWithDomain:@"登录验证失败" code:6 userInfo:nil];
                    failure(newError);
                }
            }
            else
            {
                DDLog(@"error:%@",[error domain]);
                failure(error);
            }
        }];
    }
}

- (void)checkUSerName:(NSString*)userName
             password:(NSString*)password
          onlineState:(int)onlineState
           clientType:(int)clientType
        clientVersion:(NSString*)clientVersion
           completion:(DDMsgServerCheckCompletion)completion
{
    NSArray* parameter = @[userName,password,@(onlineState),@(clientType),clientVersion];
    
    DDLoginAPI* api = [[DDLoginAPI alloc] init];
    [api requestWithObject:parameter Completion:^(id response, NSError *error) {
        if (!error)
        {
            LoginEntity* loginEntity = (LoginEntity*)response;
            if (loginEntity.result == 0)
            {
                completion(loginEntity.myUserInfo,nil);
            }
            else
            {
                NSError* newError = [NSError errorWithDomain:@"登录验证失败" code:6 userInfo:nil];
                completion(nil,newError);
            }
        }
        else
        {
            DDLog(@"error:%@",[error domain]);
            completion(nil,error);
        }
    }];

}

@end
