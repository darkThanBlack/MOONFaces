//
//  DlibWrapper.h
//  MOONFaces
//
//  Created by 徐一丁 on 2020/7/3.
//  Copyright © 2020 徐一丁. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface DlibWrapper : NSObject

- (instancetype)init;
- (void)prepare;
- (void)doWorkOnSampleBuffer:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)rects;
- (void)doWorkOnImagePath:(NSString*)imagePath savePath:(NSString*)savePath;
@end


NS_ASSUME_NONNULL_END
