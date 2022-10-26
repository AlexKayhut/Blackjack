//
//  Player.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "Player.h"

@interface Player ()

@property (nonatomic, weak, nullable) id<PlayerDelegate> delegate;

@end

@implementation Player
- (instancetype)initWithName:(NSString *)name cards:(NSArray *)cards chips:(NSInteger)chips state:(ContestantState)state delegate:(id<PlayerDelegate>)delegate {
  self = [super initWithName:name cards:cards chips:chips state:state];
  if (self) {
    _delegate = delegate;
  }
  return self;
}

- (instancetype)initWithName:(NSString *)name chips:(NSInteger)chips delegate:(id<PlayerDelegate>)delegate {
  self = [super initWithName:name chips:chips];
  if (self) {
    _delegate = delegate;
  }
  return self;
}

- (void)setState:(ContestantState)state {
  [super setState:state];
  [self.delegate hasNewChangesForPlayer:self];
}

@end
