//
//  DCControl.m
//
//  Copyright 2011 Domestic Cat. All rights reserved.
//

#import "DCControl.h"

@implementation DCControl
@synthesize delegate;
@synthesize color;
@synthesize labelFont, labelColor, labelOffset;
@synthesize min, max, value;
@synthesize displaysValue, allowsTapGestures, allowsTouchGestures;

- (void)dealloc
{
	delegate = nil;
}

#pragma mark -

- (id)initWithDelegate:(id)aDelegate
{
	if ((self = [super init]))
	{
		self.delegate = aDelegate;
        [self setDefaults];		
	}

	return self;
}

- (void)setDefaults
{
    self.color = [UIColor blueColor];
    self.min = 0.0;
    self.max = 1.0;
    self.displaysValue = YES;
    self.allowsTapGestures = YES;
    self.allowsTouchGestures = YES;
    self.labelFont = [UIFont boldSystemFontOfSize:12.5];
    
    self.clipsToBounds = NO;
    self.opaque = YES;
}

- (void)setValue:(float)newValue
{
	if (newValue > self.max)
		value = self.max;
	else if (newValue < self.min)
		value = self.min;
	else
		value = newValue;
	if (self.delegate)
		[self.delegate controlValueDidChange:self.value sender:self];

	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark Helper Methods

- (void)context:(CGContextRef)c addRoundedRect:(CGRect)rect cornerRadius:(float)cornerRadius
{
	rect.size.width += 0.5;
	int x_left = rect.origin.x;
	int x_left_center = rect.origin.x + cornerRadius;
	int x_right_center = rect.origin.x + rect.size.width - cornerRadius;
	int x_right = rect.origin.x + rect.size.width;
	int y_top = rect.origin.y;
	int y_top_center = rect.origin.y + cornerRadius;
	int y_bottom_center = rect.origin.y + rect.size.height - cornerRadius;
	int y_bottom = rect.origin.y + rect.size.height;

	/* Begin! */
	CGContextBeginPath(c);
	CGContextMoveToPoint(c, x_left, y_top_center);

	/* First corner */
	CGContextAddArcToPoint(c, x_left, y_top, x_left_center, y_top, cornerRadius);
	CGContextAddLineToPoint(c, x_right_center, y_top);

	/* Second corner */
	CGContextAddArcToPoint(c, x_right, y_top, x_right, y_top_center, cornerRadius);
	CGContextAddLineToPoint(c, x_right, y_bottom_center);

	/* Third corner */
	CGContextAddArcToPoint(c, x_right, y_bottom, x_right_center, y_bottom, cornerRadius);
	CGContextAddLineToPoint(c, x_left_center, y_bottom);

	/* Fourth corner */
	CGContextAddArcToPoint(c, x_left, y_bottom, x_left, y_bottom_center, cornerRadius);
	CGContextAddLineToPoint(c, x_left, y_top_center);

	/* Done */
	CGContextClosePath(c);	
}

#pragma mark - Gesture states

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(controlGestureStateDidChange:sender:)]) {
        [self.delegate controlGestureStateDidChange:UIGestureRecognizerStateBegan sender:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(controlGestureStateDidChange:sender:)]) {
        [self.delegate controlGestureStateDidChange:UIGestureRecognizerStateChanged sender:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(controlGestureStateDidChange:sender:)]) {
        [self.delegate controlGestureStateDidChange:UIGestureRecognizerStateEnded sender:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(controlGestureStateDidChange:sender:)]) {
        [self.delegate controlGestureStateDidChange:UIGestureRecognizerStateCancelled sender:self];
    }
}

@end
