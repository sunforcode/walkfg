#!/bin/bash

# 创建临时目录
mkdir -p temp_fonts

# 下载 NotoSansSC 字体文件
echo "正在下载 NotoSansSC 字体文件..."

# 下载 Regular 字重
curl -L "https://github.com/googlefonts/noto-cjk/raw/main/Sans/OTF/Chinese_Simplified/NotoSansSC-Regular.otf" -o temp_fonts/NotoSansSC-Regular.otf

# 下载 Medium 字重
curl -L "https://github.com/googlefonts/noto-cjk/raw/main/Sans/OTF/Chinese_Simplified/NotoSansSC-Medium.otf" -o temp_fonts/NotoSansSC-Medium.otf

# 下载 Bold 字重
curl -L "https://github.com/googlefonts/noto-cjk/raw/main/Sans/OTF/Chinese_Simplified/NotoSansSC-Bold.otf" -o temp_fonts/NotoSansSC-Bold.otf

# 下载 Light 字重
curl -L "https://github.com/googlefonts/noto-cjk/raw/main/Sans/OTF/Chinese_Simplified/NotoSansSC-Light.otf" -o temp_fonts/NotoSansSC-Light.otf

# 移动字体文件到 assets/fonts 目录
echo "正在复制字体文件到 assets/fonts 目录..."
cp temp_fonts/*.otf assets/fonts/

# 清理临时目录
rm -rf temp_fonts

echo "字体文件下载完成！"