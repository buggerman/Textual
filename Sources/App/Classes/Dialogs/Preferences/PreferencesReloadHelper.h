/* ObjC helper to call TPCPreferences reload actions from Swift */

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface PreferencesReloadHelper : NSObject
+ (void)performReload:(NSUInteger)action;
@end

NS_ASSUME_NONNULL_END
