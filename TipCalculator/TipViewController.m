//
//  TipViewController.m
//  TipCalculator
//
//  Created by Rupa Satrasala on 1/12/15.
//  Copyright (c) 2015 Personal. All rights reserved.
//

#import "TipViewController.h"
#import "SettingsViewController.h"

@interface TipViewController ()
@property (strong, nonatomic) IBOutlet UITextField *billTextField;
@property (strong, nonatomic) IBOutlet UITextField *TotalSplitText;
@property (strong, nonatomic) IBOutlet UITextField *TotalAmountText;
@property (strong, nonatomic) IBOutlet UILabel *TipAmountText;

@property (strong, nonatomic) IBOutlet UILabel *tipTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *splitTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *tipPercentLabel;
@property (strong, nonatomic) IBOutlet UILabel *splitValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *currencyLabel;


@property (strong, nonatomic) IBOutlet UIImageView *tipImage;
@property (strong, nonatomic) IBOutlet UIImageView *totalImage;
@property (strong, nonatomic) IBOutlet UIImageView *totalSplitImage;

@property (strong, nonatomic) IBOutlet UISlider *tipSlider;
@property (strong, nonatomic) IBOutlet UISlider *splitSlider;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) NSString *currencySeparator;

- (IBAction)onTap:(id)sender;
- (void) updateValues;
- (void) hideEverything;
- (void) showEverything;
- (void) storeBillAmount;

@end

@implementation TipViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {  }
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];
    self.title = @"Tipper";
    _defaults = [NSUserDefaults standardUserDefaults];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(onSettingTapped)];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    _currencyLabel.text = [formatter currencySymbol];
    
    [self updateBillAmount];
    [self updateMainScreen];
    
}

- (void) updateBillAmount {
    
    NSDate *billTimerStart = (NSDate*)[_defaults objectForKey:@"bill_timer"];
    NSDate *timerPlus5mins = [billTimerStart dateByAddingTimeInterval:300];
    NSDate *now = [[NSDate alloc]init];
    
    if([now compare: timerPlus5mins] == NSOrderedAscending){
        float bill = [_defaults floatForKey:@"old_bill"];
        if ( bill>0) {
            _billTextField.text = [NSString stringWithFormat:@"%0.2f",bill];
        }
    }else {
        [_defaults setFloat:-1 forKey:@"old_bill"];
    }
}

-(void) storeBillAmount {
    NSDate *date = [[NSDate alloc] init];

    [_defaults setObject:date forKey:@"bill_timer"];
    NSLog(@"%0.2f", [_billTextField.text floatValue]);
    [_defaults setFloat:[_billTextField.text floatValue] forKey:@"old_bill"];
    NSMutableArray *array = [_defaults objectForKey:@"table_data"];
    if (array == nil) {
        array =  [[NSMutableArray alloc] initWithObjects:@"", nil];
    }

    if (_billTextField.text.length > 0) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithObjects:@"", nil];
        for (int i=0,j=0; i<array.count && i<=2; i++) {
            if (![[array objectAtIndex:i] isEqual: @""]) {
                [tempArray insertObject:[array objectAtIndex:i] atIndex:j];
                j++;
            }
        }
        [tempArray insertObject:[NSString stringWithFormat:@"%@      %@",date, _TotalAmountText.text ] atIndex:0];
        [_defaults setObject:tempArray forKey:@"table_data"];
    }
    
}

- (void) updateMainScreen {
    BOOL textAvailable = false;
    if(_billTextField.text.length > 0 && !textAvailable) {
        textAvailable=true;
        [self showEverything];
        [self updateSliders];
    } else {
        textAvailable=false;
        [self hideEverything];
        [_scrollView setContentOffset:CGPointZero animated:YES];
        [_billTextField resignFirstResponder];
    }
    
    [self updateValues];
    
}

- (void) updateSliders {
    int defaultTipPercent = (int)[_defaults integerForKey:@"default_tip"];
    int defaultSplit = (int)[_defaults integerForKey:@"default_split"];
    defaultSplit = defaultSplit==0?1:defaultSplit;
    
    _tipPercentLabel.text = [NSString stringWithFormat:@"%d", defaultTipPercent];
    _splitValueLabel.text = [NSString stringWithFormat:@"%d", defaultSplit];
  
    [_tipSlider setValue:defaultTipPercent];
    [_splitSlider setValue:defaultSplit];
}

- (void) showSplitTotalIfNecessary {
    int splitNumber = (int)_splitSlider.value;
    if (_billTextField.text.length == 0 || splitNumber==1) {
        _totalSplitImage.hidden = true;
        _TotalSplitText.hidden = true;
    }else{
        _totalSplitImage.hidden = false;
        _TotalSplitText.hidden = false;
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateSliders];
    [self updateValues];
    [self showSplitTotalIfNecessary];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerKeyboardNotification];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self deregisterKeyboardNotification];
    [self storeBillAmount];
    [super viewWillDisappear:animated];
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
    if (_billTextField.text.length==0) {
        [_billTextField becomeFirstResponder];
    }else {
        [self updateValues];
        [_billTextField resignFirstResponder];
    }
}

- (void) registerKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) deregisterKeyboardNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown: (NSNotification *)notification{
    
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect visibleRect = self.view.frame;
    visibleRect.size.height -= keyboardSize.height;
    
    CGPoint scrollPoint = CGPointMake(0.0, visibleRect.origin.y*2);
    [_scrollView setContentOffset:scrollPoint animated:YES];
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
  
    CGPoint scrollPoint = CGPointMake(0.0, self.view.frame.size.height*0.1);
    [_scrollView setContentOffset:scrollPoint animated:YES];
    
}

- (void) updateValues {
    
    float billAmount = [_billTextField.text floatValue];
    float tipValue = (int)_tipSlider.value;
    float splitValue = (int)_splitSlider.value;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:[NSLocale currentLocale]];
    
    float tipAmount = billAmount * tipValue/100;
    float totalAmount = billAmount + tipAmount;
    float splitTotalAmount = totalAmount/splitValue;
    /*_TipAmountText.text = [NSString stringWithFormat:@"$%0.2f", tipAmount];
    _TotalAmountText.text = [NSString stringWithFormat:@"$%0.2f", totalAmount];
    _TotalSplitText.text = [NSString stringWithFormat:@"%0.2f", splitTotalAmount];*/
    
    _TipAmountText.text = [formatter stringFromNumber:[NSNumber numberWithFloat:tipAmount]];
    _TotalAmountText.text = [formatter stringFromNumber:[NSNumber numberWithFloat:totalAmount]];
    _TotalSplitText.text = [formatter stringFromNumber:[NSNumber numberWithFloat:splitTotalAmount]];
    
}

- (void) onSettingTapped {
    [self.navigationController pushViewController:[SettingsViewController alloc] animated:YES];
}

- (IBAction)tipSliderValueChanged:(id)sender {
    _tipPercentLabel.text = [NSString stringWithFormat:@
                                 "%d", (int)_tipSlider.value];
}
- (IBAction)splitSliderValueChanged:(id)sender {
    _splitValueLabel.text = [NSString stringWithFormat:@
                                 "%d", (int)_splitSlider.value];
    [self showSplitTotalIfNecessary];
}

- (IBAction)amountTextFieldChanged:(id)sender {
    [self updateMainScreen];
}

- (void) hideEverything {
    _tipTextLabel.hidden = true;
    _tipSlider.hidden = true;
    _tipPercentLabel.hidden = true;
    
    _splitTextLabel.hidden = true;
    _splitSlider.hidden = true;
    _splitValueLabel.hidden = true;
    
    _tipImage.hidden = true;
    _TipAmountText.hidden = true;
    
    _totalImage.hidden = true;
    _TotalAmountText.hidden = true;
    
    _totalSplitImage.hidden = true;
    _TotalSplitText.hidden = true;
    
}

- (void) showEverything {
    _tipTextLabel.hidden = false;
    _tipSlider.hidden = false;
    _tipPercentLabel.hidden = false;
    
    _splitTextLabel.hidden = false;
    _splitSlider.hidden = false;
    _splitValueLabel.hidden = false;
    
    _tipImage.hidden = false;
    _TipAmountText.hidden = false;
    
    _totalImage.hidden = false;
    _TotalAmountText.hidden = false;
    
    [self showSplitTotalIfNecessary];
    
}

@end

