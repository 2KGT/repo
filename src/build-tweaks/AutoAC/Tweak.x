// =========================================================
// 🛠 HOOK KÍCH HOẠT CHO CẢ YOUTUBE & FACEBOOK
// =========================================================

// YouTube: Nhấn vào Logo (góc trái)
%hook YTHeaderView
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    %orig;
    UIView *v = (UIView *)self;
    CGPoint loc = [[touches anyObject] locationInView:v];
    // Chạm 1/3 bên trái thanh Header
    if (loc.x < v.frame.size.width / 3.0) {
        showAutoACMenu();
    }
}
%end

// Facebook: Nhấn vào Logo hoặc vùng tiêu đề bên trái
%hook FBNavigationBar
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    %orig;
    UIView *v = (UIView *)self;
    CGPoint loc = [[touches anyObject] locationInView:v];
    
    // Facebook Logo thường nằm ở phía bên trái. 
    // Chúng ta bắt sự kiện nếu chạm vào vùng 1/4 bên trái của thanh điều hướng.
    if (loc.x < v.frame.size.width / 4.0) {
        showAutoACMenu();
    }
}
%end
