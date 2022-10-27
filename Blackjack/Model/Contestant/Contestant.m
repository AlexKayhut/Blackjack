//
//  Contestant.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "Contestant.h"

@implementation Contestant

- (instancetype)initWithName:(NSString *)name {
  self = [super init];
  if (self) {
    _identifier = [[NSUUID UUID] UUIDString];
    _name = name;
  }
  return self;
}

@end
