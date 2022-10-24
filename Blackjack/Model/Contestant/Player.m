//
//  Player.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "Player.h"
#import "PlayingCard.h"
#import "BlackjackGame.h"

@implementation Player

@synthesize state = _state;
@synthesize identifier = _identifier;

- (ContestantState)state {
    if (!_state) {
        _state = PLAYING;
    }
    return _state;
}

- (NSString *)identifier {
    if (!_identifier) {
        _identifier = [[NSUUID UUID] UUIDString];
    }
    return _identifier;
}

- (instancetype)initWithName:(NSString *)name chips:(NSInteger)chips delegate:(id)delegate {
    self = [super initWithName:name chips:chips];
    if (self) {
        super._delegate = delegate;
    }
    return self;
}
@end
