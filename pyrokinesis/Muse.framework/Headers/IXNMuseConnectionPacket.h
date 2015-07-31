// AUTOGENERATED FILE - DO NOT MODIFY!
// This file generated by Djinni from packets.djinni

#import "IXNConnectionState.h"
#import <Foundation/Foundation.h>
@class IXNSenderInformation;

/** Packet provides information about connection state. */

@interface IXNMuseConnectionPacket : NSObject
- (id)initWithMuseConnectionPacket:(IXNMuseConnectionPacket *)museConnectionPacket;
- (id)initWithSource:(IXNSenderInformation *)source previousConnectionState:(IXNConnectionState)previousConnectionState currentConnectionState:(IXNConnectionState)currentConnectionState;

/** Information about the Muse which sent the packet. */
@property (nonatomic, readonly) IXNSenderInformation *source;

/** Provides access to the previous connection status. */
@property (nonatomic, readonly) IXNConnectionState previousConnectionState;

/**  Provides access to the current connection status. */
@property (nonatomic, readonly) IXNConnectionState currentConnectionState;

@end
