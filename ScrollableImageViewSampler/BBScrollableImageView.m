//
//  BBScrollableImageView.m
//  ScrollableImageViewSampler
//
//  Created by Takayoshi Otake on 2015/10/21.
//  Copyright © 2015 Takayoshi Otake. All rights reserved.
//

#import "BBScrollableImageView.h"

@interface BBScrollableImageView ()

@property (weak, nonatomic) UIImageView *imageView;
@property (assign, atomic, readwrite) CGFloat zoomScaleToFit;
@property (assign, atomic) BOOL shouldFitContent;

@end

@interface BBScrollableImageView (UIScrollViewDelegate) <UIScrollViewDelegate>
@end

@implementation BBScrollableImageView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self init_];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self init_];
    return self;
}

- (void)init_ {
    self.zoomScaleToFit = NAN;
    self.delegate = self;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:imageView];
    self.imageView = imageView;
}

- (void)awakeFromNib {
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeDoubleTap:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:doubleTapRecognizer];
}

- (void)dealloc {
}


- (UIImage *)image {
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image {
    // NOTE: This is very important; This prevents the image is displayed strangely larger.
    self.imageView.image = nil; // Disables "scrollViewDidZoom:"
    [self setZoomScale:1.0 animated:false];
    
    self.imageView.image = image;
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    [self updateZoomScales];
    if (!isnan(self.zoomScaleToFit) && (self.zoomScale != self.zoomScaleToFit)) {
        [self setZoomScale:self.zoomScaleToFit animated:false];
    }
    else {
        [self setZoomScale:1.0 animated:false];
        [self scrollViewDidZoom:self];
    }
}

- (void)setBounds:(CGRect)bounds {
    const CGRect boundsLast = self.bounds;
    [super setBounds:bounds];
    
    if (!CGSizeEqualToSize(boundsLast.size, self.bounds.size)) {
        [self updateZoomScales];
        if (self.shouldFitContent) {
            [self setZoomScale:self.zoomScaleToFit animated:false];
        }
        
        [self layoutImageViewIfNeeded];
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    const UIEdgeInsets contentInsetLast = self.contentInset;
    [super setContentInset:contentInset];
    
    if (!UIEdgeInsetsEqualToEdgeInsets(contentInsetLast, self.contentInset)) {
        [self updateZoomScales];
        if (self.shouldFitContent) {
            [self setZoomScale:self.zoomScaleToFit animated:false];
        }
        
        [self layoutImageViewIfNeeded];
    }
}

- (CGSize)visibleSize {
    return CGSizeMake(self.bounds.size.width - self.contentInset.left - self.contentInset.right, self.bounds.size.height - self.contentInset.top - self.contentInset.bottom);
}

- (void)updateZoomScales {
    const CGSize imageSize = self.imageView.image.size;
    const CGSize visibleSize = self.visibleSize;
    
    if (imageSize.width == 0 || imageSize.height == 0) {
        return;
    }
    
    const CGFloat zoomScaleToFit = MIN(visibleSize.width / imageSize.width, visibleSize.height / imageSize.height);
    self.maximumZoomScale = 1;
    self.minimumZoomScale = MIN(self.maximumZoomScale, zoomScaleToFit);
    if (self.minimumZoomScale == self.maximumZoomScale) {
        self.zoomScaleToFit = NAN;
        self.shouldFitContent = false;
    }
    else {
        self.zoomScaleToFit = MIN(MAX(zoomScaleToFit, self.minimumZoomScale), self.maximumZoomScale);
    }
    
    if (self.zoomScale > self.maximumZoomScale) {
        [self setZoomScale:self.maximumZoomScale animated:false];
    }
    else if (self.zoomScale < self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:false];
    }
}

- (void)didRecognizeDoubleTap:(UITapGestureRecognizer *)recognizer {
    if (isnan(self.zoomScaleToFit)) {
        return;
    }
    
    if (self.zoomScale == self.zoomScaleToFit) {
        const CGFloat zoomScale = self.maximumZoomScale;
        
        const CGPoint center = [recognizer locationInView:self.imageView];
        const CGFloat width = self.bounds.size.width / zoomScale;
        const CGFloat height = self.bounds.size.height / zoomScale;
        const CGFloat x = center.x - width / 2;
        const CGFloat y = center.y - height / 2;
        [self zoomToRect:CGRectMake(x, y, width, height) animated:true];
    }
    else {
        [self setZoomScale:self.zoomScaleToFit animated:true];
    }
}

- (void)layoutImageViewIfNeeded {
    CGRect contentFrame = self.imageView.frame;
    CGSize visibleSize = self.visibleSize;
    
    contentFrame.origin = CGPointZero;
    if (contentFrame.size.width < visibleSize.width) {
        contentFrame.origin.x = (visibleSize.width - contentFrame.size.width) / 2;
    }
    if (contentFrame.size.height < visibleSize.height) {
        contentFrame.origin.y = (visibleSize.height - contentFrame.size.height) / 2;
    }

    if (!CGRectEqualToRect(self.imageView.frame, contentFrame)) {
        self.imageView.frame = contentFrame;
    }
}

#pragma mark <UIScrollViewDelegate>

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (!self.imageView.image) {
        return;
    }
    
    self.shouldFitContent = self.zoomScale == self.zoomScaleToFit;
    [self layoutImageViewIfNeeded];
}

@end
