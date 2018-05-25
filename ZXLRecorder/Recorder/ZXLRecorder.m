//
//  ZXLRecorder.m
//  ZXLRecorder
//
//  Created by 张小龙 on 2018/5/14.
//  Copyright © 2018年 张小龙. All rights reserved.
//

#import "ZXLRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "ZXLThread.h"
#import <lame/lame.h>

#define ZXLAudioRecorderCache @"com.zxl.chat.ZXLAudioRecorderCache"

@interface ZXLRecorder()
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer         *timer;
@property (nonatomic, assign) BOOL         isStopRecord;//结束录音控制
@property (nonatomic, assign) BOOL         isDestroyRecord; //销毁录音控制
@property (nonatomic, assign) BOOL         isPauseRecord; //暂停录音控制
@property (nonatomic, strong) ZXLThread * thread; //控制线程中录音转MP3 暂停和继续
@end

@implementation ZXLRecorder

#pragma mark - Init Methods
- (instancetype)initWithDelegate:(id<ZXLRecorderDelegate>)delegate{
    if (self = [super init]) {
        _delegate = delegate;
        self.isStopRecord = YES;
        self.isDestroyRecord = YES;
        self.maxTime = 60;
    }
    return self;
}

-(void)dealloc{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

-(ZXLThread *)thread{
    if (!_thread) {
        _thread = [ZXLThread currentThread];
    }
    return _thread;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

-(AVAudioRecorder *)recorder{
    if (!_recorder) {
        NSError *recorderSetupError = nil;
        _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:[self cafPath]]
                                                settings:[self audioRecorderSettings]
                                                   error:&recorderSetupError];
        if (recorderSetupError) {
//            NSLog(@"创建播放器过程中发生错误，错误信息：%@",recorderSetupError.localizedDescription);
            return nil;
        }
        _recorder.meteringEnabled = YES;//声波测试
    }
    return _recorder;
}

/**
 *  设置音频会话
 */
-(void)setAudioSession{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

/**
 录音设置 （可根据需要自己设置）
 
 @return 设置信息
 */
-(NSDictionary *)audioRecorderSettings{
    return @{AVFormatIDKey  :  @(kAudioFormatLinearPCM), //录音格式
             AVSampleRateKey : @(11025.0),              //采样率
             AVNumberOfChannelsKey : @2,                //通道数
             AVEncoderBitDepthHintKey : @16,            //比特率
             AVEncoderAudioQualityKey : @(AVAudioQualityHigh)}; //声音质量
}



#pragma mark - audioPowerChange
- (void)audioPowerChange {
    [self.recorder updateMeters];
    float peakPower = [self.recorder averagePowerForChannel:0];
    double peakPowerForChannel = pow(10, (0.015 * peakPower));
    // 更新扬声器
    if ([self.delegate respondsToSelector:@selector(peakPowerForChannel:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [self.delegate peakPowerForChannel:peakPowerForChannel];
        });
    }
    // 当前录音时长更新
    if ([self.delegate respondsToSelector:@selector(recordTime:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate recordTime:self.recorder.currentTime];
        });
    }
    // 当前录音的时间大于最大时间，停止录音
    NSTimeInterval currentTimeInterval = _recorder.currentTime;
    if (currentTimeInterval >= self.maxTime) {
        [self stop];
        if ([self.delegate respondsToSelector:@selector(maxTimeStopRecord)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                 [self.delegate maxTimeStopRecord];
            });
        }
    }
}


-(void)prepareToRecord{
    [self setAudioSession];
    //清空历史录音文件
    NSString *cafFilePath = [self cafPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cafFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:cafFilePath error:nil];
    }
    [self.recorder prepareToRecord];
}

- (void)start{
  if ([self isRecording]) return;
    
    [self prepareToRecord];
    self.isStopRecord = NO;
    self.isDestroyRecord = NO;
    [self.recorder record];
    [self.timer setFireDate:[NSDate distantPast]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self conventToMp3];
    });
}


- (void)pause{
    if (self.isPauseRecord || ![self isRecording]) return;
    
    [self.timer setFireDate:[NSDate distantFuture]];
    [self.recorder pause];
    self.isPauseRecord = YES;
    [self.thread sendWaitSignal];
}

- (void)resume{
    if (!self.isPauseRecord) return;
    
    [self.recorder record];
    [self.thread signal];
    self.isPauseRecord = NO;
    [self.timer setFireDate:[NSDate distantPast]];
}

- (void)stop{
    if (![self isRecording]) return;
    
    [self.timer setFireDate:[NSDate distantFuture]];
    
    double cTime = self.recorder.currentTime;
    [self.recorder stop];
    self.isStopRecord = YES;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    if (cTime < 1){
        [self.recorder deleteRecording];
        if (self.delegate && [self.delegate respondsToSelector:@selector(failRecord)]) {
            [self.delegate failRecord];
        }
    }
}

- (void)destroy{
    if (self.isStopRecord || self.isDestroyRecord) {
        return;
    }
   
    self.isDestroyRecord = YES;
    self.isStopRecord = YES;
    [self.thread signal];
    [self.timer setFireDate:[NSDate distantFuture]];
    [self.recorder stop];
    [self.recorder deleteRecording];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
}

-(BOOL)isRecording{
    return (self.recorder.isRecording && !self.isStopRecord);
}

#pragma mark - Convert to mp3
- (void)conventToMp3 {
    NSString*cafFilePath = [self cafPath];
    NSString *mp3FilePath = [[self mp3Path] stringByAppendingPathComponent:[self randomMP3FileName]];
    @try{
        int read, write;
        FILE*pcm =fopen([cafFilePath cStringUsingEncoding:NSASCIIStringEncoding],"rb");
        FILE*mp3 =fopen([mp3FilePath cStringUsingEncoding:NSASCIIStringEncoding],"wb");
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE * 2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        long curpos;
        BOOL isSkipPCMHeader =NO;
        do{
            curpos = ftell(pcm);
            long startPos = ftell(pcm);
            fseek(pcm, 0,SEEK_END);
            long endPos = ftell(pcm);
            long length = endPos - startPos;
            fseek(pcm, curpos,SEEK_SET);
            if(length > PCM_SIZE * 2 *sizeof(short int)) {
                if(!isSkipPCMHeader) {
                    fseek(pcm, 4 * 1024,SEEK_SET);
                    isSkipPCMHeader =YES;
                }
                
                read = (int)fread(pcm_buffer, 2 *sizeof(short int), PCM_SIZE, pcm);
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                fwrite(mp3_buffer, write, 1, mp3);
            }
            else{
                [NSThread sleepForTimeInterval:0.05];
            }
            
            if (self.isPauseRecord && [self.thread waitSignal]) {
                [self.thread wait];
            }
            
        }while(!self.isStopRecord);
        
        read = (int)fread(pcm_buffer, 2 *sizeof(short int), PCM_SIZE, pcm);
        write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    
    @catch(NSException *exception) {
        mp3FilePath = nil;
    }
    
    @finally{
        
        if (!self.isDestroyRecord) {//销毁不做返回
            if (mp3FilePath && mp3FilePath.length > 0) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(endConvertWithMP3FileName:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate endConvertWithMP3FileName:mp3FilePath];
                    });
                }
            }else{
                if (self.delegate && [self.delegate respondsToSelector:@selector(failRecord)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate failRecord];
                    });
                }
            }
        }
    }
}


#pragma mark - Path Utils
- (NSString *)cafPath {
    NSString *cafPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.caf"];
    return cafPath;
}

- (NSString *)mp3Path {
    NSString *mp3Path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:ZXLAudioRecorderCache];
    if (![[NSFileManager defaultManager] fileExistsAtPath:mp3Path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:mp3Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return mp3Path;
}

- (NSString *)randomMP3FileName {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"ZXLRecorder_%.0f.mp3",timeInterval];
    return fileName;
}
@end
