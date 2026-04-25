#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - 💎 GIAO DIỆN CÀI ĐẶT CHUẨN (AUTHENTIC SETTINGS)

@interface AutoACSettingsVC : UITableViewController
@end

@implementation AutoACSettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.scrollEnabled = NO;
    // Sử dụng màu nền trong suốt để lộ lớp kính mờ của Action Sheet
    self.tableView.backgroundColor = [UIColor clearColor];
    // Bo góc cho toàn bộ bảng
    self.tableView.layer.cornerRadius = 12;
    self.tableView.clipsToBounds = YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0; // Chiều cao chuẩn của dòng Settings iOS
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"SettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }

    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    // --- TẠO ICON MÀU SẮC BO TRÒN (GIỐNG ẢNH MẪU) ---
    UIView *iconBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    iconBG.layer.cornerRadius = 7;
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 18, 18)];
    iconView.tintColor = [UIColor whiteColor];
    iconView.contentMode = UIViewContentModeScaleAspectFit;

    if (indexPath.row == 0) {
        cell.textLabel.text = @"Tự động tối ưu";
        iconBG.backgroundColor = [UIColor systemGreenColor]; // Màu xanh lá cho tối ưu
        iconView.image = [UIImage systemImageNamed:@"bolt.fill"];
        
        UISwitch *sw1 = [[UISwitch alloc] init];
        sw1.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"AutoC_SmartClean_Enabled"];
        [sw1 addTarget:self action:@selector(sw1Changed:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = sw1;
    } else {
        cell.textLabel.text = @"Xoá Ads banner tag";
        iconBG.backgroundColor = [UIColor systemBlueColor]; // Màu xanh dương cho Ads
        iconView.image = [UIImage systemImageNamed:@"megaphone.fill"];
        
        UISwitch *sw2 = [[UISwitch alloc] init];
        sw2.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"AutoC_RemoveAds_Enabled"];
        [sw2 addTarget:self action:@selector(sw2Changed:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = sw2;
    }

    [iconBG addSubview:iconView];
    cell.imageView.image = [self imageFromView:iconBG];

    return cell;
}

// Hàm hỗ trợ biến View thành Image để đặt vào ImageView của Cell
- (UIImage *)imageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)sw1Changed:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"AutoC_SmartClean_Enabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)sw2Changed:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"AutoC_RemoveAds_Enabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

static void showAutoACMenu() {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tối ưu hệ thống" message:@"\n\n\n\n" preferredStyle:UIAlertControllerStyleActionSheet];
    
    AutoACSettingsVC *tableVC = [[AutoACSettingsVC alloc] initWithStyle:UITableViewStylePlain];
    tableVC.preferredContentSize = CGSizeMake(270, 100);
    [alert setValue:tableVC forKey:@"contentViewController"];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Dọn dẹp sâu" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        // Gọi hàm dọn dẹp...
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];

    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    UIViewController *top = window.rootViewController;
    while(top.presentedViewController) top = top.presentedViewController;
    [top presentViewController:alert animated:YES completion:nil];
}
