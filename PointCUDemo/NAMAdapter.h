//
//  NAMAdapter.h
//  AdPopcornSSP
//
//  Created by mick on 2022. 9. 27..
//  Copyright (c) 2022년 adpopcorn All rights reserved.
//

@import GFPSDK;
@import AdPopcornSSP;

@interface NAMAdapter : AdPopcornSSPAdapter
{
    GFPAdLoader *adLoader;
    GFPBannerView *gfpBannerView, *gfpModalBannerView;
    GFPNativeSimpleAd *gfpNativeSimpleAd;
    GFPNativeAd *gfpNativeAd;
}

@end

@interface APNAMNativeAdRenderer: NSObject
@property (strong, nonatomic)  UIView *namNativeSuperView;
@property (strong, nonatomic) GFPNativeSimpleAdView *namNativeSimpleAdView;
@property (strong, nonatomic) GFPNativeAdView *namNativeAdView;
@property (strong, nonatomic) GFPAdDedupeManager *namDedupeManager;
@property (strong, nonatomic) GFPNativeAdRenderingSetting *GFPNativeSetting;
@property (strong, nonatomic) GFPNativeSimpleAdRenderingSetting *GFPNativeSimpleSetting;
@property (nonatomic, assign) NSTimeInterval timeOut;
@property (assign, nonatomic) BOOL backgroundBlur;
@end

