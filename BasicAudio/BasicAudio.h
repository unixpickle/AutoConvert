//
//  BasicAudio.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACConverter.h"

#import <ACPlugIn/ACConverter.h>
#import <AudioToolbox/AudioToolbox.h>

/**
 * This is an ACConverter which uses CoreAudio to convert between standard
 * audio file types.
 *
 * Limitations:
 * - Cannot transcode m4a
 * - Cannot encode mp3
 *
 * Features:
 * - Supports live progress updates!
 * - Functional and quick cancel functionality
 */
@interface BasicAudio : ACConverter {
    AudioFileID primInputFile;
    ExtAudioFileRef inputFile;
    AudioStreamBasicDescription inputFormat;
    
    ExtAudioFileRef outputFile;
    AudioStreamBasicDescription outputFormat;
    AudioFileTypeID outputFileType;
    
    AudioStreamBasicDescription clientFormat;
    BOOL noError;
}

+ (AudioFileTypeID)audioFileTypeForExtension:(NSString *)extension;
- (BOOL)openInputFile:(NSString *)path;
- (BOOL)openOutputFile:(NSString *)path;
- (BOOL)setClientFormat;
- (void)dispose;

@end
