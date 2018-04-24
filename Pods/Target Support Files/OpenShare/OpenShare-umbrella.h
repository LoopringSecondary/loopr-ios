#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "OpenShare+Alipay.h"
#import "OpenShare+QQ.h"
#import "OpenShare+Renren.h"
#import "OpenShare+Weibo.h"
#import "OpenShare+Weixin.h"
#import "OpenShare.h"
#import "OpenShareHeader.h"

FOUNDATION_EXPORT double OpenShareVersionNumber;
FOUNDATION_EXPORT const unsigned char OpenShareVersionString[];

