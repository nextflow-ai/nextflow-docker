# API QUẢN LÝ DỰ ÁN NextFlow CRM

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Dự án](#2-endpoints-dự-án)
3. [Endpoints Công việc](#3-endpoints-công-việc)
4. [Endpoints Thời gian](#4-endpoints-thời-gian)
5. [Endpoints Tài nguyên](#5-endpoints-tài-nguyên)
6. [Endpoints Báo cáo](#6-endpoints-báo-cáo)
7. [Endpoints Gantt](#7-endpoints-gantt)
8. [Mã lỗi](#8-mã-lỗi)

## 1. GIỚI THIỆU

API Quản lý Dự án NextFlow CRM cung cấp các endpoint để tạo, quản lý dự án, phân công công việc, theo dõi tiến độ và báo cáo.

### 1.1. Base URL

```
https://api.nextflow-crm.com/v1/projects
```

### 1.2. Xác thực

```http
Authorization: Bearer {your_token}
X-Project-Role: {user_role_in_project}
```

## 2. ENDPOINTS DỰ ÁN

### 2.1. Tạo dự án mới

```http
POST /projects
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "Triển khai NextFlow CRM cho Công ty ABC",
  "description": "Dự án triển khai hệ thống CRM toàn diện cho 50 nhân viên",
  "customerId": "customer_123456789",
  "contactId": "contact_123456789",
  "startDate": "2024-11-01",
  "endDate": "2025-01-31",
  "budget": 500000000,
  "currency": "VND",
  "priority": "high",
  "status": "planning",
  "templateId": "template_crm_implementation",
  "teamMembers": [
    {
      "userId": "user_123456789",
      "role": "project_manager",
      "hourlyRate": 500000,
      "allocation": 100
    },
    {
      "userId": "user_234567890", 
      "role": "developer",
      "hourlyRate": 300000,
      "allocation": 80
    }
  ],
  "customFields": {
    "contractNumber": "CONTRACT001",
    "clientBudget": 500000000,
    "riskLevel": "medium"
  }
}
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "Dự án đã được tạo thành công",
  "data": {
    "id": "project_123456789",
    "projectCode": "PRJ001",
    "name": "Triển khai NextFlow CRM cho Công ty ABC",
    "status": "planning",
    "customer": {
      "id": "customer_123456789",
      "name": "Công ty ABC",
      "contact": {
        "name": "Nguyễn Văn A",
        "email": "cto@abc.com",
        "phone": "0901234567"
      }
    },
    "timeline": {
      "startDate": "2024-11-01",
      "endDate": "2025-01-31",
      "duration": 92,
      "workingDays": 66
    },
    "budget": {
      "total": 500000000,
      "spent": 0,
      "committed": 0,
      "remaining": 500000000
    },
    "team": {
      "totalMembers": 2,
      "projectManager": "Nguyễn Văn B",
      "roles": ["project_manager", "developer"]
    },
    "progress": {
      "completion": 0,
      "tasksTotal": 0,
      "tasksCompleted": 0,
      "milestonesTotal": 0,
      "milestonesCompleted": 0
    },
    "createdAt": "2024-10-27T10:30:00Z"
  }
}
```

### 2.2. Lấy danh sách dự án

```http
GET /projects
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| page | integer | Số trang (mặc định: 1) |
| perPage | integer | Số dự án mỗi trang (mặc định: 20) |
| status | string | Trạng thái (planning, active, on_hold, completed, cancelled) |
| customerId | string | Lọc theo khách hàng |
| managerId | string | Lọc theo project manager |
| priority | string | Mức độ ưu tiên (low, medium, high, critical) |
| fromDate | string | Từ ngày bắt đầu |
| toDate | string | Đến ngày kết thúc |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": [
    {
      "id": "project_123456789",
      "projectCode": "PRJ001",
      "name": "Triển khai NextFlow CRM cho Công ty ABC",
      "customer": {
        "name": "Công ty ABC",
        "logo": "https://cdn.nextflow-crm.com/logos/abc.png"
      },
      "status": "active",
      "priority": "high",
      "progress": 35,
      "budget": {
        "total": 500000000,
        "spent": 175000000,
        "utilization": 35
      },
      "timeline": {
        "startDate": "2024-11-01",
        "endDate": "2025-01-31",
        "daysRemaining": 65,
        "isOverdue": false
      },
      "team": {
        "manager": "Nguyễn Văn B",
        "memberCount": 5,
        "avatars": [
          "https://cdn.nextflow-crm.com/avatars/user1.jpg",
          "https://cdn.nextflow-crm.com/avatars/user2.jpg"
        ]
      },
      "health": {
        "status": "green",
        "score": 85,
        "risks": 1
      }
    }
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "perPage": 20,
      "totalPages": 3,
      "totalItems": 45
    },
    "summary": {
      "totalProjects": 45,
      "activeProjects": 12,
      "completedProjects": 28,
      "totalBudget": 15000000000,
      "totalRevenue": 12000000000
    }
  }
}
```

### 2.3. Cập nhật dự án

```http
PUT /projects/{projectId}
Content-Type: application/json
```

### 2.4. Thay đổi trạng thái dự án

```http
POST /projects/{projectId}/status
Content-Type: application/json
```

#### Request Body

```json
{
  "status": "active",
  "reason": "Khách hàng đã approve và ký hợp đồng",
  "effectiveDate": "2024-11-01",
  "notifyTeam": true,
  "notifyClient": true
}
```

## 3. ENDPOINTS CÔNG VIỆC

### 3.1. Tạo task mới

```http
POST /projects/{projectId}/tasks
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "Thiết kế database module khách hàng",
  "description": "Thiết kế cấu trúc database cho module quản lý khách hàng bao gồm customers, contacts, addresses",
  "assigneeId": "user_123456789",
  "reviewerId": "user_234567890",
  "startDate": "2024-11-05",
  "dueDate": "2024-11-08",
  "estimatedHours": 24,
  "priority": "high",
  "complexity": "medium",
  "tags": ["database", "design", "backend"],
  "dependencies": [
    {
      "taskId": "task_987654321",
      "type": "finish_to_start",
      "lag": 0
    }
  ],
  "checklist": [
    "Phân tích yêu cầu business",
    "Thiết kế ERD",
    "Định nghĩa relationships", 
    "Tối ưu indexes",
    "Tạo migration scripts"
  ],
  "customFields": {
    "module": "customer_management",
    "complexity_score": 7,
    "skill_required": "database_design"
  }
}
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "Task đã được tạo thành công",
  "data": {
    "id": "task_123456789",
    "taskNumber": "TSK001",
    "name": "Thiết kế database module khách hàng",
    "project": {
      "id": "project_123456789",
      "name": "Triển khai NextFlow CRM cho Công ty ABC"
    },
    "assignee": {
      "id": "user_123456789",
      "name": "Nguyễn Văn B",
      "avatar": "https://cdn.nextflow-crm.com/avatars/user1.jpg",
      "role": "Database Architect"
    },
    "status": "todo",
    "priority": "high",
    "progress": 0,
    "timeline": {
      "startDate": "2024-11-05",
      "dueDate": "2024-11-08",
      "estimatedHours": 24,
      "actualHours": 0,
      "remainingHours": 24
    },
    "dependencies": {
      "blockedBy": 1,
      "blocking": 0,
      "canStart": false
    },
    "checklist": {
      "total": 5,
      "completed": 0,
      "percentage": 0
    },
    "createdAt": "2024-10-27T10:30:00Z"
  }
}
```

### 3.2. Lấy danh sách tasks

```http
GET /projects/{projectId}/tasks
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| status | string | Trạng thái (todo, in_progress, review, done) |
| assigneeId | string | Lọc theo người thực hiện |
| priority | string | Mức độ ưu tiên |
| dueDate | string | Lọc theo deadline |
| tags | string | Lọc theo tags (comma-separated) |
| view | string | Kiểu hiển thị (list, kanban, calendar) |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "kanban": {
      "todo": [
        {
          "id": "task_123456789",
          "name": "Thiết kế UI module báo cáo",
          "assignee": "Nguyễn Văn C",
          "dueDate": "2024-11-10",
          "priority": "medium",
          "estimatedHours": 16,
          "tags": ["ui", "design", "frontend"]
        }
      ],
      "in_progress": [
        {
          "id": "task_234567890",
          "name": "Phát triển API khách hàng",
          "assignee": "Trần Thị D",
          "progress": 75,
          "dueDate": "2024-11-08",
          "priority": "high",
          "actualHours": 18,
          "estimatedHours": 24
        }
      ],
      "review": [
        {
          "id": "task_345678901",
          "name": "Module đăng nhập SSO",
          "assignee": "Lê Văn E",
          "reviewer": "Nguyễn Văn B",
          "completedAt": "2024-11-06",
          "priority": "high"
        }
      ],
      "done": [
        {
          "id": "task_456789012",
          "name": "Phân tích yêu cầu",
          "assignee": "Nguyễn Văn B",
          "completedAt": "2024-11-01",
          "actualHours": 32,
          "estimatedHours": 30
        }
      ]
    },
    "summary": {
      "totalTasks": 35,
      "todoTasks": 8,
      "inProgressTasks": 5,
      "reviewTasks": 3,
      "doneTasks": 19,
      "overdueTasks": 2,
      "completionRate": 54.3
    }
  }
}
```

### 3.3. Cập nhật tiến độ task

```http
PUT /projects/{projectId}/tasks/{taskId}/progress
Content-Type: application/json
```

#### Request Body

```json
{
  "progress": 75,
  "status": "in_progress",
  "actualHours": 18,
  "notes": "Đã hoàn thành 3/4 API endpoints. Còn lại search và delete customer.",
  "completedChecklist": [
    "Phân tích yêu cầu business",
    "Thiết kế ERD", 
    "Định nghĩa relationships"
  ],
  "blockers": [
    {
      "description": "Chờ khách hàng xác nhận business rules",
      "severity": "medium",
      "reportedAt": "2024-11-07T14:30:00Z"
    }
  ]
}
```

## 4. ENDPOINTS THỜI GIAN

### 4.1. Bắt đầu time tracking

```http
POST /projects/{projectId}/tasks/{taskId}/time/start
Content-Type: application/json
```

#### Request Body

```json
{
  "description": "Thiết kế ERD cho module khách hàng",
  "category": "development",
  "billable": true
}
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "Đã bắt đầu tracking thời gian",
  "data": {
    "timeEntryId": "time_123456789",
    "taskId": "task_123456789",
    "startTime": "2024-11-07T09:00:00Z",
    "description": "Thiết kế ERD cho module khách hàng",
    "isRunning": true,
    "duration": 0
  }
}
```

### 4.2. Dừng time tracking

```http
POST /projects/{projectId}/tasks/{taskId}/time/stop
Content-Type: application/json
```

#### Request Body

```json
{
  "timeEntryId": "time_123456789",
  "endTime": "2024-11-07T12:30:00Z",
  "description": "Hoàn thành thiết kế ERD, tạo 5 tables chính",
  "actualWork": "Thiết kế customers, contacts, addresses, activities, notes tables"
}
```

### 4.3. Lấy timesheet

```http
GET /projects/{projectId}/timesheet
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| userId | string | Lọc theo nhân viên |
| fromDate | string | Từ ngày |
| toDate | string | Đến ngày |
| billable | boolean | Chỉ lấy giờ billable |
| groupBy | string | Nhóm theo (day, week, task, user) |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "period": {
      "fromDate": "2024-11-04",
      "toDate": "2024-11-10",
      "workingDays": 5
    },
    "summary": {
      "totalHours": 42.5,
      "billableHours": 38.0,
      "nonBillableHours": 4.5,
      "billableRate": 89.4,
      "estimatedRevenue": 11400000
    },
    "entries": [
      {
        "date": "2024-11-07",
        "user": "Nguyễn Văn B",
        "task": "Thiết kế database module khách hàng",
        "startTime": "09:00",
        "endTime": "12:30",
        "duration": 3.5,
        "description": "Thiết kế ERD cho module khách hàng",
        "category": "development",
        "billable": true,
        "hourlyRate": 300000
      }
    ],
    "dailySummary": [
      {
        "date": "2024-11-07",
        "totalHours": 8.5,
        "billableHours": 7.5,
        "tasks": 3,
        "revenue": 2250000
      }
    ]
  }
}
```

## 5. ENDPOINTS TÀI NGUYÊN

### 5.1. Phân bổ tài nguyên

```http
GET /projects/{projectId}/resources
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "teamMembers": [
      {
        "userId": "user_123456789",
        "name": "Nguyễn Văn B",
        "role": "Project Manager",
        "allocation": 100,
        "hourlyRate": 500000,
        "capacity": {
          "totalHours": 160,
          "allocatedHours": 160,
          "availableHours": 0,
          "utilizationRate": 100
        },
        "workload": {
          "thisWeek": 40,
          "nextWeek": 40,
          "thisMonth": 160,
          "status": "fully_allocated"
        },
        "skills": ["project_management", "agile", "stakeholder_management"]
      }
    ],
    "resourceSummary": {
      "totalTeamMembers": 5,
      "totalCapacity": 800,
      "totalAllocated": 720,
      "totalAvailable": 80,
      "averageUtilization": 90,
      "overallocatedMembers": 1,
      "underutilizedMembers": 1
    },
    "recommendations": [
      {
        "type": "overallocation",
        "message": "Nguyễn Văn A đang overallocated 120%. Cần điều chỉnh workload.",
        "severity": "high",
        "suggestions": [
          "Chuyển 20h sang Trần Thị B",
          "Gia hạn deadline task TSK005"
        ]
      }
    ]
  }
}
```

### 5.2. Cập nhật phân bổ

```http
PUT /projects/{projectId}/resources/{userId}
Content-Type: application/json
```

#### Request Body

```json
{
  "allocation": 80,
  "hourlyRate": 350000,
  "role": "Senior Developer",
  "startDate": "2024-11-01",
  "endDate": "2025-01-31",
  "skills": ["react", "nodejs", "database_design"],
  "notes": "Giảm allocation xuống 80% để tham gia dự án khác"
}
```

## 6. ENDPOINTS BÁO CÁO

### 6.1. Dashboard dự án

```http
GET /projects/{projectId}/dashboard
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "overview": {
      "progress": 35,
      "health": "green",
      "status": "active",
      "daysRemaining": 65,
      "budgetUtilization": 35,
      "teamSatisfaction": 4.2
    },
    "milestones": {
      "upcoming": [
        {
          "name": "Demo cho khách hàng",
          "dueDate": "2024-11-15",
          "daysUntil": 8,
          "progress": 80,
          "status": "on_track"
        }
      ],
      "completed": [
        {
          "name": "Hoàn thành phân tích",
          "completedDate": "2024-11-01",
          "onTime": true
        }
      ]
    },
    "risks": [
      {
        "id": "risk_001",
        "description": "Thiếu Senior Developer",
        "impact": "medium",
        "probability": "high",
        "mitigation": "Tuyển thêm hoặc outsource",
        "owner": "Nguyễn Văn B"
      }
    ],
    "kpis": {
      "schedulePerformance": 1.0,
      "costPerformance": 1.05,
      "qualityScore": 85,
      "clientSatisfaction": 4.5,
      "teamVelocity": 32
    }
  }
}
```

### 6.2. Báo cáo tiến độ

```http
GET /projects/{projectId}/progress-report
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| period | string | Kỳ báo cáo (weekly, monthly) |
| format | string | Định dạng (json, pdf, excel) |
| includeDetails | boolean | Bao gồm chi tiết tasks |

## 7. ENDPOINTS GANTT

### 7.1. Lấy dữ liệu Gantt

```http
GET /projects/{projectId}/gantt
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "timeline": {
      "startDate": "2024-11-01",
      "endDate": "2025-01-31",
      "totalDays": 92,
      "workingDays": 66
    },
    "tasks": [
      {
        "id": "task_123456789",
        "name": "Giai đoạn 1: Phân tích",
        "type": "phase",
        "startDate": "2024-11-01",
        "endDate": "2024-11-15",
        "duration": 11,
        "progress": 100,
        "dependencies": [],
        "children": [
          {
            "id": "task_234567890",
            "name": "Khảo sát hiện trạng",
            "type": "task",
            "startDate": "2024-11-01",
            "endDate": "2024-11-05",
            "duration": 3,
            "progress": 100,
            "assignee": "Nguyễn Văn B"
          }
        ]
      }
    ],
    "milestones": [
      {
        "id": "milestone_001",
        "name": "Hoàn thành phân tích",
        "date": "2024-11-15",
        "status": "completed"
      }
    ],
    "criticalPath": [
      "task_234567890",
      "task_345678901",
      "task_456789012"
    ]
  }
}
```

## 8. MÃ LỖI

| Code | Message | Mô tả |
|------|---------|-------|
| 4001 | Project not found | Không tìm thấy dự án |
| 4002 | Task not found | Không tìm thấy task |
| 4003 | Access denied | Không có quyền truy cập |
| 4004 | Invalid date range | Khoảng thời gian không hợp lệ |
| 4005 | Resource conflict | Xung đột tài nguyên |
| 4006 | Dependency cycle | Phụ thuộc vòng tròn |
| 4007 | Budget exceeded | Vượt quá ngân sách |
| 5001 | Time tracking failed | Tracking thời gian thất bại |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM Project Team
