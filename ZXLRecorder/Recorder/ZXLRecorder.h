//
//  ZXLRecorder.h
//  ZXLRecorder
//
//  Created by 张小龙 on 2018/5/14.
//  Copyright © 2018年 张小龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZXLRecorderDelegate <NSObject>

/**
 录音失败
 */
- (void)failRecord;

/**
 录音结束后的MP3文件地址

 @param filePath MP3文件地址
 */
- (void)endConvertWithMP3FileName:(NSString *)filePath;
@optional

/**
 录音过程中音量的波动

 @param peakPowerForChannel 音量波动值
 */
- (void)peakPowerForChannel:(double)peakPowerForChannel;

/**
 录制时间变动

 @param time 时间变动 （频率和音量波动时间一样）
 */
- (void)recordTime:(double)time;

/**
 录音时长达到最大时长的时候停止录音
 */
- (void)maxTimeStopRecord;
@end

@interface ZXLRecorder : NSObject
@property (nonatomic, weak) id<ZXLRecorderDelegate> delegate;

/**
 录音最大时间 （多久自动结束）默认 60秒
 */
@property (nonatomic, assign) NSInteger maxTime;

- (instancetype)initWithDelegate:(id<ZXLRecorderDelegate>)delegate;

/**
 是否正在录音
 */
-(BOOL)isRecording;

/**
 录音开始
 */
- (void)start;
/**
 录音暂停
 */
- (void)pause;

/**
 录音继续
 */
- (void)resume;

/**
 录音停止
 */
- (void)stop;

/**
 销毁录音 ，立即停止录音 （使用录音时必须在释放函数中添加 销毁函数，防止中途界面直接销毁，没有直接释放）
 */
- (void)destroy;

@end
