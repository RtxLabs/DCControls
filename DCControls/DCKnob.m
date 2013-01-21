//
//  DCKnob.m
//
//  Copyright 2011 Domestic Cat. All rights reserved.
//

#import "DCKnob.h"

@implementation DCKnob
@synthesize biDirectional, arcStartAngle, cutoutSize, valueArcWidth;
@synthesize singleTapValue, doubleTapValue, tripleTapValue;
@synthesize arcBackgroundColor, arcForegroundColor;

#pragma mark -
#pragma mark Init

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        [self setDefaults];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
	{
        [self setDefaults];
    }
    
    return self;
}

- (id)initWithDelegate:(id)aDelegate
{
	if ((self = [super initWithDelegate:aDelegate]))
	{
		[self setDefaults];
	}

	return self;
}

- (void)setDefaults
{
    [super setDefaults];
    
    self.arcStartAngle = 90.0;
    self.cutoutSize = 60.0;
    self.valueArcWidth = 15.0;
    self.arcBackgroundColor = [UIColor grayColor];
    self.arcForegroundColor = [UIColor blueColor];
    
    self.valueFormatString = @"%02.0f%%";
    
    // add the gesture recognizers for taps
    UITapGestureRecognizer *tripleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tripleTap:)];
    tripleTapGesture.numberOfTapsRequired = 3;
    [self addGestureRecognizer:tripleTapGesture];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [doubleTapGesture requireGestureRecognizerToFail:tripleTapGesture];
    [self addGestureRecognizer:doubleTapGesture];
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTapGesture.numberOfTapsRequired = 1;
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    [self addGestureRecognizer:singleTapGesture];
}

// overridden to make sure the frame is always square.
- (void)setFrame:(CGRect)frame
{
	if (frame.size.width != frame.size.height)
	{
		if (frame.size.width > frame.size.height)
			frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width);
		else
			frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, frame.size.height);
	}

	[super setFrame:frame];
}

#pragma mark -
#pragma mark Gestures

- (void)singleTap:(UIGestureRecognizer *)gestureRecognizer
{
	if (self.allowsTapGestures)
	{
		self.value = self.singleTapValue;
	}
}

- (void)doubleTap:(UIGestureRecognizer *)gestureRecognizer
{
	if (self.allowsTapGestures)
	{
		self.value = self.doubleTapValue;
	}
}

- (void)tripleTap:(UIGestureRecognizer *)gestureRecognizer
{
	if (self.allowsTapGestures)
	{
		self.value = self.tripleTapValue;
	}
}

#pragma mark -
#pragma mark Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.allowsTouchGestures)
    {
        CGPoint thisPoint = [[touches anyObject] locationInView:self];
        CGPoint centerPoint = CGPointMake(self.frame.size.width / 2.0, self.frame.size.width / 2.0);
        initialAngle = angleBetweenPoints(thisPoint, centerPoint);

        // create the initial angle and initial transform
        initialTransform = [self initialTransform];
        [super touchesBegan:touches withEvent:event];

    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.allowsTouchGestures)
    {
        CGPoint thisPoint = [[touches anyObject] locationInView:self];
        CGPoint centerPoint = CGPointMake(self.frame.size.width / 2.0, self.frame.size.width / 2.0);

        CGFloat currentAngle = angleBetweenPoints(thisPoint, centerPoint);
        CGFloat angleDiff = (initialAngle - currentAngle);
        CGAffineTransform newTransform = CGAffineTransformRotate(initialTransform, angleDiff);

        CGFloat newValue = [self newValueFromTransform:newTransform];

        // only set the new value if it doesn't flip the knob around
        CGFloat diff = self.value - newValue;
        diff = (diff < 0) ? -diff : diff;
        if (diff < (self.max - self.min) / 10.0)
        {
            self.value = newValue;
        }
        else
        {
            // reset the initial angle & transform using the current value
            initialTransform = [self initialTransform];
            initialAngle = angleBetweenPoints(thisPoint, centerPoint);
        }
        [super touchesMoved:touches withEvent:event];
    }
}

#pragma mark -
#pragma mark Helper Methods

- (CGAffineTransform)initialTransform
{
	CGFloat pValue = (self.value - self.min) / (self.max - self.min);
	pValue = (pValue * kDCKnobRatio * 2) - kDCKnobRatio;
	return CGAffineTransformMakeRotation(pValue);
}

- (CGFloat)newValueFromTransform:(CGAffineTransform)transform
{
	CGFloat newValue = atan2(transform.b, transform.a);
	newValue = (newValue + kDCKnobRatio) / (kDCKnobRatio * 2);
	newValue = self.min + (newValue * (self.max - self.min));
	return newValue;
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect boundsRect = self.bounds;
	CGFloat maxHalf = self.min + (self.max - self.min) / 2;
	float x = boundsRect.size.width / 2;
	float y = boundsRect.size.height / 2;

	CGContextSaveGState(context);
	CGContextSetLineWidth(context, self.valueArcWidth);
	
    // outline semi circle
    const CGFloat *backgroundColorComponents = CGColorGetComponents(self.arcBackgroundColor.CGColor);
    CGContextSetStrokeColor(context, backgroundColorComponents);

    CGContextAddArc(context,
                    x,
                    y,
                    (boundsRect.size.width / 2) - self.valueArcWidth / 2,
                    kDCControlDegreesToRadians(self.arcStartAngle + self.cutoutSize / 2),
                    kDCControlDegreesToRadians(self.arcStartAngle + 360 - self.cutoutSize / 2),
                    0);
    CGContextStrokePath(context);
	
    
	// draw the value semi circle
    const CGFloat *colorComponents = CGColorGetComponents(self.arcForegroundColor.CGColor);
    CGContextSetStrokeColor(context, colorComponents);
    
	CGFloat valueAdjusted = (self.value - self.min) / (self.max - self.min);
	if (self.biDirectional)
	{
		CGContextAddArc(context,
						x,
						y,
						(boundsRect.size.width / 2) - self.valueArcWidth / 2,
						kDCControlDegreesToRadians(self.arcStartAngle + 180),
						kDCControlDegreesToRadians(self.arcStartAngle + self.cutoutSize / 2 + (360 - self.cutoutSize) * valueAdjusted),
						self.value <= maxHalf);
	}
	else
	{
		CGContextAddArc(context,
						x,
						y,
						(boundsRect.size.width / 2) - self.valueArcWidth / 2,
						kDCControlDegreesToRadians(self.arcStartAngle + self.cutoutSize / 2),
						kDCControlDegreesToRadians(self.arcStartAngle + self.cutoutSize / 2 + (360 - self.cutoutSize) * valueAdjusted),
						0);
	}
	CGContextStrokePath(context);

	// draw the value string as needed
	if (self.displaysValue)
	{
		if (self.labelColor)
			[self.labelColor set];
		else
			[self.color set];
		NSString *valueString = nil;
		if (self.biDirectional)
			valueString = [NSString stringWithFormat:self.valueFormatString, ((self.value - self.min - (self.max - self.min) / 2) / (self.max - self.min)) * 100];
		else
			valueString = [NSString stringWithFormat:self.valueFormatString, ((self.value - self.min) / (self.max - self.min)) * 100];
		CGSize valueStringSize = [valueString sizeWithFont:self.labelFont
												  forWidth:boundsRect.size.width
											 lineBreakMode:UILineBreakModeTailTruncation];
		[valueString drawInRect:CGRectMake(floorf((boundsRect.size.width - valueStringSize.width) / 2.0 + self.labelOffset.x),
										   floorf((boundsRect.size.height - valueStringSize.height) / 2.0 + self.labelOffset.y),
										   valueStringSize.width,
										   valueStringSize.height)
					   withFont:self.labelFont
				  lineBreakMode:UILineBreakModeTailTruncation];		
	}

	CGContextRestoreGState(context);
}

@end
