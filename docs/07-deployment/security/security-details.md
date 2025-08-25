# BẢO MẬT HỆ THỐNG - PHẦN 1

## 1. GIỚI THIỆU

Tài liệu này mô tả chi tiết về chiến lược và triển khai bảo mật cho hệ thống NextFlow CRM-AI. Bảo mật là một trong những yếu tố quan trọng nhất của hệ thống, đặc biệt là đối với một hệ thống multi-tenant xử lý dữ liệu nhạy cảm của nhiều khách hàng.

### 1.1. Mục đích

- Cung cấp tổng quan về chiến lược bảo mật của NextFlow CRM-AI
- Mô tả các biện pháp bảo mật được triển khai
- Hướng dẫn các best practices về bảo mật
- Xác định quy trình phát hiện và xử lý sự cố bảo mật
- Đảm bảo tuân thủ các quy định và tiêu chuẩn bảo mật

### 1.2. Phạm vi

Tài liệu này áp dụng cho tất cả các thành phần của hệ thống NextFlow CRM-AI, bao gồm:

- Backend services (NestJS)
- Frontend applications (Next.js, React Native)
- Database (PostgreSQL)
- Infrastructure (Kubernetes, Docker)
- Third-party integrations (n8n, Flowise, Marketplace APIs)
- DevOps processes

## 2. CHIẾN LƯỢC BẢO MẬT

### 2.1. Nguyên tắc bảo mật

NextFlow CRM-AI tuân theo các nguyên tắc bảo mật sau:

1. **Defense in Depth**: Triển khai nhiều lớp bảo mật để bảo vệ hệ thống
2. **Least Privilege**: Cấp quyền tối thiểu cần thiết cho người dùng và services
3. **Secure by Default**: Thiết kế hệ thống an toàn mặc định, không cần cấu hình thêm
4. **Privacy by Design**: Tích hợp quyền riêng tư vào thiết kế hệ thống
5. **Zero Trust**: Không tin tưởng bất kỳ người dùng hoặc service nào mà không xác thực
6. **Continuous Monitoring**: Giám sát liên tục để phát hiện các hoạt động bất thường
7. **Regular Updates**: Cập nhật thường xuyên để vá các lỗ hổng bảo mật

### 2.2. Mô hình bảo mật

NextFlow CRM-AI sử dụng mô hình bảo mật nhiều lớp:

```
+------------------+
|                  |
|  Perimeter       |
|  Security        |
|                  |
+------------------+
|                  |
|  Network         |
|  Security        |
|                  |
+------------------+
|                  |
|  Infrastructure  |
|  Security        |
|                  |
+------------------+
|                  |
|  Application     |
|  Security        |
|                  |
+------------------+
|                  |
|  Data            |
|  Security        |
|                  |
+------------------+
```

#### 2.2.1. Perimeter Security

- Firewall
- DDoS protection
- Web Application Firewall (WAF)
- API Gateway

#### 2.2.2. Network Security

- Network segmentation
- VPN
- Encryption in transit (TLS)
- Network monitoring

#### 2.2.3. Infrastructure Security

- Container security
- Host security
- Kubernetes security
- Cloud security

#### 2.2.4. Application Security

- Authentication
- Authorization
- Input validation
- Output encoding
- CSRF protection
- XSS protection
- SQL injection protection

#### 2.2.5. Data Security

- Encryption at rest
- Data masking
- Access control
- Audit logging
- Backup and recovery

## 3. AUTHENTICATION VÀ AUTHORIZATION

### 3.1. Authentication

NextFlow CRM-AI sử dụng nhiều phương pháp xác thực để đảm bảo chỉ người dùng hợp lệ mới có thể truy cập hệ thống.

#### 3.1.1. JWT Authentication

JSON Web Tokens (JWT) được sử dụng để xác thực API requests:

```typescript
// auth.module.ts
import { Module } from "@nestjs/common";
import { JwtModule } from "@nestjs/jwt";
import { PassportModule } from "@nestjs/passport";
import { AuthService } from "./auth.service";
import { JwtStrategy } from "./jwt.strategy";

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: "jwt" }),
    JwtModule.register({
      secret: process.env.JWT_SECRET,
      signOptions: { expiresIn: "1h" },
    }),
  ],
  providers: [AuthService, JwtStrategy],
  exports: [AuthService],
})
export class AuthModule {}

// jwt.strategy.ts
import { Injectable, UnauthorizedException } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import { ExtractJwt, Strategy } from "passport-jwt";
import { UserService } from "../user/user.service";

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private userService: UserService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: process.env.JWT_SECRET,
    });
  }

  async validate(payload: any) {
    const user = await this.userService.findById(payload.sub);
    if (!user) {
      throw new UnauthorizedException();
    }
    return user;
  }
}
```

#### 3.1.2. OAuth2 / OpenID Connect

OAuth2 và OpenID Connect được sử dụng cho Single Sign-On (SSO) và xác thực với các dịch vụ bên thứ ba:

```typescript
// oauth.module.ts
import { Module } from "@nestjs/common";
import { PassportModule } from "@nestjs/passport";
import { GoogleStrategy } from "./google.strategy";
import { MicrosoftStrategy } from "./microsoft.strategy";
import { OAuthController } from "./oauth.controller";
import { OAuthService } from "./oauth.service";

@Module({
  imports: [PassportModule],
  controllers: [OAuthController],
  providers: [OAuthService, GoogleStrategy, MicrosoftStrategy],
})
export class OAuthModule {}

// google.strategy.ts
import { Injectable } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import { Strategy, VerifyCallback } from "passport-google-oauth20";
import { OAuthService } from "./oauth.service";

@Injectable()
export class GoogleStrategy extends PassportStrategy(Strategy, "google") {
  constructor(private oauthService: OAuthService) {
    super({
      clientID: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL: process.env.GOOGLE_CALLBACK_URL,
      scope: ["email", "profile"],
    });
  }

  async validate(accessToken: string, refreshToken: string, profile: any, done: VerifyCallback) {
    const user = await this.oauthService.validateOAuthUser({
      provider: "google",
      providerId: profile.id,
      email: profile.emails[0].value,
      name: profile.displayName,
    });
    done(null, user);
  }
}
```

#### 3.1.3. Multi-factor Authentication (MFA)

MFA được triển khai để tăng cường bảo mật:

```typescript
// mfa.service.ts
import { Injectable } from "@nestjs/common";
import * as speakeasy from "speakeasy";
import * as QRCode from "qrcode";
import { UserService } from "../user/user.service";

@Injectable()
export class MfaService {
  constructor(private userService: UserService) {}

  async generateSecret(userId: string) {
    const secret = speakeasy.generateSecret({
      name: `NextFlow CRM-AI (${userId})`,
    });

    await this.userService.updateMfaSecret(userId, secret.base32);

    const qrCodeUrl = await QRCode.toDataURL(secret.otpauth_url);

    return {
      secret: secret.base32,
      qrCodeUrl,
    };
  }

  async verifyToken(userId: string, token: string) {
    const user = await this.userService.findById(userId);

    return speakeasy.totp.verify({
      secret: user.mfaSecret,
      encoding: "base32",
      token,
    });
  }
}
```

#### 3.1.4. API Keys

API Keys được sử dụng cho machine-to-machine authentication:

```typescript
// api-key.guard.ts
import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from "@nestjs/common";
import { ApiKeyService } from "./api-key.service";

@Injectable()
export class ApiKeyGuard implements CanActivate {
  constructor(private apiKeyService: ApiKeyService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const apiKey = request.headers["x-api-key"];

    if (!apiKey) {
      throw new UnauthorizedException("API key is missing");
    }

    const isValid = await this.apiKeyService.validateApiKey(apiKey);

    if (!isValid) {
      throw new UnauthorizedException("Invalid API key");
    }

    return true;
  }
}
```

### 3.2. Authorization

NextFlow CRM-AI sử dụng CASL để triển khai hệ thống phân quyền linh hoạt và mạnh mẽ.

#### 3.2.1. Role-Based Access Control (RBAC)

```typescript
// roles.enum.ts
export enum Role {
  SUPER_ADMIN = "super_admin",
  ADMIN = "admin",
  MANAGER = "manager",
  USER = "user",
  GUEST = "guest",
}

// roles.decorator.ts
import { SetMetadata } from "@nestjs/common";
import { Role } from "./roles.enum";

export const ROLES_KEY = "roles";
export const Roles = (...roles: Role[]) => SetMetadata(ROLES_KEY, roles);

// roles.guard.ts
import { Injectable, CanActivate, ExecutionContext } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { Role } from "./roles.enum";
import { ROLES_KEY } from "./roles.decorator";

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (!requiredRoles) {
      return true;
    }

    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.some((role) => user.roles?.includes(role));
  }
}
```

#### 3.2.2. Attribute-Based Access Control (ABAC) với CASL

```typescript
// casl.module.ts
import { Module } from "@nestjs/common";
import { CaslAbilityFactory } from "./casl-ability.factory";

@Module({
  providers: [CaslAbilityFactory],
  exports: [CaslAbilityFactory],
})
export class CaslModule {}

// casl-ability.factory.ts
import { Injectable } from "@nestjs/common";
import { Ability, AbilityBuilder, AbilityClass, ExtractSubjectType, InferSubjects } from "@casl/ability";
import { User } from "../user/user.entity";
import { Customer } from "../customer/customer.entity";
import { Product } from "../product/product.entity";
import { Order } from "../order/order.entity";

export enum Action {
  Manage = "manage",
  Create = "create",
  Read = "read",
  Update = "update",
  Delete = "delete",
}

export type Subjects = InferSubjects<typeof User | typeof Customer | typeof Product | typeof Order> | "all";

export type AppAbility = Ability<[Action, Subjects]>;

@Injectable()
export class CaslAbilityFactory {
  createForUser(user: User) {
    const { can, cannot, build } = new AbilityBuilder<AppAbility>(Ability as AbilityClass<AppAbility>);

    if (user.roles.includes("super_admin")) {
      can(Action.Manage, "all");
    } else if (user.roles.includes("admin")) {
      can(Action.Manage, "all");
      cannot(Action.Delete, User);
    } else if (user.roles.includes("manager")) {
      can(Action.Read, "all");
      can(Action.Create, [Customer, Product, Order]);
      can(Action.Update, [Customer, Product, Order]);
      cannot(Action.Delete, "all");
    } else {
      can(Action.Read, [Customer, Product, Order]);
      can(Action.Create, Order);
      can(Action.Update, Order, { createdBy: user.id });
    }

    // Tenant isolation
    if (!user.roles.includes("super_admin")) {
      cannot(Action.Manage, "all", { tenantId: { $ne: user.tenantId } });
    }

    return build({
      detectSubjectType: (item) => item.constructor as ExtractSubjectType<Subjects>,
    });
  }
}
```

#### 3.2.3. Policy-Based Access Control

```typescript
// policies.guard.ts
import { Injectable, CanActivate, ExecutionContext } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { CaslAbilityFactory } from "./casl-ability.factory";
import { CHECK_POLICIES_KEY } from "./policies.decorator";
import { PolicyHandler } from "./policy-handler.interface";

@Injectable()
export class PoliciesGuard implements CanActivate {
  constructor(private reflector: Reflector, private caslAbilityFactory: CaslAbilityFactory) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const policyHandlers = this.reflector.get<PolicyHandler[]>(CHECK_POLICIES_KEY, context.getHandler()) || [];

    const { user } = context.switchToHttp().getRequest();
    const ability = this.caslAbilityFactory.createForUser(user);

    return policyHandlers.every((handler) => this.execPolicyHandler(handler, ability));
  }

  private execPolicyHandler(handler: PolicyHandler, ability: AppAbility) {
    if (typeof handler === "function") {
      return handler(ability);
    }
    return handler.handle(ability);
  }
}

// policies.decorator.ts
import { SetMetadata } from "@nestjs/common";
import { PolicyHandler } from "./policy-handler.interface";

export const CHECK_POLICIES_KEY = "check_policy";
export const CheckPolicies = (...handlers: PolicyHandler[]) => SetMetadata(CHECK_POLICIES_KEY, handlers);
```

## 4. BẢO MẬT ỨNG DỤNG

### 4.1. Input Validation

NextFlow CRM-AI sử dụng class-validator để xác thực input từ người dùng:

```typescript
// create-user.dto.ts
import { IsEmail, IsNotEmpty, IsString, MinLength, Matches } from "class-validator";

export class CreateUserDto {
  @IsNotEmpty()
  @IsString()
  name: string;

  @IsNotEmpty()
  @IsEmail()
  email: string;

  @IsNotEmpty()
  @IsString()
  @MinLength(8)
  @Matches(/((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$/, {
    message: "Password too weak",
  })
  password: string;
}

// validation.pipe.ts
import { PipeTransform, Injectable, ArgumentMetadata, BadRequestException } from "@nestjs/common";
import { validate } from "class-validator";
import { plainToClass } from "class-transformer";

@Injectable()
export class ValidationPipe implements PipeTransform<any> {
  async transform(value: any, { metatype }: ArgumentMetadata) {
    if (!metatype || !this.toValidate(metatype)) {
      return value;
    }
    const object = plainToClass(metatype, value);
    const errors = await validate(object);
    if (errors.length > 0) {
      throw new BadRequestException("Validation failed");
    }
    return value;
  }

  private toValidate(metatype: Function): boolean {
    const types: Function[] = [String, Boolean, Number, Array, Object];
    return !types.includes(metatype);
  }
}
```

### 4.2. XSS Protection

NextFlow CRM-AI sử dụng các biện pháp sau để ngăn chặn XSS:

#### 4.2.1. Content Security Policy (CSP)

```typescript
// main.ts
import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";
import * as helmet from "helmet";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.use(
    helmet.contentSecurityPolicy({
      directives: {
        defaultSrc: ["'self'"],
        scriptSrc: ["'self'", "'unsafe-inline'", "https://cdn.jsdelivr.net"],
        styleSrc: ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"],
        imgSrc: ["'self'", "data:", "https://storage.NextFlow.com"],
        connectSrc: ["'self'", "https://api.NextFlow.com"],
        fontSrc: ["'self'", "https://fonts.gstatic.com"],
        objectSrc: ["'none'"],
        mediaSrc: ["'self'"],
        frameSrc: ["'none'"],
      },
    })
  );

  await app.listen(3000);
}
bootstrap();
```

#### 4.2.2. Output Encoding

```typescript
// sanitize.pipe.ts
import { PipeTransform, Injectable, ArgumentMetadata } from "@nestjs/common";
import * as sanitizeHtml from "sanitize-html";

@Injectable()
export class SanitizePipe implements PipeTransform {
  transform(value: any, metadata: ArgumentMetadata) {
    if (typeof value !== "string") {
      return value;
    }

    return sanitizeHtml(value, {
      allowedTags: ["b", "i", "em", "strong", "a", "p", "br"],
      allowedAttributes: {
        a: ["href", "target"],
      },
    });
  }
}
```

### 4.3. CSRF Protection

```typescript
// main.ts
import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";
import * as cookieParser from "cookie-parser";
import * as csurf from "csurf";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.use(cookieParser());
  app.use(csurf({ cookie: true }));

  app.use((req, res, next) => {
    res.cookie("XSRF-TOKEN", req.csrfToken());
    next();
  });

  await app.listen(3000);
}
bootstrap();
```

### 4.4. SQL Injection Protection

NextFlow CRM-AI sử dụng TypeORM với prepared statements để ngăn chặn SQL injection:

```typescript
// user.repository.ts
import { EntityRepository, Repository } from "typeorm";
import { User } from "./user.entity";

@EntityRepository(User)
export class UserRepository extends Repository<User> {
  async findByEmail(email: string): Promise<User> {
    // Safe: Using query builder with parameters
    return this.createQueryBuilder("user").where("user.email = :email", { email }).getOne();

    // Unsafe: Don't do this!
    // return this.query(`SELECT * FROM user WHERE email = '${email}'`);
  }
}
```
