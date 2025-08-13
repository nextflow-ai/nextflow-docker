# TRIỂN KHAI NEXTAUTH.JS THAY THẾ KEYCLOAK

## 1. TỔNG QUAN

NextAuth.js là giải pháp authentication hiện đại, nhẹ và dễ tích hợp cho ứng dụng Next.js. Đây là sự thay thế hoàn hảo cho Keycloak trong môi trường startup.

### 1.1. Lợi ích so với Keycloak

| Tiêu chí | Keycloak | NextAuth.js |
|----------|----------|-------------|
| **Resource Usage** | Nặng (1GB RAM) | Nhẹ (<100MB) |
| **Complexity** | Phức tạp, nhiều config | Đơn giản, ít config |
| **Integration** | Cần setup riêng | Tích hợp sẵn Next.js |
| **Startup Cost** | $50-100/month | $0 |
| **Learning Curve** | Cao | Thấp |
| **Community** | Enterprise focus | Developer-friendly |

### 1.2. Tính năng hỗ trợ

- ✅ Multiple OAuth providers (Google, GitHub, Facebook, etc.)
- ✅ Email/Password authentication
- ✅ JWT và Database sessions
- ✅ Multi-tenant support
- ✅ Role-based access control
- ✅ TypeScript support
- ✅ Serverless compatible

## 2. KIẾN TRÚC AUTHENTICATION

### 2.1. Luồng Authentication

```mermaid
graph TD
    A[User Login] --> B{Provider Type}
    B -->|OAuth| C[OAuth Provider]
    B -->|Email/Password| D[Credentials Check]
    C --> E[NextAuth Callback]
    D --> E
    E --> F[Create Session]
    F --> G[Set JWT Token]
    G --> H[Redirect to Dashboard]
    
    I[API Request] --> J[Middleware Check]
    J --> K{Valid Token?}
    K -->|Yes| L[Allow Access]
    K -->|No| M[Return 401]
```

### 2.2. Database Schema

```sql
-- NextAuth.js required tables
CREATE TABLE accounts (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  type TEXT NOT NULL,
  provider TEXT NOT NULL,
  provider_account_id TEXT NOT NULL,
  refresh_token TEXT,
  access_token TEXT,
  expires_at INTEGER,
  token_type TEXT,
  scope TEXT,
  id_token TEXT,
  session_state TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE sessions (
  id TEXT PRIMARY KEY,
  session_token TEXT UNIQUE NOT NULL,
  user_id TEXT NOT NULL,
  expires TIMESTAMP NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE users (
  id TEXT PRIMARY KEY,
  name TEXT,
  email TEXT UNIQUE,
  email_verified TIMESTAMP,
  image TEXT,
  tenant_id TEXT,
  role TEXT DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE verification_tokens (
  identifier TEXT NOT NULL,
  token TEXT UNIQUE NOT NULL,
  expires TIMESTAMP NOT NULL
);

-- Multi-tenant support
CREATE TABLE tenants (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  domain TEXT UNIQUE,
  settings JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Role-based permissions
CREATE TABLE roles (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  tenant_id TEXT,
  permissions JSONB,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);
```

## 3. IMPLEMENTATION

### 3.1. Cài đặt Dependencies

```bash
# Core NextAuth.js
npm install next-auth

# Database adapter
npm install @next-auth/prisma-adapter

# Additional providers
npm install @auth/google-provider
npm install @auth/github-provider

# Utilities
npm install bcryptjs
npm install jsonwebtoken
```

### 3.2. Environment Variables

```bash
# NextAuth.js Configuration
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-super-secret-key-here

# OAuth Providers
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GITHUB_CLIENT_ID=your-github-client-id
GITHUB_CLIENT_SECRET=your-github-client-secret

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/nextflow_crm
```

### 3.3. NextAuth Configuration

```javascript
// pages/api/auth/[...nextauth].js
import NextAuth from 'next-auth'
import GoogleProvider from 'next-auth/providers/google'
import GitHubProvider from 'next-auth/providers/github'
import CredentialsProvider from 'next-auth/providers/credentials'
import { PrismaAdapter } from "@next-auth/prisma-adapter"
import { prisma } from "../../../lib/prisma"
import bcrypt from 'bcryptjs'

export default NextAuth({
  adapter: PrismaAdapter(prisma),
  
  providers: [
    // OAuth Providers
    GoogleProvider({
      clientId: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    }),
    
    GitHubProvider({
      clientId: process.env.GITHUB_CLIENT_ID,
      clientSecret: process.env.GITHUB_CLIENT_SECRET,
    }),
    
    // Email/Password Provider
    CredentialsProvider({
      name: "credentials",
      credentials: {
        email: { label: "Email", type: "email" },
        password: { label: "Password", type: "password" }
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) {
          return null
        }

        const user = await prisma.user.findUnique({
          where: { email: credentials.email },
          include: { tenant: true }
        })

        if (!user || !user.password) {
          return null
        }

        const isPasswordValid = await bcrypt.compare(
          credentials.password,
          user.password
        )

        if (!isPasswordValid) {
          return null
        }

        return {
          id: user.id,
          email: user.email,
          name: user.name,
          tenantId: user.tenantId,
          role: user.role,
        }
      }
    })
  ],

  session: {
    strategy: "jwt",
    maxAge: 30 * 24 * 60 * 60, // 30 days
  },

  callbacks: {
    async jwt({ token, user, account }) {
      if (user) {
        token.tenantId = user.tenantId
        token.role = user.role
      }
      return token
    },

    async session({ session, token }) {
      session.user.id = token.sub
      session.user.tenantId = token.tenantId
      session.user.role = token.role
      return session
    },

    async signIn({ user, account, profile }) {
      // Multi-tenant logic
      if (account?.provider === "google" || account?.provider === "github") {
        const existingUser = await prisma.user.findUnique({
          where: { email: user.email }
        })

        if (!existingUser) {
          // Auto-assign tenant based on email domain
          const emailDomain = user.email.split('@')[1]
          let tenant = await prisma.tenant.findUnique({
            where: { domain: emailDomain }
          })

          if (!tenant) {
            // Create new tenant for new domain
            tenant = await prisma.tenant.create({
              data: {
                name: emailDomain,
                domain: emailDomain,
                settings: {}
              }
            })
          }

          // Update user with tenant
          await prisma.user.update({
            where: { email: user.email },
            data: { tenantId: tenant.id }
          })
        }
      }

      return true
    }
  },

  pages: {
    signIn: '/auth/signin',
    signUp: '/auth/signup',
    error: '/auth/error',
  },

  events: {
    async signIn({ user, account, profile }) {
      console.log(`User ${user.email} signed in with ${account.provider}`)
    },
    async signOut({ session }) {
      console.log(`User ${session.user.email} signed out`)
    }
  }
})
```

### 3.4. Middleware cho API Protection

```javascript
// middleware.js
import { withAuth } from "next-auth/middleware"

export default withAuth(
  function middleware(req) {
    // Additional middleware logic
    const token = req.nextauth.token
    const { pathname } = req.nextUrl

    // Admin routes protection
    if (pathname.startsWith('/admin') && token?.role !== 'admin') {
      return new Response('Unauthorized', { status: 401 })
    }

    // Tenant isolation
    if (pathname.startsWith('/api/') && !pathname.startsWith('/api/auth/')) {
      req.headers.set('x-tenant-id', token?.tenantId || '')
    }
  },
  {
    callbacks: {
      authorized: ({ token, req }) => {
        const { pathname } = req.nextUrl
        
        // Public routes
        if (pathname.startsWith('/auth/') || pathname === '/') {
          return true
        }
        
        // Protected routes require token
        return !!token
      },
    },
  }
)

export const config = {
  matcher: [
    '/dashboard/:path*',
    '/api/:path*',
    '/admin/:path*'
  ]
}
```

## 4. MULTI-TENANT SUPPORT

### 4.1. Tenant Context Provider

```typescript
// contexts/TenantContext.tsx
import { createContext, useContext, ReactNode } from 'react'
import { useSession } from 'next-auth/react'

interface TenantContextType {
  tenantId: string | null
  tenantName: string | null
  isLoading: boolean
}

const TenantContext = createContext<TenantContextType | undefined>(undefined)

export function TenantProvider({ children }: { children: ReactNode }) {
  const { data: session, status } = useSession()
  
  const value = {
    tenantId: session?.user?.tenantId || null,
    tenantName: session?.user?.tenant?.name || null,
    isLoading: status === 'loading'
  }

  return (
    <TenantContext.Provider value={value}>
      {children}
    </TenantContext.Provider>
  )
}

export function useTenant() {
  const context = useContext(TenantContext)
  if (context === undefined) {
    throw new Error('useTenant must be used within a TenantProvider')
  }
  return context
}
```

### 4.2. API Route với Tenant Isolation

```typescript
// pages/api/customers/index.ts
import { NextApiRequest, NextApiResponse } from 'next'
import { getServerSession } from 'next-auth/next'
import { authOptions } from '../auth/[...nextauth]'
import { prisma } from '../../../lib/prisma'

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  const session = await getServerSession(req, res, authOptions)
  
  if (!session) {
    return res.status(401).json({ error: 'Unauthorized' })
  }

  const tenantId = session.user.tenantId

  switch (req.method) {
    case 'GET':
      const customers = await prisma.customer.findMany({
        where: { tenantId },
        orderBy: { createdAt: 'desc' }
      })
      return res.json(customers)

    case 'POST':
      const customer = await prisma.customer.create({
        data: {
          ...req.body,
          tenantId
        }
      })
      return res.json(customer)

    default:
      res.setHeader('Allow', ['GET', 'POST'])
      return res.status(405).end(`Method ${req.method} Not Allowed`)
  }
}
```

## 5. ROLE-BASED ACCESS CONTROL

### 5.1. Permission System

```typescript
// lib/permissions.ts
export const PERMISSIONS = {
  CUSTOMER_READ: 'customer:read',
  CUSTOMER_WRITE: 'customer:write',
  CUSTOMER_DELETE: 'customer:delete',
  PRODUCT_READ: 'product:read',
  PRODUCT_WRITE: 'product:write',
  ADMIN_ACCESS: 'admin:access',
} as const

export const ROLES = {
  ADMIN: {
    name: 'admin',
    permissions: Object.values(PERMISSIONS)
  },
  MANAGER: {
    name: 'manager',
    permissions: [
      PERMISSIONS.CUSTOMER_READ,
      PERMISSIONS.CUSTOMER_WRITE,
      PERMISSIONS.PRODUCT_READ,
      PERMISSIONS.PRODUCT_WRITE,
    ]
  },
  USER: {
    name: 'user',
    permissions: [
      PERMISSIONS.CUSTOMER_READ,
      PERMISSIONS.PRODUCT_READ,
    ]
  }
} as const

export function hasPermission(userRole: string, permission: string): boolean {
  const role = Object.values(ROLES).find(r => r.name === userRole)
  return role?.permissions.includes(permission) || false
}
```

### 5.2. Permission Hook

```typescript
// hooks/usePermissions.ts
import { useSession } from 'next-auth/react'
import { hasPermission } from '../lib/permissions'

export function usePermissions() {
  const { data: session } = useSession()
  
  const checkPermission = (permission: string): boolean => {
    if (!session?.user?.role) return false
    return hasPermission(session.user.role, permission)
  }

  return {
    hasPermission: checkPermission,
    role: session?.user?.role,
    isAdmin: session?.user?.role === 'admin'
  }
}
```

## 6. TESTING VÀ DEPLOYMENT

### 6.1. Testing Authentication

```typescript
// __tests__/auth.test.ts
import { render, screen } from '@testing-library/react'
import { SessionProvider } from 'next-auth/react'
import { useSession } from 'next-auth/react'

// Mock session
const mockSession = {
  user: {
    id: '1',
    email: 'test@example.com',
    tenantId: 'tenant-1',
    role: 'admin'
  },
  expires: '2024-12-31'
}

describe('Authentication', () => {
  it('should protect admin routes', () => {
    // Test implementation
  })

  it('should isolate tenant data', () => {
    // Test implementation
  })
})
```

### 6.2. Production Deployment

```bash
# Build và deploy
npm run build
npm run start

# Environment variables for production
NEXTAUTH_URL=https://yourcrm.com
NEXTAUTH_SECRET=your-production-secret
```

## 7. MIGRATION TỪ KEYCLOAK

### 7.1. Data Migration Script

```typescript
// scripts/migrate-from-keycloak.ts
import { prisma } from '../lib/prisma'
import bcrypt from 'bcryptjs'

async function migrateUsers() {
  // Đọc dữ liệu từ Keycloak export
  const keycloakUsers = await readKeycloakExport()
  
  for (const kcUser of keycloakUsers) {
    const hashedPassword = await bcrypt.hash(kcUser.password, 12)
    
    await prisma.user.create({
      data: {
        id: kcUser.id,
        email: kcUser.email,
        name: kcUser.firstName + ' ' + kcUser.lastName,
        password: hashedPassword,
        tenantId: kcUser.tenantId,
        role: kcUser.role,
        emailVerified: kcUser.emailVerified ? new Date() : null
      }
    })
  }
}
```

## 8. KẾT LUẬN

NextAuth.js cung cấp giải pháp authentication hoàn chỉnh, nhẹ và dễ maintain cho NextFlow CRM. Với chi phí thấp và tích hợp tốt với Next.js, đây là lựa chọn tối ưu cho startup.

### Lợi ích chính:
- 💰 Tiết kiệm chi phí (từ $100/tháng xuống $0)
- 🚀 Dễ triển khai và maintain
- 🔒 Bảo mật tốt với JWT và session management
- 🏢 Hỗ trợ multi-tenant đầy đủ
- 📱 Tương thích với mobile app
