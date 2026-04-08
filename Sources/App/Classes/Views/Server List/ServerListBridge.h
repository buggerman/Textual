/* ObjC bridge for the SwiftUI server list to access IRCWorld data */

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// Snapshot of a channel for the SwiftUI server list.
@interface ServerListChannelSnapshot : NSObject
@property (nonatomic, copy) NSString *uniqueId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) BOOL isChannel;
@property (nonatomic, assign) BOOL isPrivateMessage;
@property (nonatomic, assign) NSUInteger unreadCount;
@property (nonatomic, assign) NSUInteger highlightCount;
@end

/// Snapshot of a server for the SwiftUI server list.
@interface ServerListServerSnapshot : NSObject
@property (nonatomic, copy) NSString *uniqueId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, copy) NSArray<ServerListChannelSnapshot *> *channels;
@end

/// Bridge between ObjC IRCWorld and SwiftUI ServerListModel.
@interface ServerListBridge : NSObject
+ (NSArray<ServerListServerSnapshot *> *)currentServers;
+ (nullable NSString *)selectedItemId;
+ (void)selectItemWithId:(NSString *)uniqueId;
+ (void)doubleClickItemWithId:(NSString *)uniqueId;
+ (nullable NSMenu *)serverContextMenu;
+ (nullable NSMenu *)channelContextMenuForItem:(NSString *)uniqueId;
@end

NS_ASSUME_NONNULL_END
