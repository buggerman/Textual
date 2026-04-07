/* *********************************************************************
 *
 * ObjC interface for IRCLineParser (implemented in Swift).
 *
 *********************************************************************** */

NS_ASSUME_NONNULL_BEGIN

@interface IRCLineParserResult : NSObject
@property (readonly, copy) NSDictionary<NSString *, NSString *> *tags;
@property (readonly, copy, nullable) NSString *senderString;
@property (readonly, copy) NSString *command;
@property (readonly) NSInteger commandNumeric;
@property (readonly, copy) NSArray<NSString *> *params;
@property (readonly, copy, nullable) NSString *senderNickname;
@property (readonly, copy, nullable) NSString *senderUsername;
@property (readonly, copy, nullable) NSString *senderAddress;
@property (readonly) BOOL senderIsServer;
@end

@interface IRCLineParser : NSObject
+ (nullable IRCLineParserResult *)parse:(NSString *)line;
@end

NS_ASSUME_NONNULL_END
