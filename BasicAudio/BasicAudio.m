//
//  BasicAudio.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BasicAudio.h"

@implementation BasicAudio

+ (BOOL)supportsExtension:(NSString *)oldExt toExtension:(NSString *)newExt {
    AudioFileTypeID fromType = [self audioFileTypeForExtension:oldExt];
    AudioFileTypeID toType = [self audioFileTypeForExtension:newExt];
    if (fromType == 0 || toType == 0) return NO;
    if (toType == kAudioFileMP3Type || toType == kAudioFileMP2Type || toType == kAudioFileMP1Type) {
        return NO;
    }
    return YES;
}

+ (AudioFileTypeID)audioFileTypeForExtension:(NSString *)extension {
    NSDictionary * fileTypes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithUnsignedLongLong:kAudioFileAIFFType], @"aif",
                                [NSNumber numberWithUnsignedLongLong:kAudioFileAIFFType], @"aiff",
                                [NSNumber numberWithUnsignedLongLong:kAudioFileAIFCType], @"aifc",
                                [NSNumber numberWithUnsignedLongLong:kAudioFileWAVEType], @"wav",
                                [NSNumber numberWithUnsignedLongLong:kAudioFileSoundDesigner2Type], @"sd2",
                                [NSNumber numberWithUnsignedLongLong:kAudioFileMP3Type], @"mp3",
                                [NSNumber numberWithUnsignedLongLong:kAudioFileMP2Type], @"mp2",
                                [NSNumber numberWithUnsignedLongLong:kAudioFileMP1Type], @"mp1", 
                                [NSNumber numberWithUnsignedLongLong:kAudioFileMP1Type], @"mpg",
                                // [NSNumber numberWithUnsignedLongLong:kAudioFileAC3Type], @"ac3", 
                                // [NSNumber numberWithUnsignedLongLong:kAudioFileM4AType], @"m4a", 
                                // [NSNumber numberWithUnsignedLongLong:kAudioFileMPEG4Type], @"mp4", 
                                [NSNumber numberWithUnsignedLongLong:kAudioFileCAFType], @"caf", 
                                [NSNumber numberWithUnsignedLongLong:kAudioFileCAFType],@"caff", 
                                [NSNumber numberWithUnsignedLongLong:kAudioFileNextType], @"snd",
                                [NSNumber numberWithUnsignedLongLong:kAudioFileNextType], @"au",
                                nil];
    return (AudioFileTypeID)[[fileTypes objectForKey:extension] unsignedLongLongValue];
}

- (id)initWithFile:(NSString *)aFile source:(NSString *)oldExt dest:(NSString *)newExt {
    if ((self = [super initWithFile:aFile source:oldExt dest:newExt])) {
        if (![self openInputFile:aFile]) return self;
        if (![self openOutputFile:tempFile]) return self;
        if (![self setClientFormat]) return self;
        noError = YES;
    }
    return self;
}

- (BOOL)openInputFile:(NSString *)path {
    NSURL * fileURL = [NSURL fileURLWithPath:path];
    OSStatus err = 0;
    
    err = AudioFileOpenURL((__bridge CFURLRef)fileURL, kAudioFileReadPermission, [[self class] audioFileTypeForExtension:sourceExtension], &primInputFile);
    if (err != noErr) return NO;
    err = ExtAudioFileWrapAudioFileID(primInputFile, FALSE, &inputFile);
    if (err != noErr) return NO;
    
    // get the file's input format
    UInt32 size = sizeof(inputFormat);
    Boolean writable = 0;
    ExtAudioFileGetPropertyInfo(inputFile, kExtAudioFileProperty_FileDataFormat, &size, &writable);
    err = ExtAudioFileGetProperty(inputFile, kExtAudioFileProperty_FileDataFormat, &size, &inputFormat);
    if (err != noErr) return NO;
    
    return YES;
}

- (BOOL)openOutputFile:(NSString *)path {
    outputFileType = [[self class] audioFileTypeForExtension:self.destExtension];
    
    UInt32 formatID = 0;
    if (outputFileType == kAudioFileAMRType) {
        formatID = kAudioFormatAMR;
    } else if (outputFileType == kAudioFileWAVEType || outputFileType == kAudioFileCAFType) {
        formatID = kAudioFormatLinearPCM;
    } else if (outputFileType == kAudioFileMPEG4Type) {
        formatID = kAudioFormatMPEG4AAC;
    } else if (outputFileType == kAudioFile3GPType) {
        formatID = kAudioFormatMPEG4AAC;
    } else if (outputFileType == kAudioFileMP3Type) {
        formatID = kAudioFormatMPEGLayer3;
    } else if (outputFileType == kAudioFileMP2Type) {
        formatID = kAudioFormatMPEGLayer2;
    } else if (outputFileType == kAudioFileMP1Type) {
        formatID = kAudioFormatMPEGLayer1;
    } else if (outputFileType == kAudioFileSoundDesigner2Type) {
        formatID = kAudioFormatLinearPCM;
    } else if (outputFileType == kAudioFileAIFCType) {
        formatID = kAudioFormatULaw;
    } else if (outputFileType == kAudioFileAIFFType) {
        formatID = kAudioFormatLinearPCM;
    } else if (outputFileType == kAudioFileNextType) {
        formatID = kAudioFormatLinearPCM;
    } else if (outputFileType == kAudioFileAC3Type) {
        formatID = kAudioFormatAC3;
    } else {
        return NO;
    }
    
    outputFormat.mFormatID = formatID;
    outputFormat.mSampleRate = inputFormat.mSampleRate != 0 ? inputFormat.mSampleRate : 44100;
    outputFormat.mChannelsPerFrame = inputFormat.mChannelsPerFrame;
    outputFormat.mBitsPerChannel = 16;
    if (outputFormat.mFormatID == kAudioFormatLinearPCM) {
        outputFormat.mBytesPerPacket = outputFormat.mChannelsPerFrame * sizeof(SInt16);
        outputFormat.mBytesPerFrame = outputFormat.mChannelsPerFrame * sizeof(SInt16);
    } else {
        outputFormat.mBytesPerPacket = 0;
        outputFormat.mBytesPerFrame = 0;
    }
    outputFormat.mFramesPerPacket = 1;
    
    // set various flags
    if (formatID == kAudioFormatLinearPCM) {
        if (outputFileType == kAudioFileWAVEType) {
            outputFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        } else {
            outputFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked + kAudioFormatFlagIsBigEndian;
        }
    }
    
    NSURL * outputURL = [NSURL fileURLWithPath:path];
    OSStatus err = ExtAudioFileCreateWithURL((__bridge CFURLRef)outputURL,
                                             outputFileType,
                                             &outputFormat,
                                             NULL,
                                             kAudioFileFlags_EraseFile,
                                             &outputFile);
    return (err == noErr);
}

- (BOOL)setClientFormat {
    clientFormat.mSampleRate = inputFormat.mSampleRate;
    clientFormat.mFormatID = kAudioFormatLinearPCM;
    clientFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    clientFormat.mChannelsPerFrame = inputFormat.mChannelsPerFrame;
    clientFormat.mBitsPerChannel = 16;
    clientFormat.mBytesPerFrame = 4;
    clientFormat.mBytesPerPacket = 4;
    clientFormat.mFramesPerPacket = 1;
    
    OSStatus err;
    UInt32 size = sizeof(clientFormat);
    err = ExtAudioFileSetProperty(inputFile, kExtAudioFileProperty_ClientDataFormat, size, &clientFormat);
    if (err != noErr) return NO;
    
    size = sizeof(clientFormat);
    err = ExtAudioFileSetProperty(outputFile, kExtAudioFileProperty_ClientDataFormat, size, &clientFormat);
    if (err != noErr) return NO;
    
    return YES;
}

#pragma mark - Conversion -

- (void)convertSynchronously:(ACConverterCallback)callback {
    if (noError == NO) {
        callback(ACConverterCallbackTypeError, 0, [NSError errorWithDomain:@"ACAudioConverter" code:1 userInfo:nil]);
        return;
    }
    
    SInt64 inputFileSize = 0;
    UInt32 _size = sizeof(inputFileSize);
    OSStatus err;
    
    err = ExtAudioFileGetProperty(inputFile, kExtAudioFileProperty_FileLengthFrames, &_size, &inputFileSize);
    if (err != noErr) {
        callback(ACConverterCallbackTypeError, 0, [NSError errorWithDomain:@"ExtAudioFileGetProperty"
                                                                      code:err
                                                                  userInfo:nil]);
        return;
    }
    
    UInt32 bytesForFrame = inputFormat.mBytesPerFrame ? inputFormat.mBytesPerFrame : 65536;
    UInt32 bufferSizeInFrames = 1024;
    UInt32 bufferSize = (bufferSizeInFrames * bytesForFrame);
    UInt8 * buffer = (UInt8 *)malloc(bufferSize);
    
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mNumberChannels = clientFormat.mChannelsPerFrame;
    bufferList.mBuffers[0].mData = buffer;
    bufferList.mBuffers[0].mDataByteSize = bufferSize;
    
    UInt64 encodedFrames = 0;
    int percent = 0;
    
    while (TRUE) {
        if ([[NSThread currentThread] isCancelled]) {
            [self dispose];
            free(buffer);
            return;
        }
        
        UInt32 framesRead = bufferSizeInFrames;
        err = ExtAudioFileRead(inputFile, &framesRead, &bufferList);
        if (err != noErr) {
            callback(ACConverterCallbackTypeError, 0, [NSError errorWithDomain:@"ExtAudioFileRead"
                                                                          code:err
                                                                      userInfo:nil]);
            free(buffer);
            return;
        }
        
        if (framesRead == 0) break;
        
        if ([[NSThread currentThread] isCancelled]) {
            [self dispose];
            free(buffer);
            return;
        }
        
        err = ExtAudioFileWrite(outputFile, framesRead, &bufferList);
        if (err != noErr) {
            callback(ACConverterCallbackTypeError, 0, [NSError errorWithDomain:@"ExtAudioFileWrite"
                                                                          code:err
                                                                      userInfo:nil]);
            free(buffer);
            return;
        }
        
        if ([[NSThread currentThread] isCancelled]) {
            [self dispose];
            free(buffer);
            return;
        }
        
        encodedFrames += framesRead;
        int newPercent = round((float)encodedFrames / (float)inputFileSize * 100);
        if (newPercent != percent) {
            percent = newPercent;
            callback(ACConverterCallbackTypeProgress, (float)encodedFrames / (float)inputFileSize, nil);
        }
    }
    
    free(buffer);
    [self dispose];
    
    if (![[NSThread currentThread] isCancelled]) {
        NSError * doneErr = nil;
        if (![self placeTempFile:&doneErr]) {
            callback(ACConverterCallbackTypeError, 0, doneErr);
        }
    }
}

- (void)dispose {
    if (inputFile) {
        ExtAudioFileDispose(inputFile);
        inputFile = NULL;
    }
    if (primInputFile) {
        AudioFileClose(primInputFile);
        primInputFile = NULL;
    }
    if (outputFile) {
        ExtAudioFileDispose(outputFile);
        outputFile = NULL;
    }
}

- (void)dealloc {
    [self dispose];
}

@end
