// Copyright 2015 Google Inc.

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#import <GoogleCast/GCKDefines.h>

#ifdef USE_CAST_DYNAMIC_FRAMEWORK
#define GCKFrameworkResourcesClass NSClassFromString(@"GCKFrameworkResources")
#endif

GCK_ASSUME_NONNULL_BEGIN

/**
 * A singleton object that provides access to the framework's resource bundle.
 *
 * @since 3.0
 */
GCK_EXPORT
@interface GCKFrameworkResources : NSObject

/** Returns the singleton instance. */
+ (instancetype)sharedInstance;

/** The framework's resource bundle. */
@property(nonatomic, readonly) NSBundle *bundle;

#if TARGET_OS_IPHONE

/**
 * Loads and returns the framework image resource with the given filename.
 *
 * @param name The name of the resource.
 * @return The image.
 */
- (UIImage *)imageNamed:(NSString *)name;

/**
 * Loads and returns the framework image resource with the given filename and rendering mode.
 *
 * @param name The name of the resource.
 * @param renderingMode The image rendering mode.
 * @return The image.
 */
- (UIImage *)imageNamed:(NSString *)name withRenderingMode:(UIImageRenderingMode)renderingMode;

/**
 * Loads and returns the framework Nib resource with the given filename.
 *
 * @param name The name of the resource.
 * @param owner The object that will own the Nib.
 * @param objects Replacement objects for the Nib. May be <code>nil</code> if none are required.
 */
- (NSArray *)nibNamed:(NSString *)name
                 owner:(id)owner
    replacementObjects:(NSDictionary *GCK_NULLABLE_TYPE)objects;

/**
 * Loads and returns the storyboard resource with the given filename.
 *
 * @param name The name of the resource.
 */
- (UIStoryboard *)storyboardNamed:(NSString *)name;

#endif  // TARGET_OS_IPHONE

@end

GCK_ASSUME_NONNULL_END
