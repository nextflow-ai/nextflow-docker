# Hướng dẫn cài đặt shadcn/ui trên Next.js

## Giới thiệu về shadcn/ui

**shadcn/ui** là một bộ sưu tập các React component: thành phần React có thể tái sử dụng, được thiết kế đẹp mắt, dễ tiếp cận và có thể tùy chỉnh hoàn toàn. Khác với các UI library: thư viện giao diện truyền thống, shadcn/ui cho phép bạn copy và paste: sao chép và dán các component vào project: dự án của mình.

### Đặc điểm chính:
- **Foundation: Nền tảng**: Sử dụng Tailwind CSS và Radix UI
- **Framework support: Hỗ trợ framework**: Next.js, Gatsby, Remix, Astro, Laravel, Vite
- **Lightweight: Nhẹ**: Chỉ thêm component khi cần thiết
- **Customizable: Tùy chỉnh được**: Có thể chỉnh sửa source code: mã nguồn hoàn toàn

## Bước 1: Cài đặt Next.js

### Tạo project mới

**Với npm:**
```bash
npx create-next-app@latest ten-du-an --typescript --tailwind --eslint
```

**Với yarn:**
```bash
yarn create next-app@latest ten-du-an --typescript --tailwind --eslint
```

**Với pnpm:**
```bash
pnpm create next-app@latest ten-du-an --typescript --tailwind --eslint
```

**Với bun:**
```bash
bunx --bun create-next-app@latest ten-du-an --typescript --tailwind --eslint
```

### Cấu hình Next.js

Khi chạy lệnh trên, CLI: giao diện dòng lệnh sẽ hỏi các câu hỏi cấu hình:

```
✔ Would you like to use `src/` directory? … No / Yes
✔ Would you like to use App Router? (recommended) … No / Yes  
✔ Would you like to customize the default import alias (@/*)? … No / Yes
```

**Khuyến nghị cấu hình:**
- `src/` directory: **No** (giữ cấu trúc đơn giản)
- App Router: **Yes** (được khuyến nghị cho Next.js 14+)
- Import alias: **No** (sử dụng @ mặc định)

### Di chuyển vào thư mục project
```bash
cd ten-du-an
```

## Bước 2: Khởi tạo shadcn/ui

### Chạy lệnh init

**Với npm:**
```bash
npx shadcn-ui@latest init
```

**Với yarn:**
```bash
npx shadcn-ui@latest init
```

**Với pnpm:**
```bash
pnpm dlx shadcn-ui@latest init
```

**Với bun:**
```bash
bunx --bun shadcn-ui@latest init
```

### Cấu hình shadcn/ui

CLI sẽ hỏi các câu hỏi setup: thiết lập:

```
✔ Which style would you like to use? › New York
✔ Which color would you like to use as base color? › Slate  
✔ Would you like to use CSS variables for colors? › yes
```

**Giải thích các tùy chọn:**

1. **Style options: Tùy chọn phong cách**
   - `Default`: Phong cách cơ bản
   - `New York`: Phong cách hiện đại hơn (khuyến nghị)

2. **Base color: Màu cơ sở**

   Đây là **bảng màu trung tính** chính được sử dụng cho toàn bộ giao diện, quyết định màu sắc của nền, chữ viết, viền và các thành phần khác. Việc chọn một `Base color` sẽ tạo ra một cảm giác và tông màu nhất quán cho ứng dụng.

   - **Slate (Khuyến nghị):** Màu xám có tông lạnh, pha chút sắc xanh dương. Tạo cảm giác hiện đại, chuyên nghiệp.
   - **Gray:** Màu xám trung tính, không pha trộn. Tạo cảm giác cân bằng, cổ điển.
   - **Zinc:** Màu xám có tông hơi ấm, pha chút sắc xanh lá hoặc nâu. Tạo cảm giác công nghiệp, mạnh mẽ.
   - **Neutral:** Rất giống `Gray`, là một màu xám tinh khiết. Tạo cảm giác sạch sẽ, đơn giản.
   - **Stone:** Màu xám có tông ấm rõ rệt, pha sắc nâu hoặc be. Tạo cảm giác tự nhiên, ấm cúng.

3. **CSS variables: Biến CSS**
   - `Yes`: Sử dụng CSS variables để dễ customize: tùy chỉnh màu sắc
   - `No`: Sử dụng Tailwind classes trực tiếp

## Bước 3: Cấu trúc project sau cài đặt

Sau khi init: khởi tạo thành công, cấu trúc project sẽ như sau:

```
ten-du-an/
├── components/
│   └── ui/              # Thư mục chứa shadcn components (ban đầu trống)
├── lib/
│   └── utils.ts         # Utility functions: hàm tiện ích
├── app/
│   ├── globals.css      # Global styles: kiểu dáng toàn cục (đã cập nhật)
│   └── page.tsx
├── components.json      # Config file: file cấu hình shadcn
└── tailwind.config.ts   # Tailwind config (đã cập nhật)
```

**Lưu ý quan trọng:** Thư mục `components/ui` ban đầu sẽ trống. shadcn/ui không tự động install: cài đặt tất cả component để giữ project lightweight: nhẹ.

## Bước 4: Thêm component đầu tiên

### Cài đặt Button component

```bash
npx shadcn-ui@latest add button
```

Lệnh này sẽ:
- Download: tải xuống source code của Button component
- Đặt file vào `components/ui/button.tsx`
- Install: cài đặt các dependencies: phụ thuộc cần thiết

### Sử dụng Button component

Cập nhật file `app/page.tsx`:

```tsx
import { Button } from "@/components/ui/button";

export default function TrangChu() {
  return (
    <div className="flex justify-center items-center min-h-screen">
      <Button variant="outline">Nhấn vào đây!</Button>
    </div>
  );
}
```

## Bước 5: Các variant và size của Button

### Button variants có sẵn

```tsx
import { Button } from "@/components/ui/button";

export default function TrangDemo() {
  return (
    <div className="flex justify-center items-center flex-col gap-4 min-h-screen">
      <Button variant="default">Mặc định</Button>
      <Button variant="destructive">Phá hủy</Button>
      <Button variant="outline">Viền</Button>
      <Button variant="secondary">Phụ</Button>
      <Button variant="ghost">Trong suốt</Button>
      <Button variant="link">Liên kết</Button>
    </div>
  );
}
```

### Button sizes: kích thước

```tsx
<Button size="sm">Nhỏ</Button>
<Button size="default">Mặc định</Button>
<Button size="lg">Lớn</Button>
<Button size="icon">Icon</Button>
```

## Bước 6: Tùy chỉnh component

### Chỉnh sửa Button component

File `components/ui/button.tsx` chứa source code hoàn chỉnh. Bạn có thể:

1. **Thêm variant mới:**
```tsx
// Trong file components/ui/button.tsx
const buttonVariants = cva(
  // Base classes: lớp cơ sở...
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground shadow hover:bg-primary/90",
        // ... các variant khác
        tuyChinh: "bg-blue-500 text-white hover:bg-blue-600", // Variant mới
      },
      // ...
    },
  }
);
```

2. **Sử dụng variant tùy chỉnh:**
```tsx
<Button variant="tuyChinh">Button tùy chỉnh</Button>
```

## Bước 7: Thêm các component khác

### Danh sách component phổ biến

```bash
# Alert Dialog: hộp thoại cảnh báo
npx shadcn-ui@latest add alert-dialog

# Card: thẻ
npx shadcn-ui@latest add card

# Input: ô nhập liệu
npx shadcn-ui@latest add input

# Form: biểu mẫu
npx shadcn-ui@latest add form

# Table: bảng
npx shadcn-ui@latest add table
```

### Ví dụ sử dụng Card

```tsx
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export default function TrangCard() {
  return (
    <Card className="w-96">
      <CardHeader>
        <CardTitle>Tiêu đề thẻ</CardTitle>
        <CardDescription>Mô tả ngắn gọn về nội dung thẻ</CardDescription>
      </CardHeader>
      <CardContent>
        <p>Nội dung chính của thẻ được hiển thị ở đây.</p>
      </CardContent>
    </Card>
  );
}
```

## Troubleshooting: Xử lý sự cố

### Lỗi thường gặp

1. **Command not found: Không tìm thấy lệnh**
   - Đảm bảo đã install Node.js và npm/yarn/pnpm
   - Kiểm tra network connection: kết nối mạng

2. **TypeScript errors: Lỗi TypeScript**
   - Chạy `npm run build` để kiểm tra lỗi
   - Đảm bảo đã import đúng path: đường dẫn

3. **Styling issues: Vấn đề về styling**
   - Kiểm tra Tailwind CSS đã được cấu hình đúng
   - Xem file `globals.css` có chứa shadcn styles

### Tips: Mẹo hữu ích

- Luôn check: kiểm tra documentation chính thức tại ui.shadcn.com
- Sử dụng TypeScript để có better: tốt hơn type safety: an toàn kiểu dữ liệu
- Customize: tùy chỉnh component theo design system: hệ thống thiết kế của project

## Kết luận

shadcn/ui cung cấp một cách tiếp cận linh hoạt để xây dựng UI components cho Next.js. Với khả năng customize hoàn toàn và performance: hiệu năng tốt, đây là lựa chọn tuyệt vời cho các modern web applications: ứng dụng web hiện đại.