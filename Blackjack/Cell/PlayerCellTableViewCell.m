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
    self.cardEvaluationLabel.text = @"";
  self.backgroundColor = UIColor.clearColor;
}

- (void)updateTextColorTo:(UIColor *)color {
    self.name.textColor = color;
    self.chips.textColor = color;
    self.currentBet.textColor = color;
    self.cardEvaluationLabel.textColor = color;
}

+ (NSString *)identifier {
  return @"PlayerCellTableViewCell";
}

@end
