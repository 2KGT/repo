#!/bin/bash

# Cấu hình đường dẫn (Phẳng hóa)
RAW_HEADERS="src/refinery/staging/headers"
CLEAN_REPO="headers-repo/YouTube"

echo "🥩 Bắt đầu lọc xương tại Refinery..."

# 1. Quét và xử lý từng file .h
find "$RAW_HEADERS" -type f -name "*.h" | while read -r file; do
    filename=$(basename "$file")
    
    # Lọc xương: Xoá import nội bộ, giữ lại import hệ thống
    # Tiêm thuốc: Thêm forward declaration (@class) để bắc cầu
    sed -E -e '/#import ".*"/d' \
           -e '/#include ".*"/d' \
           -i '' "$file"
    
    # Tiêm danh sách @class phổ biến để tránh lỗi "Unknown type"
    echo -e "@class NSString, NSArray, NSDictionary, UIView, UIViewController, NSData;\n$(cat "$file")" > "$file"
    
    # Di biếu: Chuyển hàng sạch về kho ngoài Root
    mv "$file" "$CLEAN_REPO/$filename"
done

echo "✅ Đã lọc xong nạc. Hàng đã về kho: $CLEAN_REPO"
