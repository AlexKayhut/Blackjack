//
//  Contestant.h
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import <Foundation/Foundation.h>

@interface Contestant : NSObject

- (instancetype _Nonnull)initWithName:(NSString *_Nonnull)name;

@property (nonatomic, readonly, copy, nonnull) NSString *identifier;
@property (nonatomic, readonly, copy, nonnull) NSString *name;


@end
