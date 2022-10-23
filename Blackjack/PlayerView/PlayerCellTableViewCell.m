//
//  PlayerCellTableViewCell.m
//  Blackjack
//
//  Created by Alex on 29/09/2022.
//

#import "PlayerCellTableViewCell.h"

@implementation PlayerCellTableViewCell

- (void)prepareForReuse {
  [super prepareForReuse];
  super.backgroundColor = UIColor.whiteColor;
  self.name.text = @"";
  self.chips.text = @"";
  self.currentBet.text = @"";
}

+ (NSString *)identifier {
  return @"PlayerCellTableViewCell";
}

@end
