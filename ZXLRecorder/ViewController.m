//
//  ViewController.m
//  ZXLRecorder
//
//  Created by 张小龙 on 2018/5/14.
//  Copyright © 2018年 张小龙. All rights reserved.
//

#import "ViewController.h"
#import "ZXLRecorder.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<ZXLRecorderDelegate>
@property (nonatomic,strong)UIButton * recorderBtn;
@property (nonatomic,strong)UIButton * pasueBtn;
@property (nonatomic,strong)UIButton * resumeBtn;
@property (nonatomic,strong)UIButton * stopBtn;
@property (nonatomic,strong)UIButton * playBtn;
@property (nonatomic,strong)UIProgressView * progressView;
@property (nonatomic,strong)UILabel * tipsLabel;
@property (nonatomic,strong)ZXLRecorder * recorder;
@property (nonatomic,strong)AVAudioPlayer * player;
@property (nonatomic,copy)NSString * strPath;
@end

@implementation ViewController

-(ZXLRecorder *)recorder{
    if (!_recorder) {
        _recorder = [[ZXLRecorder alloc] initWithDelegate:self];
    }
    return _recorder;
}

-(AVAudioPlayer *)player{
    if (!_player) {
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.strPath] error:nil];
    }
    return _player;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = CGRectMake(0, 200, 140, 40);
    rect.origin.x = (self.view.frame.size.width - rect.size.width)/2;
    
    if (_recorderBtn == nil) {
        _recorderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _recorderBtn.backgroundColor = [UIColor blackColor];
        _recorderBtn.layer.cornerRadius = 6.0f;
        _recorderBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_recorderBtn setTitle:@"录制" forState:UIControlStateNormal];
        [_recorderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_recorderBtn addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
        _recorderBtn.frame = rect;
        [self.view addSubview:_recorderBtn];
    }
    
    rect.origin.y += rect.size.height + 20;
    if (_pasueBtn == nil) {
        _pasueBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _pasueBtn.backgroundColor = [UIColor blackColor];
        _pasueBtn.layer.cornerRadius = 6.0f;
        _pasueBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_pasueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_pasueBtn setTitle:@"暂停" forState:UIControlStateNormal];
        [_pasueBtn addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
        _pasueBtn.frame = rect;
        [self.view addSubview:_pasueBtn];
    }
    
    rect.origin.y += rect.size.height + 20;
    if (_resumeBtn == nil) {
        _resumeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _resumeBtn.backgroundColor = [UIColor blackColor];
        _resumeBtn.layer.cornerRadius = 6.0f;
        _resumeBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_resumeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_resumeBtn setTitle:@"继续" forState:UIControlStateNormal];
        [_resumeBtn addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
        _resumeBtn.frame = rect;
        [self.view addSubview:_resumeBtn];
    }
    
    rect.origin.y += rect.size.height + 20;
    if (_stopBtn == nil) {
        _stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _stopBtn.backgroundColor = [UIColor blackColor];
        _stopBtn.layer.cornerRadius = 6.0f;
        _stopBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_stopBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_stopBtn setTitle:@"停止" forState:UIControlStateNormal];
        [_stopBtn addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
        _stopBtn.frame = rect;
        [self.view addSubview:_stopBtn];
    }
    
    rect.origin.y += rect.size.height + 20;
    if (_playBtn == nil) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playBtn.backgroundColor = [UIColor blackColor];
        _playBtn.layer.cornerRadius = 6.0f;
        _playBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_playBtn setTitle:@"播放" forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
        _playBtn.frame = rect;
        [self.view addSubview:_playBtn];
    }
    rect.origin.y += rect.size.height + 20;
    rect.size.width = 200;
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.textColor = [UIColor redColor];
        _tipsLabel.frame = rect;
        [self.view addSubview:_tipsLabel];
    }

    rect = CGRectMake(10, rect.origin.y + rect.size.height + 20, 300, 10);
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]init];
        _progressView.progressTintColor = [UIColor redColor];
        _progressView.trackTintColor = [UIColor grayColor];
        _progressView.progress = 0;
        _progressView.progressViewStyle = UIProgressViewStyleDefault;
        [self.view addSubview:_progressView];
    }
}

-(void)onButton:(id)sender{
    if (sender == _recorderBtn) {
        [self.recorder start];
        
        if (_player) {
            if (_player.isPlaying) {
                [_player stop];
            }
            _player = nil;
        }
    }
    
    if (sender == _pasueBtn) {
        [self.recorder pause];
    }
    
    if (sender == _resumeBtn) {
        [self.recorder resume];
    }
    
    if (sender == _stopBtn) {
        [self.recorder stop];
    }
    
    if (sender == _playBtn) {
        if (self.player) {
            [self.player play];
        }
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)endConvertWithMP3FileName:(NSString *)filePath {
    self.strPath = filePath;
    
    _tipsLabel.text = @"录制成功";
}

- (void)failRecord {
    _tipsLabel.text = @"录制失败";
}


- (void)peakPowerForChannel:(double)peakPowerForChannel{
    
}

- (void)maxTimeStopRecord{
    
}

- (void)recordTime:(double)time{
    _tipsLabel.text = [NSString stringWithFormat:@"录制中%lf",time];
}

@end
