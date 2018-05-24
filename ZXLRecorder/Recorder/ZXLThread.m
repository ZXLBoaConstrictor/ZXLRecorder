//
//  ZXLThread.m
//  ZXLRecorder
//
//  Created by 张小龙 on 2018/5/18.
//  Copyright © 2018年 张小龙. All rights reserved.
//

#import "ZXLThread.h"

@interface ZXLThread()
@property(nonatomic, assign) BOOL waitSignal;
@property(nonatomic, strong) NSCondition *condition;
@end

@implementation ZXLThread
+ (ZXLThread *) currentThread{
    return [[ZXLThread alloc]init];
}
- (id) init{
    self = [super init];
    if (self){
        self.waitSignal = NO;
        self.condition = [[NSCondition alloc] init];
    }
    return self;
}

-(BOOL)sendWaitSignal{
    [self.condition lock];
    self.waitSignal = YES;
    [self.condition unlock];
    return self.waitSignal;
}

-(BOOL)waitSignal{
    return _waitSignal;
}

-(void)sleep:(NSInteger)seconds{
    if (seconds == 0) {
        [self wait];
    }else{
        [self.condition lock];
        [self.condition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:seconds]];
        [self.condition unlock];
    }
}

-(void)wait{
    [self.condition lock];
    [self.condition wait];
    [self.condition unlock];
}

-(void)signal{
    [self.condition lock];
    self.waitSignal = NO;
    [self.condition signal];
    [self.condition unlock];
}

-(void)broadcast{
    [self.condition lock];
    self.waitSignal = NO;
    [self.condition broadcast];
    [self.condition unlock];
}
@end
