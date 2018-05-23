//
//  ZXLThread.h
//  ZXLRecorder
//
//  Created by 张小龙 on 2018/5/18.
//  Copyright © 2018年 张小龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZXLThread : NSObject


+ (ZXLThread *) currentThread;


/**
 发送等待信号

 @return 是否等待
 */
-(BOOL)sendWaitSignal;

/**
 等待信号

 @return 是否去等待
 */
-(BOOL)waitSignal;

/**
 休眠（seconds == 0 即 wait函数）

 @param seconds 秒
 */
-(void)sleep:(NSInteger)seconds;
/**
 线程等待
 */
-(void)wait;

/**
 线程继续
 */
-(void)signal;

/**
 控制的全部线程继续
 */
-(void)broadcast;
@end
