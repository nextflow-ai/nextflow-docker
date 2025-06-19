# THÀNH PHẦN UI CƠ BẢN NextFlow CRM

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Buttons](#2-buttons)
3. [Form Elements](#3-form-elements)
4. [Cards](#4-cards)
5. [Tables](#5-tables)
6. [Navigation](#6-navigation)
7. [Feedback](#7-feedback)
8. [Layout](#8-layout)
9. [Typography](#9-typography)
10. [Icons](#10-icons)
11. [Kết luận](#11-kết-luận)
12. [Tài liệu tham khảo](#12-tài-liệu-tham-khảo)

## 1. GIỚI THIỆU

Thành phần UI cơ bản là các yếu tố giao diện người dùng được sử dụng thường xuyên trong NextFlow CRM. Các thành phần này được thiết kế để nhất quán, dễ sử dụng và linh hoạt, đồng thời tuân thủ hệ thống thiết kế của NextFlow CRM.

### 1.1. Nguyên tắc thiết kế thành phần

**Tính nhất quán:**
- Tất cả thành phần tuân theo design system
- Màu sắc, typography và spacing nhất quán
- Behavior patterns đồng nhất

**Khả năng tiếp cận:**
- Tuân thủ WCAG 2.1 Level AA
- Keyboard navigation support
- Screen reader compatibility
- High contrast support

**Tính linh hoạt:**
- Responsive design cho mọi breakpoint
- Customizable properties
- Reusable components
- Scalable architecture

### 1.2. Atomic Design Methodology

**Atoms (Nguyên tử):**
- Buttons, inputs, labels, icons
- Typography elements
- Color tokens, spacing units

**Molecules (Phân tử):**
- Form groups, search bars
- Navigation items
- Card components

**Organisms (Sinh vật):**
- Headers, footers, sidebars
- Data tables, forms
- Complex layouts

## 2. BUTTONS

Buttons là thành phần tương tác cơ bản, cho phép người dùng thực hiện các hành động trong hệ thống.

### 2.1. Phân loại Buttons

#### 2.1.1. Primary Button

**Mục đích và Sử dụng:**
- Hành động chính hoặc quan trọng nhất trên màn hình
- Call-to-action chính trong forms
- Submit actions, save operations
- Chỉ nên có một primary button trên mỗi màn hình

**Đặc điểm Thiết kế:**
- Màu nền: Primary color (#3366FF)
- Văn bản: White (#FFFFFF)
- Border radius: 8px
- Font weight: Medium (500)
- Elevation: Level 1 shadow

**Trạng thái:**
- **Default**: Primary background, white text
- **Hover**: Darker primary background (10% darker)
- **Active**: Even darker background (15% darker)
- **Focus**: Primary background với focus ring
- **Disabled**: Gray background, reduced opacity

#### 2.1.2. Secondary Button

**Mục đích và Sử dụng:**
- Hành động thứ yếu hoặc bổ sung
- Cancel actions, back navigation
- Alternative actions trong forms
- Có thể có nhiều secondary buttons

**Đặc điểm Thiết kế:**
- Màu nền: Transparent
- Văn bản: Primary color (#3366FF)
- Border: 1px solid primary color
- Border radius: 8px
- Font weight: Medium (500)

#### 2.1.3. Tertiary Button

**Mục đích và Sử dụng:**
- Hành động ít quan trọng
- Text links, subtle actions
- Navigation links
- Actions trong space-constrained areas

**Đặc điểm Thiết kế:**
- Màu nền: Transparent
- Văn bản: Primary color (#3366FF)
- Không có border
- Font weight: Medium (500)
- Underline on hover (optional)

#### 2.1.4. Danger Button

**Mục đích và Sử dụng:**
- Hành động nguy hiểm hoặc destructive
- Delete operations
- Permanent actions
- Warning confirmations

**Đặc điểm Thiết kế:**
- Màu nền: Error color (#FF3366)
- Văn bản: White (#FFFFFF)
- Border radius: 8px
- Font weight: Medium (500)
- Elevation: Level 1 shadow

### 2.2. Kích thước Buttons

#### 2.2.1. Small (32px height)

**Sử dụng:**
- Compact interfaces
- Table actions
- Secondary actions
- Mobile interfaces

**Specifications:**
- Height: 32px
- Padding: 4px 12px
- Font size: 12px
- Icon size: 16px

#### 2.2.2. Medium (40px height)

**Sử dụng:**
- Default size cho most cases
- Form submissions
- Standard actions
- Desktop interfaces

**Specifications:**
- Height: 40px
- Padding: 8px 16px
- Font size: 14px
- Icon size: 20px

#### 2.2.3. Large (48px height)

**Sử dụng:**
- Important actions
- Landing pages
- Mobile touch targets
- Prominent CTAs

**Specifications:**
- Height: 48px
- Padding: 12px 24px
- Font size: 16px
- Icon size: 24px

### 2.3. Button States và Interactions

#### 2.3.1. Interactive States

**Default State:**
- Normal appearance của button
- Ready for user interaction
- Clear visual hierarchy

**Hover State:**
- Triggered by mouse hover
- Subtle color change (10% darker/lighter)
- Smooth transition (200ms ease)
- Indicates interactivity

**Active State:**
- Triggered by mouse press
- More pronounced color change (15% darker)
- Immediate feedback
- Brief duration

**Focus State:**
- Triggered by keyboard navigation
- Focus ring around button
- High contrast outline
- Maintains accessibility

**Disabled State:**
- Non-interactive state
- Reduced opacity (50%)
- Gray color scheme
- Cursor: not-allowed

#### 2.3.2. Loading State

**Purpose:**
- Indicates processing action
- Prevents multiple submissions
- Provides user feedback

**Design:**
- Spinner icon inside button
- Disabled interaction
- "Đang xử lý..." text (optional)
- Maintains button dimensions

### 2.4. Button Combinations

#### 2.4.1. Button với Icon

**Icon Placement:**
- **Leading icon**: Icon trước text (8px spacing)
- **Trailing icon**: Icon sau text (8px spacing)
- **Icon only**: Chỉ icon, requires tooltip

**Best Practices:**
- Icon phải meaningful và recognizable
- Consistent icon style throughout app
- Appropriate icon size cho button size
- Tooltip cho icon-only buttons

#### 2.4.2. Button Groups

**Purpose:**
- Related actions grouping
- Toggle functionality
- Segmented controls
- Filter options

**Design:**
- Connected buttons
- Shared borders
- Consistent styling
- Clear active state

### 2.5. Accessibility Considerations

#### 2.5.1. Keyboard Navigation

**Requirements:**
- Tab order logical
- Enter/Space activation
- Focus indicators visible
- Skip links available

#### 2.5.2. Screen Reader Support

**Requirements:**
- Descriptive button text
- ARIA labels cho icon buttons
- State announcements
- Role definitions

#### 2.5.3. Touch Targets

**Requirements:**
- Minimum 44px touch area
- Adequate spacing between buttons
- Easy thumb reach on mobile
- Gesture support

## 3. FORM ELEMENTS

Form elements cho phép người dùng nhập và chỉnh sửa dữ liệu trong hệ thống.

### 3.1. Text Inputs

#### 3.1.1. Standard Text Input

**Mục đích và Sử dụng:**
- Nhập văn bản một dòng
- User information, search queries
- Form data entry
- Single-line content

**Đặc điểm Thiết kế:**
- Height: 40px (default)
- Border: 1px solid neutral color
- Border radius: 8px
- Padding: 8px 12px
- Font size: 14px

**Trạng thái:**
- **Default**: Neutral border, placeholder text
- **Focus**: Primary border, no placeholder
- **Filled**: User content, normal border
- **Error**: Red border, error message
- **Disabled**: Gray background, reduced opacity

#### 3.1.2. Textarea

**Mục đích và Sử dụng:**
- Nhập văn bản nhiều dòng
- Comments, descriptions
- Long-form content
- Multi-line input

**Đặc điểm Thiết kế:**
- Minimum height: 80px
- Resizable vertically
- Same styling như text input
- Line height: 1.5

#### 3.1.3. Search Input

**Mục đích và Sử dụng:**
- Tìm kiếm nội dung
- Filter data
- Quick search functionality
- Global search

**Đặc điểm Thiết kế:**
- Search icon (leading)
- Clear button (trailing)
- Rounded corners
- Placeholder text descriptive

### 3.2. Selection Controls

#### 3.2.1. Dropdown/Select

**Mục đích và Sử dụng:**
- Chọn một option từ list
- Category selection
- Status selection
- Configuration options

**Đặc điểm Thiết kế:**
- Dropdown arrow icon
- Same height như text input
- Scrollable options list
- Search functionality (optional)

#### 3.2.2. Checkbox

**Mục đích và Sử dụng:**
- Multiple selections
- Boolean options
- Bulk actions
- Settings toggles

**Đặc điểm Thiết kế:**
- Size: 16px, 20px, 24px
- Custom design với checkmark
- Smooth animation
- Clear labels

#### 3.2.3. Radio Buttons

**Mục đích và Sử dụng:**
- Single selection từ group
- Mutually exclusive options
- Settings choices
- Form selections

**Đặc điểm Thiết kế:**
- Circular design
- Filled center when selected
- Grouped logically
- Clear option labels

#### 3.2.4. Toggle Switch

**Mục đích và Sử dụng:**
- On/off states
- Feature toggles
- Settings activation
- Binary choices

**Đặc điểm Thiết kế:**
- Pill-shaped background
- Sliding indicator
- Color change on state
- Smooth animation

### 3.3. Form Validation

#### 3.3.1. Error States

**Visual Indicators:**
- Red border color
- Error icon
- Error message text
- Shake animation (optional)

**Message Guidelines:**
- Clear và specific
- Actionable instructions
- Friendly tone
- Immediate feedback

#### 3.3.2. Success States

**Visual Indicators:**
- Green border color
- Success icon
- Confirmation message
- Positive feedback

#### 3.3.3. Warning States

**Visual Indicators:**
- Yellow/orange border
- Warning icon
- Cautionary message
- Preventive guidance

### 3.4. Form Layout

#### 3.4.1. Form Groups

**Structure:**
- Label (required/optional indicator)
- Input field
- Helper text
- Error/success message

**Spacing:**
- 16px between form groups
- 8px between label và input
- 4px between input và helper text

#### 3.4.2. Form Sections

**Organization:**
- Related fields grouped
- Section headers
- Progressive disclosure
- Logical flow

## 4. CARDS

Cards là containers chứa nội dung và actions liên quan đến một chủ đề cụ thể.

### 4.1. Card Types

#### 4.1.1. Standard Card

**Mục đích và Sử dụng:**
- Display related information
- Content grouping
- Action containers
- Information hierarchy

**Đặc điểm Thiết kế:**
- Background: White
- Border: 1px solid light gray
- Border radius: 8px
- Padding: 24px
- Shadow: Subtle elevation

**Structure:**
- Header (optional)
- Body content
- Footer actions (optional)

#### 4.1.2. Interactive Card

**Mục đích và Sử dụng:**
- Clickable content
- Navigation cards
- Selection items
- Hover interactions

**Đặc điểm Thiết kế:**
- Hover effects
- Cursor pointer
- Subtle animations
- Clear interactive states

#### 4.1.3. Media Card

**Mục đích và Sử dụng:**
- Image/video content
- Product displays
- Gallery items
- Rich media

**Đặc điểm Thiết kế:**
- Media area
- Content overlay
- Aspect ratio maintained
- Responsive images

### 4.2. Card Layouts

#### 4.2.1. Vertical Layout

**Structure:**
- Media on top
- Content below
- Actions at bottom
- Consistent heights

#### 4.2.2. Horizontal Layout

**Structure:**
- Media on left/right
- Content adjacent
- Flexible widths
- Responsive behavior

#### 4.2.3. Grid Layout

**Organization:**
- Equal card sizes
- Consistent spacing
- Responsive columns
- Proper alignment

### 4.3. Card States

#### 4.3.1. Default State

**Appearance:**
- Normal styling
- Clear content hierarchy
- Readable text
- Proper spacing

#### 4.3.2. Hover State

**Appearance:**
- Subtle elevation increase
- Color changes
- Smooth transitions
- Interactive feedback

#### 4.3.3. Selected State

**Appearance:**
- Primary border/background
- Selection indicators
- Clear selection state
- Accessible feedback

## 5. TABLES

Tables hiển thị dữ liệu có cấu trúc, cho phép users xem, so sánh và thao tác với data.

### 5.1. Table Types

#### 5.1.1. Data Table

**Mục đích và Sử dụng:**
- Display structured data
- Compare information
- Bulk operations
- Data analysis

**Đặc điểm Thiết kế:**
- Clear column headers
- Alternating row colors
- Sortable columns
- Responsive behavior

#### 5.1.2. Simple Table

**Mục đích và Sử dụng:**
- Basic information display
- Simple data presentation
- Read-only content
- Minimal interactions

**Đặc điểm Thiết kế:**
- Clean borders
- Consistent spacing
- Clear typography
- Minimal styling

### 5.2. Table Features

#### 5.2.1. Sorting

**Functionality:**
- Column header clicking
- Sort indicators
- Multiple column sorting
- Default sort orders

**Visual Design:**
- Arrow indicators
- Active column highlighting
- Clear sort direction
- Hover states

#### 5.2.2. Filtering

**Functionality:**
- Column-specific filters
- Global search
- Filter combinations
- Clear filter options

**Visual Design:**
- Filter controls
- Active filter indicators
- Filter summaries
- Reset options

#### 5.2.3. Pagination

**Functionality:**
- Page navigation
- Items per page
- Total count display
- Jump to page

**Visual Design:**
- Page numbers
- Previous/next buttons
- Current page indicator
- Responsive behavior

### 5.3. Table Interactions

#### 5.3.1. Row Selection

**Functionality:**
- Single row selection
- Multiple row selection
- Select all option
- Bulk actions

**Visual Design:**
- Checkboxes
- Selected row highlighting
- Selection count
- Action buttons

#### 5.3.2. Row Actions

**Functionality:**
- Edit, delete, view actions
- Context menus
- Inline editing
- Quick actions

**Visual Design:**
- Action buttons
- Icon buttons
- Dropdown menus
- Hover reveals

## 6. NAVIGATION

Navigation components giúp users di chuyển trong application.

### 6.1. Primary Navigation

#### 6.1.1. Top Navigation

**Mục đích và Sử dụng:**
- Main app navigation
- Global actions
- User account access
- Brand identity

**Đặc điểm Thiết kế:**
- Fixed position
- Brand logo
- Navigation links
- User menu

#### 6.1.2. Sidebar Navigation

**Mục đích và Sử dụng:**
- Section navigation
- Hierarchical menus
- Collapsible design
- Context-specific

**Đặc điểm Thiết kế:**
- Vertical layout
- Expandable sections
- Active state indicators
- Responsive collapse

### 6.2. Secondary Navigation

#### 6.2.1. Breadcrumbs

**Mục đích và Sử dụng:**
- Location awareness
- Navigation history
- Quick backtracking
- Hierarchy display

**Đặc điểm Thiết kế:**
- Horizontal layout
- Separator icons
- Clickable links
- Current page indicator

#### 6.2.2. Tabs

**Mục đích và Sử dụng:**
- Content sections
- View switching
- Related content
- Horizontal navigation

**Đặc điểm Thiết kế:**
- Horizontal tabs
- Active tab indicator
- Consistent spacing
- Responsive behavior

### 6.3. Navigation States

#### 6.3.1. Active State

**Visual Indicators:**
- Different background color
- Border indicators
- Font weight changes
- Icon variations

#### 6.3.2. Hover State

**Visual Indicators:**
- Background color change
- Smooth transitions
- Interactive feedback
- Cursor changes

## 7. FEEDBACK

Feedback components cung cấp thông tin về system state và user actions.

### 7.1. Alerts và Messages

#### 7.1.1. Success Messages

**Mục đích và Sử dụng:**
- Confirm successful actions
- Positive feedback
- Completion notifications
- Achievement indicators

**Đặc điểm Thiết kế:**
- Green color scheme
- Success icon
- Clear message text
- Auto-dismiss option

#### 7.1.2. Error Messages

**Mục đích và Sử dụng:**
- Indicate problems
- Validation errors
- System failures
- User guidance

**Đặc điểm Thiết kế:**
- Red color scheme
- Error icon
- Specific error text
- Action suggestions

#### 7.1.3. Warning Messages

**Mục đích và Sử dụng:**
- Cautionary information
- Potential issues
- Important notices
- Preventive guidance

**Đặc điểm Thiết kế:**
- Yellow/orange color scheme
- Warning icon
- Clear warning text
- Dismissible option

#### 7.1.4. Info Messages

**Mục đích và Sử dụng:**
- General information
- Tips và hints
- System updates
- Neutral notifications

**Đặc điểm Thiết kế:**
- Blue color scheme
- Info icon
- Informative text
- Optional actions

### 7.2. Loading States

#### 7.2.1. Spinners

**Mục đích và Sử dụng:**
- Quick loading actions
- Button loading states
- Small content areas
- Inline loading

**Đặc điểm Thiết kế:**
- Circular animation
- Brand colors
- Appropriate sizing
- Smooth rotation

#### 7.2.2. Progress Bars

**Mục đích và Sử dụng:**
- File uploads
- Multi-step processes
- Determinate progress
- Long operations

**Đặc điểm Thiết kế:**
- Horizontal bar
- Progress indication
- Percentage display
- Color progression

#### 7.2.3. Skeleton Screens

**Mục đích và Sử dụng:**
- Content loading
- Page initialization
- Perceived performance
- Layout preservation

**Đặc điểm Thiết kế:**
- Content shape mimicking
- Subtle animation
- Gray placeholder
- Smooth transitions

### 7.3. Tooltips và Popovers

#### 7.3.1. Tooltips

**Mục đích và Sử dụng:**
- Additional information
- Icon explanations
- Help text
- Context clues

**Đặc điểm Thiết kế:**
- Small text container
- Pointer arrow
- Dark background
- Hover trigger

#### 7.3.2. Popovers

**Mục đích và Sử dụng:**
- Detailed information
- Action menus
- Form helpers
- Rich content

**Đặc điểm Thiết kế:**
- Larger container
- White background
- Border và shadow
- Click trigger

## 8. LAYOUT

Layout components cung cấp structure cho application interface.

### 8.1. Grid System

#### 8.1.1. 12-Column Grid

**Specifications:**
- 12 equal columns
- Flexible gutters
- Responsive breakpoints
- Container max-widths

**Usage:**
- Content organization
- Responsive layouts
- Consistent spacing
- Alignment system

#### 8.1.2. Flexbox Utilities

**Capabilities:**
- Flexible layouts
- Alignment control
- Space distribution
- Responsive behavior

### 8.2. Spacing System

#### 8.2.1. Spacing Scale

**Scale Values:**
- 4px, 8px, 16px, 24px, 32px, 48px, 64px
- Consistent increments
- Predictable spacing
- Scalable system

#### 8.2.2. Margin và Padding

**Application:**
- Component spacing
- Content separation
- Visual hierarchy
- Responsive adjustments

### 8.3. Containers

#### 8.3.1. Page Containers

**Purpose:**
- Content boundaries
- Responsive widths
- Centered alignment
- Consistent margins

#### 8.3.2. Section Containers

**Purpose:**
- Content grouping
- Background areas
- Spacing control
- Visual separation

## 9. TYPOGRAPHY

Typography system đảm bảo consistent text presentation.

### 9.1. Font Families

#### 9.1.1. Primary Font

**Font**: Inter
- **Usage**: Body text, UI elements
- **Weights**: Regular (400), Medium (500), Bold (700)
- **Characteristics**: Readable, modern, web-optimized

#### 9.1.2. Monospace Font

**Font**: Fira Code
- **Usage**: Code, technical content
- **Weights**: Regular (400), Medium (500)
- **Characteristics**: Ligatures, coding-optimized

### 9.2. Type Scale

#### 9.2.1. Heading Sizes

- **H1**: 32px, Bold, Line height 1.2
- **H2**: 24px, Bold, Line height 1.3
- **H3**: 20px, Bold, Line height 1.4
- **H4**: 18px, Medium, Line height 1.4
- **H5**: 16px, Medium, Line height 1.5
- **H6**: 14px, Medium, Line height 1.5

#### 9.2.2. Body Sizes

- **Large**: 18px, Regular, Line height 1.6
- **Base**: 16px, Regular, Line height 1.5
- **Small**: 14px, Regular, Line height 1.4
- **Caption**: 12px, Regular, Line height 1.3

### 9.3. Text Styles

#### 9.3.1. Emphasis

- **Bold**: Important information
- **Italic**: Emphasis, quotes
- **Underline**: Links, interactive text
- **Strikethrough**: Deleted content

#### 9.3.2. Colors

- **Primary**: Main text color
- **Secondary**: Supporting text
- **Muted**: Less important text
- **Inverse**: Text on dark backgrounds

## 10. ICONS

Icon system cung cấp visual symbols cho actions và concepts.

### 10.1. Icon Library

#### 10.1.1. Icon Set

**Source**: Heroicons, Feather Icons
- **Style**: Outline và solid variants
- **Sizes**: 16px, 20px, 24px, 32px
- **Format**: SVG for scalability

#### 10.1.2. Icon Categories

**Navigation Icons:**
- Menu, close, arrow directions
- Home, back, forward
- Expand, collapse

**Action Icons:**
- Edit, delete, save, cancel
- Add, remove, copy, share
- Search, filter, sort

**Status Icons:**
- Success, error, warning, info
- Loading, completed, pending
- Online, offline, sync

### 10.2. Icon Usage

#### 10.2.1. Sizing Guidelines

- **16px**: Small buttons, inline text
- **20px**: Standard buttons, form elements
- **24px**: Large buttons, headers
- **32px**: Feature icons, illustrations

#### 10.2.2. Color Guidelines

- **Primary**: Interactive icons
- **Secondary**: Supporting icons
- **Muted**: Decorative icons
- **Status**: State-specific colors

### 10.3. Icon Accessibility

#### 10.3.1. Alternative Text

**Requirements:**
- Descriptive alt text
- Context-appropriate descriptions
- Screen reader compatibility
- Meaningful labels

#### 10.3.2. Interactive Icons

**Requirements:**
- Adequate touch targets
- Focus indicators
- Keyboard accessibility
- Clear purpose

## 11. KẾT LUẬN

Thành phần UI cơ bản của NextFlow CRM được thiết kế để tạo ra trải nghiệm người dùng nhất quán, accessible và hiệu quả. Mỗi component được xây dựng với:

### 11.1. Design Principles

**Consistency:**
- Unified design language
- Predictable behaviors
- Standardized patterns
- Cohesive experience

**Accessibility:**
- WCAG compliance
- Keyboard navigation
- Screen reader support
- Inclusive design

**Usability:**
- Intuitive interactions
- Clear feedback
- Error prevention
- User-centered design

### 11.2. Implementation Guidelines

**Development:**
- Component-based architecture
- Reusable code patterns
- Performance optimization
- Maintainable structure

**Quality Assurance:**
- Cross-browser testing
- Accessibility testing
- Usability testing
- Performance monitoring

## 12. TÀI LIỆU THAM KHẢO

### 12.1. Design Systems
- [Material Design](https://material.io/design)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Ant Design](https://ant.design/)

### 12.2. Accessibility
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [WebAIM](https://webaim.org/)
- [A11y Project](https://www.a11yproject.com/)

### 12.3. NextFlow CRM Documentation
- [Hệ thống Thiết kế](../he-thong-thiet-ke.md)
- [Nguyên tắc Thiết kế](../nguyen-tac-thiet-ke.md)
- [Thiết kế Chi tiết Trang](../thiet-ke-chi-tiet-trang.md)

---

**Cập nhật lần cuối**: 2024-01-15
**Phiên bản**: 2.0.0
**Tác giả**: NextFlow Design Team
