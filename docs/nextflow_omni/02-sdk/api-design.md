# Thiết kế API Nextflow Zalo SDK

## 🏗️ Kiến trúc API tổng thể

### **Thiết kế Giao diện Thống nhất**
```typescript
// Class SDK chính - Giao diện thống nhất cho cả Cá nhân và OA
class NextflowZaloSDK {
    personal: ZaloPersonalClient; // Client Zalo cá nhân
    official: ZaloOfficialClient; // Client Zalo OA
    nextflow: NextflowIntegration; // Tích hợp Nextflow

    constructor(config: SDKConfig) {
        this.personal = new ZaloPersonalClient(config.personal);
        this.official = new ZaloOfficialClient(config.official);
        this.nextflow = new NextflowIntegration(config.nextflow);
    }
}

// Ví dụ sử dụng
const zaloSDK = new NextflowZaloSDK({
    personal: {
        credentials: personalCredentials, // Thông tin đăng nhập cá nhân
        rateLimits: { messages: 100, interval: 60000 } // Giới hạn tốc độ
    },
    official: {
        appId: "your-oa-app-id", // ID ứng dụng OA
        appSecret: "your-oa-secret", // Mã bí mật OA
        accessToken: "your-access-token" // Token truy cập
    },
    nextflow: {
        apiKey: "nextflow-api-key", // Khóa API Nextflow
        endpoint: "https://api.nextflow.com" // Điểm kết nối Nextflow
    }
});
```

## 📱 Thiết kế API Zalo Cá nhân

### **Xác thực & Kết nối**
```typescript
interface PersonalAuthConfig {
    credentials?: ZCACredentials; // Thông tin đăng nhập
    qrLogin?: { // Đăng nhập mã QR
        qrPath?: string; // Đường dẫn lưu mã QR
        userAgent?: string; // Chuỗi user agent
        language?: string; // Ngôn ngữ
    };
    rateLimits?: RateLimitConfig; // Cấu hình giới hạn tốc độ
}

class ZaloPersonalClient {
    async login(config: PersonalAuthConfig): Promise<PersonalSession>;
    async loginQR(options?: QRLoginOptions): Promise<PersonalSession>;
    async logout(): Promise<void>;
    async getSession(): Promise<PersonalSession>;
    async refreshSession(): Promise<PersonalSession>;
}
```

### **Messaging API**
```typescript
interface PersonalMessaging {
    // Gửi tin nhắn
    sendText(threadId: string, text: string, options?: MessageOptions): Promise<MessageResult>;
    sendSticker(threadId: string, stickerId: string): Promise<MessageResult>;
    sendImage(threadId: string, image: ImageData): Promise<MessageResult>;
    sendVideo(threadId: string, video: VideoData): Promise<MessageResult>;
    sendVoice(threadId: string, voice: VoiceData): Promise<MessageResult>;
    sendFile(threadId: string, file: FileData): Promise<MessageResult>;
    
    // Reply và forward
    replyMessage(messageId: string, content: MessageContent): Promise<MessageResult>;
    forwardMessage(messageId: string, targetThreadIds: string[]): Promise<MessageResult[]>;
    
    // Quản lý tin nhắn
    deleteMessage(messageId: string): Promise<boolean>;
    editMessage(messageId: string, newContent: string): Promise<MessageResult>;
    addReaction(messageId: string, reaction: string): Promise<boolean>;
    removeReaction(messageId: string): Promise<boolean>;
    
    // Lắng nghe events
    onMessage(callback: (message: PersonalMessage) => void): void;
    onTyping(callback: (typing: TypingEvent) => void): void;
    onSeen(callback: (seen: SeenEvent) => void): void;
    onReaction(callback: (reaction: ReactionEvent) => void): void;
}
```

### **Contacts & Friends API**
```typescript
interface PersonalContacts {
    // Quản lý bạn bè
    getAllFriends(): Promise<Friend[]>;
    getFriend(userId: string): Promise<Friend>;
    sendFriendRequest(userId: string, message?: string): Promise<boolean>;
    acceptFriendRequest(userId: string): Promise<boolean>;
    rejectFriendRequest(userId: string): Promise<boolean>;
    removeFriend(userId: string): Promise<boolean>;
    
    // Block/Unblock
    blockUser(userId: string): Promise<boolean>;
    unblockUser(userId: string): Promise<boolean>;
    getBlockedUsers(): Promise<User[]>;
    
    // Alias và tags
    setFriendAlias(userId: string, alias: string): Promise<boolean>;
    removeFriendAlias(userId: string): Promise<boolean>;
    getFriendAlias(userId: string): Promise<string>;
    
    // Tìm kiếm
    searchUsers(query: string): Promise<User[]>;
    findUserByPhone(phone: string): Promise<User>;
}
```

### **Groups API**
```typescript
interface PersonalGroups {
    // Quản lý nhóm
    getAllGroups(): Promise<Group[]>;
    getGroup(groupId: string): Promise<Group>;
    createGroup(name: string, memberIds: string[]): Promise<Group>;
    leaveGroup(groupId: string): Promise<boolean>;
    deleteGroup(groupId: string): Promise<boolean>;
    
    // Thành viên
    getGroupMembers(groupId: string): Promise<GroupMember[]>;
    addMembers(groupId: string, userIds: string[]): Promise<AddMemberResult>;
    removeMembers(groupId: string, userIds: string[]): Promise<RemoveMemberResult>;
    promoteToAdmin(groupId: string, userId: string): Promise<boolean>;
    demoteFromAdmin(groupId: string, userId: string): Promise<boolean>;
    
    // Cài đặt nhóm
    updateGroupName(groupId: string, name: string): Promise<boolean>;
    updateGroupAvatar(groupId: string, avatar: ImageData): Promise<boolean>;
    updateGroupSettings(groupId: string, settings: GroupSettings): Promise<boolean>;
    
    // Link mời
    createInviteLink(groupId: string): Promise<string>;
    disableInviteLink(groupId: string): Promise<boolean>;
    joinByLink(inviteLink: string): Promise<boolean>;
}
```

## 🏢 Zalo Official Account API Design

### **Authentication & Setup**
```typescript
interface OAAuthConfig {
    appId: string;
    appSecret: string;
    accessToken?: string;
    refreshToken?: string;
    webhookUrl?: string;
    webhookSecret?: string;
}

class ZaloOfficialClient {
    async authenticate(config: OAAuthConfig): Promise<OASession>;
    async refreshAccessToken(): Promise<string>;
    async setupWebhook(url: string, events: WebhookEvent[]): Promise<boolean>;
    async verifyWebhook(signature: string, body: string): boolean;
}
```

### **OA Messaging API**
```typescript
interface OAMessaging {
    // Template messages
    sendTextMessage(userId: string, text: string): Promise<MessageResult>;
    sendTemplateMessage(userId: string, template: MessageTemplate): Promise<MessageResult>;
    sendListMessage(userId: string, elements: ListElement[]): Promise<MessageResult>;
    sendCarouselMessage(userId: string, cards: CarouselCard[]): Promise<MessageResult>;
    sendButtonMessage(userId: string, text: string, buttons: Button[]): Promise<MessageResult>;
    
    // Rich media
    sendImageMessage(userId: string, imageUrl: string): Promise<MessageResult>;
    sendVideoMessage(userId: string, videoUrl: string): Promise<MessageResult>;
    sendFileMessage(userId: string, fileUrl: string): Promise<MessageResult>;
    
    // Broadcast messages
    broadcastMessage(userIds: string[], content: MessageContent): Promise<BroadcastResult>;
    broadcastToSegment(segmentId: string, content: MessageContent): Promise<BroadcastResult>;
    broadcastToAll(content: MessageContent): Promise<BroadcastResult>;
    
    // Message status
    getMessageStatus(messageId: string): Promise<MessageStatus>;
    getDeliveryReport(messageId: string): Promise<DeliveryReport>;
}
```

### **OA User Management**
```typescript
interface OAUserManagement {
    // User profile
    getUserProfile(userId: string): Promise<OAUserProfile>;
    updateUserProfile(userId: string, profile: Partial<OAUserProfile>): Promise<boolean>;
    
    // Tags và segments
    addUserTags(userId: string, tags: string[]): Promise<boolean>;
    removeUserTags(userId: string, tags: string[]): Promise<boolean>;
    getUserTags(userId: string): Promise<string[]>;
    
    // Segments
    createSegment(name: string, criteria: SegmentCriteria): Promise<Segment>;
    updateSegment(segmentId: string, criteria: SegmentCriteria): Promise<boolean>;
    deleteSegment(segmentId: string): Promise<boolean>;
    getSegmentUsers(segmentId: string): Promise<string[]>;
    
    // Followers
    getFollowers(offset?: number, limit?: number): Promise<FollowerList>;
    getFollowerInfo(userId: string): Promise<FollowerInfo>;
}
```

### **OA Analytics API**
```typescript
interface OAAnalytics {
    // Message analytics
    getMessageStats(startDate: Date, endDate: Date): Promise<MessageStats>;
    getEngagementStats(startDate: Date, endDate: Date): Promise<EngagementStats>;
    getUserGrowthStats(startDate: Date, endDate: Date): Promise<GrowthStats>;
    
    // Real-time metrics
    getRealTimeStats(): Promise<RealTimeStats>;
    getActiveUsers(period: 'day' | 'week' | 'month'): Promise<number>;
    
    // Custom reports
    generateReport(config: ReportConfig): Promise<Report>;
    scheduleReport(config: ReportConfig, schedule: CronSchedule): Promise<string>;
}
```

## 🔗 Nextflow Integration API

### **CRM Sync**
```typescript
interface NextflowCRMSync {
    // Contact synchronization
    syncContacts(source: 'personal' | 'oa'): Promise<SyncResult>;
    syncContact(contactId: string, source: 'personal' | 'oa'): Promise<Contact>;
    
    // Conversation history
    syncConversations(threadId: string, source: 'personal' | 'oa'): Promise<Conversation[]>;
    syncConversation(conversationId: string): Promise<Conversation>;
    
    // Real-time sync
    enableRealTimeSync(config: RealTimeSyncConfig): Promise<boolean>;
    disableRealTimeSync(): Promise<boolean>;
    
    // Mapping và deduplication
    mapZaloToNextflow(zaloId: string, nextflowId: string): Promise<boolean>;
    deduplicateContacts(): Promise<DeduplicationResult>;
}
```

### **AI Integration**
```typescript
interface NextflowAI {
    // Chatbot
    createChatbot(config: ChatbotConfig): Promise<Chatbot>;
    updateChatbot(botId: string, config: Partial<ChatbotConfig>): Promise<boolean>;
    deleteChatbot(botId: string): Promise<boolean>;
    
    // Natural Language Processing
    analyzeMessage(message: string): Promise<MessageAnalysis>;
    detectIntent(message: string): Promise<Intent>;
    extractEntities(message: string): Promise<Entity[]>;
    
    // Sentiment analysis
    analyzeSentiment(message: string): Promise<SentimentResult>;
    getConversationSentiment(conversationId: string): Promise<SentimentTrend>;
    
    // Auto-response
    generateResponse(context: ConversationContext): Promise<string>;
    trainModel(trainingData: TrainingData[]): Promise<ModelResult>;
}
```

### **Workflow Automation**
```typescript
interface NextflowWorkflow {
    // Workflow management
    createWorkflow(config: WorkflowConfig): Promise<Workflow>;
    updateWorkflow(workflowId: string, config: Partial<WorkflowConfig>): Promise<boolean>;
    deleteWorkflow(workflowId: string): Promise<boolean>;
    
    // Triggers
    addTrigger(workflowId: string, trigger: WorkflowTrigger): Promise<string>;
    removeTrigger(triggerId: string): Promise<boolean>;
    
    // Actions
    addAction(workflowId: string, action: WorkflowAction): Promise<string>;
    removeAction(actionId: string): Promise<boolean>;
    
    // Execution
    executeWorkflow(workflowId: string, context: ExecutionContext): Promise<ExecutionResult>;
    getExecutionHistory(workflowId: string): Promise<ExecutionHistory[]>;
    
    // Monitoring
    getWorkflowStats(workflowId: string): Promise<WorkflowStats>;
    enableWorkflow(workflowId: string): Promise<boolean>;
    disableWorkflow(workflowId: string): Promise<boolean>;
}
```

## 🔧 Utility APIs

### **Rate Limiting & Queue**
```typescript
interface RateLimiter {
    checkLimit(key: string, limit: number, window: number): Promise<boolean>;
    getRemainingRequests(key: string): Promise<number>;
    resetLimit(key: string): Promise<boolean>;
}

interface MessageQueue {
    addMessage(message: QueuedMessage): Promise<string>;
    processQueue(): Promise<void>;
    getQueueStatus(): Promise<QueueStatus>;
    clearQueue(): Promise<boolean>;
}
```

### **Caching & Storage**
```typescript
interface CacheManager {
    set(key: string, value: any, ttl?: number): Promise<boolean>;
    get(key: string): Promise<any>;
    delete(key: string): Promise<boolean>;
    clear(): Promise<boolean>;
    exists(key: string): Promise<boolean>;
}

interface StorageManager {
    saveCredentials(credentials: any): Promise<boolean>;
    loadCredentials(): Promise<any>;
    saveConversation(conversation: Conversation): Promise<boolean>;
    loadConversations(threadId: string): Promise<Conversation[]>;
}
```

### **Logging & Monitoring**
```typescript
interface Logger {
    debug(message: string, meta?: any): void;
    info(message: string, meta?: any): void;
    warn(message: string, meta?: any): void;
    error(message: string, meta?: any): void;
    
    setLevel(level: LogLevel): void;
    addTransport(transport: LogTransport): void;
}

interface HealthMonitor {
    checkHealth(): Promise<HealthStatus>;
    getMetrics(): Promise<SystemMetrics>;
    startMonitoring(): void;
    stopMonitoring(): void;
}
```

## 📊 Event System Design

### **Event Types**
```typescript
// Personal events
type PersonalEvent = 
    | MessageEvent
    | TypingEvent
    | SeenEvent
    | ReactionEvent
    | FriendEvent
    | GroupEvent;

// OA events
type OAEvent = 
    | OAMessageEvent
    | FollowEvent
    | UnfollowEvent
    | PostbackEvent
    | QuickReplyEvent;

// Nextflow events
type NextflowEvent = 
    | ContactSyncEvent
    | WorkflowExecutionEvent
    | AIAnalysisEvent
    | CRMUpdateEvent;
```

### **Event Handler**
```typescript
class EventHandler {
    on<T extends Event>(eventType: string, handler: (event: T) => void): void;
    off(eventType: string, handler?: Function): void;
    emit<T extends Event>(eventType: string, event: T): void;
    
    // Middleware support
    use(middleware: EventMiddleware): void;
    
    // Error handling
    onError(handler: (error: Error, event: Event) => void): void;
}
```

## 🔒 Security & Compliance

### **Authentication & Authorization**
```typescript
interface SecurityManager {
    // Encryption
    encrypt(data: any): string;
    decrypt(encryptedData: string): any;
    
    // Token management
    generateToken(payload: any): string;
    verifyToken(token: string): any;
    refreshToken(token: string): string;
    
    // API key management
    generateApiKey(): string;
    validateApiKey(apiKey: string): boolean;
    revokeApiKey(apiKey: string): boolean;
}
```

### **Compliance Features**
```typescript
interface ComplianceManager {
    // Data privacy
    anonymizeData(data: any): any;
    deleteUserData(userId: string): Promise<boolean>;
    exportUserData(userId: string): Promise<any>;
    
    // Audit logging
    logAccess(userId: string, resource: string, action: string): void;
    getAuditLog(startDate: Date, endDate: Date): Promise<AuditEntry[]>;
    
    // Consent management
    recordConsent(userId: string, consentType: string): Promise<boolean>;
    checkConsent(userId: string, consentType: string): Promise<boolean>;
    revokeConsent(userId: string, consentType: string): Promise<boolean>;
}
```