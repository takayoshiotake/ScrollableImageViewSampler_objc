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
    self.zoomScaleToFit = 0;
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
    self.zoomScale = 1;
    
    self.imageView.image = image;
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    [self updateZoomScales];
    [self setZoomScale:self.zoomScaleToFit animated:false];
}

- (void)setBounds:(CGRect)bounds {
    const CGRect boundsLast = self.bounds;
    [super setBounds:bounds];
    
    if (!CGSizeEqualToSize(boundsLast.size, bounds.size)) {
        [self updateZoomScales];
        if (self.shouldFitContent) {
            [self setZoomScale:self.zoomScaleToFit animated:false];
        }
    }
}

- (void)setContentOffset:(CGPoint)contentOffset {
    // Center the content when it is smaller than visible size.
    [super setContentOffset:[self computeActualContentOffset:contentOffset]];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    // Center the content when it is smaller than visible size.
    [super setContentOffset:[self computeActualContentOffset:contentOffset] animated:animated];
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    [super setContentInset:contentInset];
    
    [self updateZoomScales];
    if (self.shouldFitContent) {
        [self setZoomScale:self.zoomScaleToFit animated:false];
    }
}

- (CGSize)visibleSize {
    return CGSizeMake(self.bounds.size.width - self.contentInset.left - self.contentInset.right, self.bounds.size.height - self.contentInset.top - self.contentInset.bottom);
}

- (CGPoint)computeActualContentOffset:(CGPoint)prefferedContentOffset {
    CGPoint contentOffset = prefferedContentOffset;
    const CGSize contentSize = self.contentSize;
    const UIEdgeInsets contentInset = self.contentInset;
    const CGSize visibleSize = self.visibleSize;
    if (contentSize.width <= visibleSize.width) {
        contentOffset.x = -((visibleSize.width - contentSize.width) / 2 + contentInset.left);
    }
    if (contentSize.height <= visibleSize.height) {
        contentOffset.y = -((visibleSize.height - contentSize.height) / 2 + contentInset.top);
    }
    return contentOffset;
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
    self.zoomScaleToFit = MIN(MAX(zoomScaleToFit, self.minimumZoomScale), self.maximumZoomScale);
    
    if (self.zoomScale > self.maximumZoomScale) {
        [self setZoomScale:self.maximumZoomScale animated:false];
    }
    else if (self.zoomScale < self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:false];
    }
}

- (void)didRecognizeDoubleTap:(UITapGestureRecognizer *)recognizer {
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

@end

@implementation BBScrollableImageView (UIScrollViewDelegate)

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.shouldFitContent = self.zoomScale == self.zoomScaleToFit;
}

@end
