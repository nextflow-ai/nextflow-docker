# WIREFRAMES VÀ MOCKUPS NextFlow CRM

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Wireframes Low-Fidelity](#2-wireframes-low-fidelity)
3. [Mockups High-Fidelity](#3-mockups-high-fidelity)
4. [Prototype Interactive](#4-prototype-interactive)
5. [Design System Components](#5-design-system-components)
6. [User Flow Diagrams](#6-user-flow-diagrams)
7. [Responsive Layouts](#7-responsive-layouts)
8. [Accessibility Considerations](#8-accessibility-considerations)
9. [Design Handoff](#9-design-handoff)
10. [Kết luận](#10-kết-luận)
11. [Tài liệu tham khảo](#11-tài-liệu-tham-khảo)

## 1. GIỚI THIỆU

Tài liệu này mô tả về wireframes và mockups cho NextFlow CRM, bao gồm các thiết kế từ low-fidelity wireframes đến high-fidelity mockups và interactive prototypes. Mục tiêu là cung cấp hướng dẫn chi tiết cho việc thiết kế và phát triển giao diện người dùng.

### 1.1. Quy trình thiết kế

**Giai đoạn 1: Research và Planning**
- User research và persona development
- Information architecture
- User journey mapping
- Content strategy

**Giai đoạn 2: Wireframing**
- Low-fidelity wireframes
- Information hierarchy
- Layout structure
- Navigation flow

**Giai đoạn 3: Visual Design**
- High-fidelity mockups
- Visual style guide
- Component library
- Brand application

**Giai đoạn 4: Prototyping**
- Interactive prototypes
- Micro-interactions
- Animation specifications
- User testing

### 1.2. Tools và Platforms

**Design Tools:**
- **Figma**: Primary design tool cho collaborative design
- **Sketch**: Alternative design tool
- **Adobe XD**: Prototyping và design
- **Framer**: Advanced prototyping

**Collaboration Tools:**
- **Figma**: Real-time collaboration
- **Zeplin**: Design handoff
- **InVision**: Prototype sharing
- **Miro**: Brainstorming và user flows

## 2. WIREFRAMES LOW-FIDELITY

### 2.1. Dashboard Wireframes

**Admin Dashboard:**
```
┌─────────────────────────────────────────────────────────┐
│ [Logo] NextFlow CRM        [Search] [Notifications] [User] │
├─────────────────────────────────────────────────────────┤
│ [Nav]  │ System Overview                                │
│ ├─Dashboard │ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐           │
│ ├─Users     │ │Users│ │Orgs │ │Rev  │ │Health│           │
│ ├─Settings  │ │1,245│ │ 87  │ │$24K │ │98.5%│           │
│ ├─Reports   │ └─────┘ └─────┘ └─────┘ └─────┘           │
│ └─Support   │                                           │
│             │ ┌─────────────────┐ ┌─────────────┐       │
│             │ │   User Growth   │ │Subscription │       │
│             │ │    [Chart]      │ │   [Pie]     │       │
│             │ └─────────────────┘ └─────────────┘       │
│             │                                           │
│             │ ┌─────────────────┐ ┌─────────────┐       │
│             │ │Recent Signups   │ │System Alerts│       │
│             │ │    [Table]      │ │   [List]    │       │
│             │ └─────────────────┘ └─────────────┘       │
└─────────────────────────────────────────────────────────┘
```

**Sales Dashboard:**
```
┌─────────────────────────────────────────────────────────┐
│ [Logo] NextFlow CRM        [Search] [Notifications] [User] │
├─────────────────────────────────────────────────────────┤
│ [Nav]  │ Sales Performance                              │
│ ├─Dashboard │ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐           │
│ ├─Customers │ │Sales│ │Conv │ │Deals│ │Target│           │
│ ├─Pipeline  │ │$45K │ │12.5%│ │ 23  │ │85%  │           │
│ ├─Activities│ └─────┘ └─────┘ └─────┘ └─────┘           │
│ └─Reports   │                                           │
│             │ ┌─────────────────────────────────────────┐ │
│             │ │        Sales Pipeline (Kanban)         │ │
│             │ │ [Lead] [Qualified] [Proposal] [Closed] │ │
│             │ │  [3]      [5]        [2]       [1]    │ │
│             │ └─────────────────────────────────────────┘ │
│             │                                           │
│             │ ┌─────────────────┐ ┌─────────────┐       │
│             │ │Recent Activities│ │Quick Actions│       │
│             │ │    [Timeline]   │ │  [Buttons]  │       │
│             │ └─────────────────┘ └─────────────┘       │
└─────────────────────────────────────────────────────────┘
```

### 2.2. Customer Management Wireframes

**Customer List:**
```
┌─────────────────────────────────────────────────────────┐
│ Customer Management                    [+ Add Customer] │
├─────────────────────────────────────────────────────────┤
│ [Search...] [Filter: All] [Status: All] [Export]       │
├─────────────────────────────────────────────────────────┤
│ ☐ │ Name        │ Email           │ Company │ Status   │
│ ☐ │ John Doe    │ john@email.com  │ Acme    │ Active   │
│ ☐ │ Jane Smith  │ jane@email.com  │ XYZ     │ Pending  │
│ ☐ │ Bob Wilson  │ bob@email.com   │ ABC     │ Active   │
│   │ ...         │ ...             │ ...     │ ...      │
├─────────────────────────────────────────────────────────┤
│ Showing 1-10 of 125        [< Previous] [1][2][3] [Next >] │
└─────────────────────────────────────────────────────────┘
```

**Customer Detail:**
```
┌─────────────────────────────────────────────────────────┐
│ ← Back to Customers    John Doe                [Edit]   │
├─────────────────────────────────────────────────────────┤
│ [Photo] │ John Doe                                      │
│  [IMG]  │ john@email.com                                │
│         │ Acme Inc. - Senior Manager                    │
│         │ Last contact: 2 days ago                      │
├─────────────────────────────────────────────────────────┤
│ [Overview] [Activities] [Opportunities] [Orders] [Support] │
├─────────────────────────────────────────────────────────┤
│ Contact Information          │ Recent Activities         │
│ ┌─────────────────────────┐  │ ┌─────────────────────────┐ │
│ │ Phone: +84 901 234 567  │  │ │ • Email sent (2d ago)   │ │
│ │ Address: 123 Main St    │  │ │ • Meeting scheduled     │ │
│ │ City: Ho Chi Minh       │  │ │ • Quote requested       │ │
│ │ Country: Vietnam        │  │ │ • Call completed        │ │
│ └─────────────────────────┘  │ └─────────────────────────┘ │
│                              │                           │
│ Company Information          │ Quick Actions             │
│ ┌─────────────────────────┐  │ ┌─────────────────────────┐ │
│ │ Company: Acme Inc.      │  │ │ [Send Email] [Call]     │ │
│ │ Industry: Technology    │  │ │ [Schedule] [Add Note]   │ │
│ │ Size: 50-100 employees  │  │ │ [Create Opportunity]    │ │
│ └─────────────────────────┘  │ └─────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### 2.3. Mobile Wireframes

**Mobile Dashboard:**
```
┌─────────────────┐
│ ☰ NextFlow [🔔] │
├─────────────────┤
│ Welcome back,   │
│ John Doe        │
├─────────────────┤
│ ┌─────┐ ┌─────┐ │
│ │Sales│ │Leads│ │
│ │$45K │ │ 23  │ │
│ └─────┘ └─────┘ │
│ ┌─────┐ ┌─────┐ │
│ │Deals│ │Tasks│ │
│ │ 12  │ │  5  │ │
│ └─────┘ └─────┘ │
├─────────────────┤
│ Recent Activity │
│ • Meeting with  │
│   Acme Inc.     │
│ • Quote sent to │
│   XYZ Corp      │
│ • Call scheduled│
├─────────────────┤
│ Quick Actions   │
│ [Add Customer]  │
│ [Create Deal]   │
│ [Log Activity]  │
└─────────────────┘
```

## 3. MOCKUPS HIGH-FIDELITY

### 3.1. Visual Design Specifications

**Color Palette:**
- Primary: #3366FF (Blue)
- Secondary: #FF6633 (Orange)
- Success: #33CC99 (Green)
- Warning: #FFCC33 (Yellow)
- Error: #FF3366 (Red)
- Neutral: #F8F9FA, #E9ECEF, #6C757D, #343A40

**Typography:**
- Heading: Inter Bold (24px, 20px, 18px, 16px)
- Body: Inter Regular (16px, 14px)
- Caption: Inter Medium (12px, 10px)
- Code: Fira Code (14px, 12px)

**Spacing System:**
- Base unit: 8px
- Spacing scale: 4px, 8px, 16px, 24px, 32px, 48px, 64px

**Border Radius:**
- Small: 4px
- Medium: 8px
- Large: 12px
- Round: 50%

### 3.2. Component Specifications

**Buttons:**
- Primary: Blue background, white text, 8px radius
- Secondary: White background, blue border, blue text
- Danger: Red background, white text
- Sizes: Small (32px), Medium (40px), Large (48px)

**Form Elements:**
- Input fields: 40px height, 8px radius, gray border
- Select dropdowns: Consistent with inputs
- Checkboxes: 16px square, blue when checked
- Radio buttons: 16px circle, blue when selected

**Cards:**
- Background: White
- Border: 1px solid #E9ECEF
- Radius: 8px
- Shadow: 0 2px 4px rgba(0,0,0,0.1)
- Padding: 24px

### 3.3. Layout Grids

**Desktop Grid:**
- Container: 1200px max-width
- Columns: 12 columns
- Gutter: 24px
- Margin: 24px

**Tablet Grid:**
- Container: 768px max-width
- Columns: 8 columns
- Gutter: 16px
- Margin: 16px

**Mobile Grid:**
- Container: 100% width
- Columns: 4 columns
- Gutter: 16px
- Margin: 16px

## 4. PROTOTYPE INTERACTIVE

### 4.1. Interaction Patterns

**Navigation:**
- Hover states: Subtle background color change
- Active states: Bold text và accent color
- Transitions: 200ms ease-in-out

**Form Interactions:**
- Focus states: Blue border và shadow
- Validation: Real-time feedback
- Error states: Red border và error message

**Data Tables:**
- Sorting: Click column headers
- Filtering: Dropdown filters
- Pagination: Number-based navigation

### 4.2. Micro-interactions

**Loading States:**
- Skeleton screens cho content loading
- Progress bars cho file uploads
- Spinners cho quick actions

**Feedback:**
- Success messages: Green toast notifications
- Error messages: Red inline alerts
- Info messages: Blue informational banners

**Animations:**
- Page transitions: Slide animations
- Modal appearances: Fade và scale
- Button clicks: Subtle scale effect

### 4.3. Responsive Behaviors

**Breakpoint Transitions:**
- Smooth layout changes
- Content reflow
- Navigation adaptations

**Touch Interactions:**
- Tap targets: Minimum 44px
- Swipe gestures: Horizontal scrolling
- Pull-to-refresh: List updates

## 5. DESIGN SYSTEM COMPONENTS

### 5.1. Atomic Components

**Atoms:**
- Buttons, inputs, labels, icons
- Colors, typography, spacing
- Borders, shadows, animations

**Molecules:**
- Form groups, search bars
- Navigation items, breadcrumbs
- Card headers, metric displays

**Organisms:**
- Headers, sidebars, footers
- Data tables, forms, modals
- Dashboards, content sections

### 5.2. Component Library

**Documentation:**
- Component specifications
- Usage guidelines
- Code examples
- Accessibility notes

**Maintenance:**
- Version control
- Update procedures
- Testing protocols
- Design tokens

## 6. USER FLOW DIAGRAMS

### 6.1. Customer Onboarding Flow

```
Start → Registration → Email Verification → Profile Setup → 
Tour → First Action → Success
```

**Decision Points:**
- Email verification success/failure
- Profile completion level
- Tour completion vs skip
- First action type selection

### 6.2. Sales Process Flow

```
Lead Creation → Qualification → Opportunity → Proposal → 
Negotiation → Closing → Customer Onboarding
```

**Parallel Processes:**
- Communication tracking
- Document management
- Team collaboration
- Progress reporting

### 6.3. Support Ticket Flow

```
Issue Identification → Self-Service Search → Ticket Creation → 
Assignment → Resolution → Feedback
```

**Escalation Paths:**
- Automatic escalation rules
- Manual escalation options
- Supervisor involvement
- Customer satisfaction tracking

## 7. RESPONSIVE LAYOUTS

### 7.1. Breakpoint Strategy

**Mobile First Approach:**
- Start with mobile design
- Progressive enhancement
- Feature prioritization
- Performance optimization

**Breakpoint Definitions:**
- Mobile: 320px - 767px
- Tablet: 768px - 1023px
- Desktop: 1024px+
- Large Desktop: 1440px+

### 7.2. Layout Adaptations

**Navigation:**
- Mobile: Hamburger menu
- Tablet: Collapsible sidebar
- Desktop: Full sidebar

**Content:**
- Mobile: Single column
- Tablet: Two columns
- Desktop: Multi-column layouts

**Data Tables:**
- Mobile: Card layout
- Tablet: Horizontal scroll
- Desktop: Full table view

## 8. ACCESSIBILITY CONSIDERATIONS

### 8.1. WCAG Compliance

**Level AA Requirements:**
- Color contrast: 4.5:1 minimum
- Keyboard navigation: Full support
- Screen reader: Proper markup
- Text scaling: Up to 200%

**Implementation:**
- Semantic HTML structure
- ARIA labels và descriptions
- Focus management
- Alternative text cho images

### 8.2. Inclusive Design

**Motor Accessibility:**
- Large touch targets
- Alternative input methods
- Reduced motion options
- Voice control support

**Cognitive Accessibility:**
- Clear language
- Consistent patterns
- Error prevention
- Help và guidance

## 9. DESIGN HANDOFF

### 9.1. Developer Resources

**Design Specifications:**
- Detailed measurements
- Color codes và typography
- Interaction specifications
- Asset exports

**Documentation:**
- Component guidelines
- Implementation notes
- Browser support
- Performance considerations

### 9.2. Quality Assurance

**Design Review:**
- Pixel-perfect implementation
- Interaction accuracy
- Responsive behavior
- Accessibility compliance

**Testing Protocols:**
- Cross-browser testing
- Device testing
- Performance testing
- User acceptance testing

## 10. KẾT LUẬN

Wireframes và mockups của NextFlow CRM được thiết kế với mục tiêu tạo ra trải nghiệm người dùng tối ưu, đảm bảo tính nhất quán và khả năng sử dụng cao. Quy trình thiết kế từ wireframes đến prototypes giúp đảm bảo chất lượng và hiệu quả trong việc phát triển sản phẩm.

### 10.1. Best Practices

**Design Process:**
- User-centered design approach
- Iterative design và testing
- Collaborative design process
- Data-driven design decisions

**Quality Assurance:**
- Consistent design system
- Accessibility compliance
- Performance optimization
- Cross-platform compatibility

## 11. TÀI LIỆU THAM KHẢO

### 11.1. Design Resources
- [Figma Design System](https://www.figma.com/design-systems/)
- [Material Design](https://material.io/design)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### 11.2. NextFlow CRM Documentation
- [Hệ thống Thiết kế](./he-thong-thiet-ke.md)
- [Thiết kế Chi tiết Trang](./thiet-ke-chi-tiet-trang.md)
- [Giao diện theo Đối tượng](./giao-dien/giao-dien-theo-doi-tuong.md)

### 11.3. Tools và Resources
- [Figma](https://www.figma.com/)
- [Sketch](https://www.sketch.com/)
- [Adobe XD](https://www.adobe.com/products/xd.html)
- [Framer](https://www.framer.com/)

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 1.0.0  
**Tác giả**: NextFlow Design Team
