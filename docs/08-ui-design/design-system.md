# HỆ THỐNG THIẾT KẾ UX/UI NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Bảng màu](#2-bảng-màu)
3. [Typography](#3-typography)
4. [Iconography](#4-iconography)
5. [Spacing](#5-spacing)
6. [Elevation](#6-elevation)
7. [Border Radius](#7-border-radius)
8. [Grid System](#8-grid-system)
9. [Dark Mode](#9-dark-mode)
10. [Tổng kết](#10-tổng-kết)
11. [Tài liệu tham khảo](#11-tài-liệu-tham-khảo)

## 1. GIỚI THIỆU

Hệ thống thiết kế của NextFlow CRM-AI là tập hợp các quy tắc, hướng dẫn và thành phần được chuẩn hóa để đảm bảo tính nhất quán và hiệu quả trong thiết kế và phát triển giao diện người dùng. Tài liệu này mô tả chi tiết về các yếu tố cơ bản của hệ thống thiết kế, bao gồm màu sắc, typography, iconography, spacing và elevation.

## 2. BẢNG MÀU

### 2.1. Màu chính (Primary Colors)

Màu chính được sử dụng cho các yếu tố chính trong giao diện, như nút chính, liên kết, và các yếu tố tương tác quan trọng.

| Tên | Mã màu | Mẫu | Mục đích sử dụng |
|-----|--------|------|-----------------|
| Primary | #3366FF | ![#3366FF](https://via.placeholder.com/15/3366FF/000000?text=+) | Màu chủ đạo, sử dụng cho các yếu tố chính |
| Primary Dark | #0044CC | ![#0044CC](https://via.placeholder.com/15/0044CC/000000?text=+) | Hover, active states |
| Primary Light | #99BBFF | ![#99BBFF](https://via.placeholder.com/15/99BBFF/000000?text=+) | Background, disabled states |

### 2.2. Màu phụ (Secondary Colors)

Màu phụ được sử dụng để nhấn mạnh và tạo sự tương phản với màu chính.

| Tên | Mã màu | Mẫu | Mục đích sử dụng |
|-----|--------|------|-----------------|
| Secondary | #FF6633 | ![#FF6633](https://via.placeholder.com/15/FF6633/000000?text=+) | Màu phụ, sử dụng cho các yếu tố nhấn mạnh |
| Secondary Dark | #CC3300 | ![#CC3300](https://via.placeholder.com/15/CC3300/000000?text=+) | Hover, active states |
| Secondary Light | #FF9966 | ![#FF9966](https://via.placeholder.com/15/FF9966/000000?text=+) | Background, disabled states |

### 2.3. Màu thứ ba (Tertiary Colors)

Màu thứ ba được sử dụng cho các yếu tố bổ sung và tạo sự đa dạng trong giao diện.

| Tên | Mã màu | Mẫu | Mục đích sử dụng |
|-----|--------|------|-----------------|
| Tertiary | #33CC99 | ![#33CC99](https://via.placeholder.com/15/33CC99/000000?text=+) | Màu thứ ba, sử dụng cho các yếu tố bổ sung |
| Tertiary Dark | #009966 | ![#009966](https://via.placeholder.com/15/009966/000000?text=+) | Hover, active states |
| Tertiary Light | #66FFCC | ![#66FFCC](https://via.placeholder.com/15/66FFCC/000000?text=+) | Background, disabled states |

### 2.4. Màu trung tính (Neutral Colors)

Màu trung tính được sử dụng cho nền, văn bản, viền và các yếu tố không nhấn mạnh.

| Tên | Mã màu | Mẫu | Mục đích sử dụng |
|-----|--------|------|-----------------|
| Background | #F8F9FA | ![#F8F9FA](https://via.placeholder.com/15/F8F9FA/000000?text=+) | Nền trang |
| Surface | #FFFFFF | ![#FFFFFF](https://via.placeholder.com/15/FFFFFF/000000?text=+) | Nền các thành phần |
| Border | #E1E4E8 | ![#E1E4E8](https://via.placeholder.com/15/E1E4E8/000000?text=+) | Viền |
| Divider | #F0F2F5 | ![#F0F2F5](https://via.placeholder.com/15/F0F2F5/000000?text=+) | Đường phân cách |

### 2.5. Màu trạng thái (State Colors)

Màu trạng thái được sử dụng để chỉ ra trạng thái của hệ thống hoặc thông báo.

| Tên | Mã màu | Mẫu | Mục đích sử dụng |
|-----|--------|------|-----------------|
| Success | #28A745 | ![#28A745](https://via.placeholder.com/15/28A745/000000?text=+) | Thành công |
| Warning | #FFC107 | ![#FFC107](https://via.placeholder.com/15/FFC107/000000?text=+) | Cảnh báo |
| Error | #DC3545 | ![#DC3545](https://via.placeholder.com/15/DC3545/000000?text=+) | Lỗi |
| Info | #17A2B8 | ![#17A2B8](https://via.placeholder.com/15/17A2B8/000000?text=+) | Thông tin |

### 2.6. Màu văn bản (Text Colors)

Màu văn bản được sử dụng cho các loại văn bản khác nhau trong giao diện.

| Tên | Mã màu | Mẫu | Mục đích sử dụng |
|-----|--------|------|-----------------|
| Text Primary | #212529 | ![#212529](https://via.placeholder.com/15/212529/000000?text=+) | Văn bản chính |
| Text Secondary | #6C757D | ![#6C757D](https://via.placeholder.com/15/6C757D/000000?text=+) | Văn bản phụ |
| Text Disabled | #ADB5BD | ![#ADB5BD](https://via.placeholder.com/15/ADB5BD/000000?text=+) | Văn bản bị vô hiệu hóa |
| Text On Primary | #FFFFFF | ![#FFFFFF](https://via.placeholder.com/15/FFFFFF/000000?text=+) | Văn bản trên nền màu chính |

### 2.7. Quy tắc sử dụng màu

- Sử dụng màu chính cho các yếu tố tương tác chính và nhấn mạnh
- Sử dụng màu phụ và màu thứ ba một cách có chọn lọc để tạo sự tương phản và nhấn mạnh
- Đảm bảo độ tương phản đủ cao giữa văn bản và nền (tối thiểu 4.5:1)
- Không chỉ dựa vào màu sắc để truyền đạt thông tin
- Duy trì tính nhất quán trong việc sử dụng màu sắc

## 3. TYPOGRAPHY

### 3.1. Font chữ

| Tên | Font | Mục đích sử dụng |
|-----|------|-----------------|
| Font chính | Roboto | Font sans-serif hiện đại, dễ đọc, sử dụng cho hầu hết nội dung |
| Font phụ | Montserrat | Font sans-serif cho tiêu đề, tạo sự tương phản với font chính |
| Font monospace | Roboto Mono | Font cho code, dữ liệu, số liệu |

### 3.2. Kích thước và line-height

| Tên | Kích thước | Line-height | Mục đích sử dụng |
|-----|------------|-------------|-----------------|
| Heading 1 | 32px | 40px | Tiêu đề trang |
| Heading 2 | 24px | 32px | Tiêu đề phần |
| Heading 3 | 20px | 28px | Tiêu đề thành phần |
| Heading 4 | 18px | 24px | Tiêu đề phụ |
| Body 1 | 16px | 24px | Văn bản chính |
| Body 2 | 14px | 20px | Văn bản phụ |
| Caption | 12px | 16px | Chú thích |
| Button | 14px | 20px | Nút |

### 3.3. Font weight

| Tên | Weight | Mục đích sử dụng |
|-----|--------|-----------------|
| Regular | 400 | Văn bản thông thường |
| Medium | 500 | Nhấn mạnh nhẹ |
| Bold | 700 | Tiêu đề, nhấn mạnh |

### 3.4. Quy tắc sử dụng typography

- Sử dụng font chính (Roboto) cho hầu hết nội dung
- Sử dụng font phụ (Montserrat) cho tiêu đề để tạo sự tương phản
- Duy trì phân cấp typography rõ ràng
- Đảm bảo khả năng đọc trên mọi thiết bị và kích thước màn hình
- Giới hạn số lượng kích thước và font weight để duy trì tính nhất quán

## 4. ICONOGRAPHY

### 4.1. Hệ thống icon

NextFlow CRM-AI sử dụng Material Design Icons làm hệ thống icon chính. Các icon được thiết kế để đơn giản, rõ ràng và nhất quán.

### 4.2. Kích thước icon

| Tên | Kích thước | Mục đích sử dụng |
|-----|------------|-----------------|
| Small | 16px x 16px | Icon nhỏ, sử dụng trong văn bản, bảng |
| Standard | 24px x 24px | Kích thước tiêu chuẩn, sử dụng trong hầu hết trường hợp |
| Medium | 32px x 32px | Icon lớn hơn, sử dụng cho các yếu tố nhấn mạnh |
| Large | 48px x 48px | Icon lớn, sử dụng cho các yếu tố nổi bật |

### 4.3. Đặc điểm icon

- **Stroke**: 2px
- **Corner radius**: 2px
- **Style**: Filled hoặc outlined tùy theo ngữ cảnh

### 4.4. Quy tắc sử dụng icon

- Sử dụng icon để tăng cường hiểu biết và nhận diện
- Đảm bảo icon có ý nghĩa rõ ràng và dễ hiểu
- Kết hợp icon với văn bản khi cần thiết
- Duy trì tính nhất quán trong việc sử dụng icon
- Đảm bảo icon có đủ không gian để dễ nhận diện

## 5. SPACING

### 5.1. Hệ thống spacing

NextFlow CRM-AI sử dụng hệ thống spacing dựa trên đơn vị cơ bản 4px. Điều này đảm bảo tính nhất quán và hài hòa trong layout.

| Tên | Kích thước | Mục đích sử dụng |
|-----|------------|-----------------|
| XXS | 4px | Khoảng cách nhỏ nhất, sử dụng cho các yếu tố liên quan chặt chẽ |
| XS | 8px | Khoảng cách giữa các yếu tố liên quan |
| S | 16px | Khoảng cách giữa các nhóm yếu tố |
| M | 24px | Khoảng cách giữa các phần |
| L | 32px | Khoảng cách giữa các khối lớn |
| XL | 48px | Khoảng cách giữa các phần chính |
| XXL | 64px | Khoảng cách lớn nhất, sử dụng cho các phần riêng biệt |

### 5.2. Padding

| Tên | Kích thước | Mục đích sử dụng |
|-----|------------|-----------------|
| Button | 8px 16px | Padding cho nút |
| Card | 16px | Padding cho card |
| Input | 8px 12px | Padding cho input |
| Container | 24px | Padding cho container |

### 5.3. Margin

| Tên | Kích thước | Mục đích sử dụng |
|-----|------------|-----------------|
| Form Group | 16px | Margin giữa các form group |
| Section | 32px | Margin giữa các section |
| Page | 48px | Margin cho page |

### 5.4. Quy tắc sử dụng spacing

- Sử dụng hệ thống spacing nhất quán trong toàn bộ giao diện
- Đảm bảo đủ không gian trắng để tạo sự cân bằng và dễ đọc
- Điều chỉnh spacing theo kích thước màn hình và thiết bị
- Duy trì tỷ lệ spacing hợp lý giữa các yếu tố

## 6. ELEVATION

### 6.1. Hệ thống elevation

NextFlow CRM-AI sử dụng hệ thống elevation để tạo cảm giác độ sâu và phân cấp trong giao diện. Elevation được thể hiện thông qua box-shadow.

| Tên | Box-shadow | Mục đích sử dụng |
|-----|------------|-----------------|
| Level 0 | none | Các yếu tố phẳng, không có shadow |
| Level 1 | 0 2px 4px rgba(0,0,0,0.1) | Card, dropdown |
| Level 2 | 0 4px 8px rgba(0,0,0,0.1) | Dialog, popover |
| Level 3 | 0 8px 16px rgba(0,0,0,0.1) | Modal |
| Level 4 | 0 16px 24px rgba(0,0,0,0.1) | Notification |

### 6.2. Quy tắc sử dụng elevation

- Sử dụng elevation để tạo phân cấp thị giác
- Đảm bảo elevation phù hợp với ngữ cảnh và mục đích sử dụng
- Không sử dụng quá nhiều cấp độ elevation trong cùng một màn hình
- Điều chỉnh elevation theo trạng thái (hover, active, focus)

## 7. BORDER RADIUS

### 7.1. Hệ thống border radius

NextFlow CRM-AI sử dụng hệ thống border radius nhất quán để tạo sự mềm mại và hiện đại cho giao diện.

| Tên | Kích thước | Mục đích sử dụng |
|-----|------------|-----------------|
| None | 0 | Không có border radius |
| Small | 4px | Border radius nhỏ, sử dụng cho các yếu tố nhỏ |
| Medium | 8px | Border radius trung bình, sử dụng cho hầu hết các thành phần |
| Large | 16px | Border radius lớn, sử dụng cho các thành phần lớn |
| Pill | 9999px | Border radius tròn, sử dụng cho badge, tag |

### 7.2. Quy tắc sử dụng border radius

- Sử dụng border radius nhất quán trong toàn bộ giao diện
- Đảm bảo border radius phù hợp với kích thước và mục đích của thành phần
- Duy trì tính nhất quán trong việc sử dụng border radius

## 8. GRID SYSTEM

### 8.1. Cấu trúc grid

NextFlow CRM-AI sử dụng grid system 12 cột để tạo layout linh hoạt và responsive.

| Tên | Mô tả |
|-----|-------|
| Columns | 12 columns |
| Gutters | 24px |
| Margins | 16px (mobile), 24px (tablet), 32px (desktop) |

### 8.2. Breakpoints

| Tên | Kích thước | Mô tả |
|-----|------------|-------|
| Extra small (xs) | < 576px | Mobile portrait |
| Small (sm) | 576px - 767px | Mobile landscape |
| Medium (md) | 768px - 991px | Tablet portrait |
| Large (lg) | 992px - 1199px | Tablet landscape, small desktop |
| Extra large (xl) | >= 1200px | Desktop |

### 8.3. Quy tắc sử dụng grid

- Sử dụng grid system để tạo layout nhất quán và responsive
- Điều chỉnh số lượng cột theo kích thước màn hình
- Đảm bảo các thành phần có đủ không gian và không bị chồng chéo
- Sử dụng các mẫu responsive design phù hợp

## 9. DARK MODE

### 9.1. Bảng màu dark mode

| Tên | Mã màu | Mẫu | Mục đích sử dụng |
|-----|--------|------|-----------------|
| Background | #121212 | ![#121212](https://via.placeholder.com/15/121212/000000?text=+) | Nền trang |
| Surface | #1E1E1E | ![#1E1E1E](https://via.placeholder.com/15/1E1E1E/000000?text=+) | Nền các thành phần |
| Border | #333333 | ![#333333](https://via.placeholder.com/15/333333/000000?text=+) | Viền |
| Divider | #2A2A2A | ![#2A2A2A](https://via.placeholder.com/15/2A2A2A/000000?text=+) | Đường phân cách |
| Text Primary | #FFFFFF | ![#FFFFFF](https://via.placeholder.com/15/FFFFFF/000000?text=+) | Văn bản chính |
| Text Secondary | #AAAAAA | ![#AAAAAA](https://via.placeholder.com/15/AAAAAA/000000?text=+) | Văn bản phụ |
| Text Disabled | #666666 | ![#666666](https://via.placeholder.com/15/666666/000000?text=+) | Văn bản bị vô hiệu hóa |

### 9.2. Quy tắc sử dụng dark mode

- Đảm bảo độ tương phản đủ cao trong dark mode
- Điều chỉnh elevation và shadow để phù hợp với dark mode
- Duy trì tính nhất quán giữa light mode và dark mode
- Cho phép người dùng chuyển đổi giữa light mode và dark mode

## 10. TỔNG KẾT

Hệ thống thiết kế của NextFlow CRM-AI là nền tảng cho việc tạo ra giao diện người dùng nhất quán, hiệu quả và thẩm mỹ. Bằng cách tuân thủ các quy tắc và hướng dẫn trong hệ thống thiết kế, chúng ta đảm bảo rằng NextFlow CRM-AI có trải nghiệm người dùng xuất sắc và nhất quán trên tất cả các tính năng và thiết bị.

Hệ thống thiết kế này sẽ tiếp tục phát triển dựa trên phản hồi của người dùng, xu hướng thiết kế mới và sự phát triển của công nghệ. Mục tiêu cuối cùng là tạo ra một sản phẩm không chỉ đẹp mắt mà còn dễ sử dụng, hiệu quả và mang lại giá trị thực sự cho người dùng.

## 11. TÀI LIỆU THAM KHẢO

### 11.1. Design Systems
- [Material Design System](https://material.io/design/introduction)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Ant Design](https://ant.design/docs/spec/introduce)
- [Carbon Design System](https://carbondesignsystem.com/)

### 11.2. Color Theory
- [Adobe Color Theory](https://www.adobe.com/creativecloud/design/discover/color-theory.html)
- [Color Accessibility Guidelines](https://webaim.org/articles/contrast/)
- [WCAG Color Contrast](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)

### 11.3. Typography
- [Google Fonts](https://fonts.google.com/)
- [Typography Guidelines](https://material.io/design/typography/the-type-system.html)
- [Web Typography Best Practices](https://www.smashingmagazine.com/2019/07/web-typography-guide/)

### 11.4. NextFlow CRM-AI Documentation
- [Tổng quan Thiết kế](./tong-quan-thiet-ke.md)
- [Nguyên tắc Thiết kế](./nguyen-tac-thiet-ke.md)
- [Thành phần UI](./thanh-phan/thanh-phan-ui-co-ban.md)
- [Responsive Design](./responsive-design.md)

---

**Cập nhật lần cuối**: 2024-01-15
**Phiên bản**: 1.0.0
**Tác giả**: NextFlow Design Team
