//
//  Card.h
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

@import Foundation;

@interface Card : NSObject

@property (strong, nonatomic, readonly) NSString *contents;
@property (nonatomic) BOOL isFaceUp;

@end
