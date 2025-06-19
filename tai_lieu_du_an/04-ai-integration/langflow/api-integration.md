# TÍCH HỢP API LANGFLOW VỚI NEXTFLOW CRM

## 📋 TỔNG QUAN

Tài liệu này hướng dẫn chi tiết cách tích hợp Langflow API với hệ thống NextFlow CRM, bao gồm authentication, endpoints, và các use cases thực tế.

## 🔗 KIẾN TRÚC TÍCH HỢP

### Sơ đồ tích hợp
```
NextFlow CRM Frontend
        ↓
NextFlow CRM Backend API
        ↓
Langflow API Wrapper
        ↓
Langflow Core API
        ↓
AI Models (OpenAI, Anthropic, etc.)
```

### Luồng dữ liệu
1. **Request từ Frontend** → NextFlow Backend
2. **Authentication** → Verify JWT token
3. **API Wrapper** → Transform request format
4. **Langflow API** → Process AI workflow
5. **Response** → Transform và return về Frontend

## 🔐 AUTHENTICATION

### JWT Token Integration
```javascript
// auth.js
const jwt = require('jsonwebtoken');
const axios = require('axios');

class LangflowAuth {
    constructor(langflowUrl, secretKey) {
        this.langflowUrl = langflowUrl;
        this.secretKey = secretKey;
        this.token = null;
        this.tokenExpiry = null;
    }

    async authenticate() {
        try {
            const response = await axios.post(`${this.langflowUrl}/api/v1/auth/login`, {
                username: process.env.LANGFLOW_USERNAME,
                password: process.env.LANGFLOW_PASSWORD
            });

            this.token = response.data.access_token;
            this.tokenExpiry = new Date(Date.now() + (response.data.expires_in * 1000));
            
            return this.token;
        } catch (error) {
            throw new Error(`Langflow authentication failed: ${error.message}`);
        }
    }

    async getValidToken() {
        if (!this.token || new Date() >= this.tokenExpiry) {
            await this.authenticate();
        }
        return this.token;
    }

    getAuthHeaders() {
        return {
            'Authorization': `Bearer ${this.token}`,
            'Content-Type': 'application/json'
        };
    }
}

module.exports = LangflowAuth;
```

### API Key Management
```javascript
// apiKeyManager.js
class ApiKeyManager {
    constructor() {
        this.keys = new Map();
        this.loadApiKeys();
    }

    loadApiKeys() {
        // Load từ database hoặc environment
        this.keys.set('openai', process.env.OPENAI_API_KEY);
        this.keys.set('anthropic', process.env.ANTHROPIC_API_KEY);
        this.keys.set('google', process.env.GOOGLE_AI_API_KEY);
    }

    getKey(provider) {
        return this.keys.get(provider);
    }

    setKey(provider, key) {
        this.keys.set(provider, key);
        // Save to database
        this.saveToDatabase(provider, key);
    }

    async saveToDatabase(provider, key) {
        // Encrypt và save vào database
        const encrypted = this.encrypt(key);
        await db.query(
            'INSERT INTO api_keys (provider, encrypted_key) VALUES ($1, $2) ON CONFLICT (provider) DO UPDATE SET encrypted_key = $2',
            [provider, encrypted]
        );
    }

    encrypt(text) {
        // Implement encryption logic
        const crypto = require('crypto');
        const cipher = crypto.createCipher('aes-256-cbc', process.env.ENCRYPTION_KEY);
        let encrypted = cipher.update(text, 'utf8', 'hex');
        encrypted += cipher.final('hex');
        return encrypted;
    }
}

module.exports = ApiKeyManager;
```

## 🛠️ API WRAPPER

### Langflow API Client
```javascript
// langflowClient.js
const axios = require('axios');
const LangflowAuth = require('./auth');
const ApiKeyManager = require('./apiKeyManager');

class LangflowClient {
    constructor(baseUrl) {
        this.baseUrl = baseUrl;
        this.auth = new LangflowAuth(baseUrl, process.env.LANGFLOW_SECRET_KEY);
        this.apiKeyManager = new ApiKeyManager();
        this.client = axios.create({
            baseURL: baseUrl,
            timeout: 30000,
            headers: {
                'Content-Type': 'application/json'
            }
        });

        // Request interceptor
        this.client.interceptors.request.use(async (config) => {
            const token = await this.auth.getValidToken();
            config.headers.Authorization = `Bearer ${token}`;
            return config;
        });

        // Response interceptor
        this.client.interceptors.response.use(
            (response) => response,
            async (error) => {
                if (error.response?.status === 401) {
                    // Token expired, retry with new token
                    await this.auth.authenticate();
                    return this.client.request(error.config);
                }
                return Promise.reject(error);
            }
        );
    }

    // Flows Management
    async getFlows() {
        try {
            const response = await this.client.get('/api/v1/flows');
            return response.data;
        } catch (error) {
            throw new Error(`Failed to get flows: ${error.message}`);
        }
    }

    async getFlow(flowId) {
        try {
            const response = await this.client.get(`/api/v1/flows/${flowId}`);
            return response.data;
        } catch (error) {
            throw new Error(`Failed to get flow ${flowId}: ${error.message}`);
        }
    }

    async createFlow(flowData) {
        try {
            const response = await this.client.post('/api/v1/flows', flowData);
            return response.data;
        } catch (error) {
            throw new Error(`Failed to create flow: ${error.message}`);
        }
    }

    async updateFlow(flowId, flowData) {
        try {
            const response = await this.client.put(`/api/v1/flows/${flowId}`, flowData);
            return response.data;
        } catch (error) {
            throw new Error(`Failed to update flow ${flowId}: ${error.message}`);
        }
    }

    async deleteFlow(flowId) {
        try {
            await this.client.delete(`/api/v1/flows/${flowId}`);
            return true;
        } catch (error) {
            throw new Error(`Failed to delete flow ${flowId}: ${error.message}`);
        }
    }

    // Flow Execution
    async runFlow(flowId, inputs, options = {}) {
        try {
            const payload = {
                inputs,
                tweaks: options.tweaks || {},
                stream: options.stream || false,
                session_id: options.sessionId || null
            };

            const response = await this.client.post(`/api/v1/flows/${flowId}/run`, payload);
            return response.data;
        } catch (error) {
            throw new Error(`Failed to run flow ${flowId}: ${error.message}`);
        }
    }

    async runFlowStream(flowId, inputs, onData, options = {}) {
        try {
            const payload = {
                inputs,
                tweaks: options.tweaks || {},
                stream: true,
                session_id: options.sessionId || null
            };

            const response = await this.client.post(`/api/v1/flows/${flowId}/run`, payload, {
                responseType: 'stream'
            });

            response.data.on('data', (chunk) => {
                const lines = chunk.toString().split('\n');
                lines.forEach(line => {
                    if (line.startsWith('data: ')) {
                        try {
                            const data = JSON.parse(line.slice(6));
                            onData(data);
                        } catch (e) {
                            console.error('Failed to parse SSE data:', e);
                        }
                    }
                });
            });

            return response;
        } catch (error) {
            throw new Error(`Failed to run flow stream ${flowId}: ${error.message}`);
        }
    }

    // Components Management
    async getComponents() {
        try {
            const response = await this.client.get('/api/v1/components');
            return response.data;
        } catch (error) {
            throw new Error(`Failed to get components: ${error.message}`);
        }
    }

    // Sessions Management
    async createSession(flowId) {
        try {
            const response = await this.client.post('/api/v1/sessions', { flow_id: flowId });
            return response.data;
        } catch (error) {
            throw new Error(`Failed to create session: ${error.message}`);
        }
    }

    async getSession(sessionId) {
        try {
            const response = await this.client.get(`/api/v1/sessions/${sessionId}`);
            return response.data;
        } catch (error) {
            throw new Error(`Failed to get session ${sessionId}: ${error.message}`);
        }
    }

    // Health Check
    async healthCheck() {
        try {
            const response = await this.client.get('/health');
            return response.data;
        } catch (error) {
            throw new Error(`Health check failed: ${error.message}`);
        }
    }
}

module.exports = LangflowClient;
```

## 🔌 NEXTFLOW CRM INTEGRATION

### Service Layer
```javascript
// services/langflowService.js
const LangflowClient = require('../clients/langflowClient');
const { logger } = require('../utils/logger');
const { validateInput } = require('../utils/validation');

class LangflowService {
    constructor() {
        this.client = new LangflowClient(process.env.LANGFLOW_URL);
        this.flowCache = new Map();
    }

    // Customer Service Chatbot
    async processChatMessage(customerId, message, context = {}) {
        try {
            validateInput({ customerId, message });

            const flowId = process.env.CUSTOMER_SERVICE_FLOW_ID;
            const inputs = {
                message,
                customer_id: customerId,
                context: JSON.stringify(context),
                timestamp: new Date().toISOString()
            };

            const result = await this.client.runFlow(flowId, inputs, {
                sessionId: `customer_${customerId}`
            });

            // Log interaction
            await this.logChatInteraction(customerId, message, result.outputs.response);

            return {
                response: result.outputs.response,
                confidence: result.outputs.confidence || 0.8,
                suggestions: result.outputs.suggestions || [],
                requiresHuman: result.outputs.requires_human || false
            };
        } catch (error) {
            logger.error('Failed to process chat message:', error);
            throw error;
        }
    }

    // Lead Qualification
    async qualifyLead(leadData) {
        try {
            validateInput({ leadData });

            const flowId = process.env.LEAD_QUALIFICATION_FLOW_ID;
            const inputs = {
                name: leadData.name,
                email: leadData.email,
                phone: leadData.phone,
                company: leadData.company,
                industry: leadData.industry,
                budget: leadData.budget,
                timeline: leadData.timeline,
                source: leadData.source
            };

            const result = await this.client.runFlow(flowId, inputs);

            return {
                score: result.outputs.qualification_score,
                category: result.outputs.lead_category,
                priority: result.outputs.priority,
                nextActions: result.outputs.next_actions,
                assignedTo: result.outputs.assigned_to,
                reasoning: result.outputs.reasoning
            };
        } catch (error) {
            logger.error('Failed to qualify lead:', error);
            throw error;
        }
    }

    // Content Generation
    async generateContent(type, parameters) {
        try {
            validateInput({ type, parameters });

            const flowId = this.getContentFlowId(type);
            const inputs = {
                content_type: type,
                ...parameters,
                brand_voice: parameters.brandVoice || 'professional',
                target_audience: parameters.targetAudience || 'general'
            };

            const result = await this.client.runFlow(flowId, inputs);

            return {
                content: result.outputs.generated_content,
                title: result.outputs.title,
                tags: result.outputs.tags || [],
                seoScore: result.outputs.seo_score || 0,
                readabilityScore: result.outputs.readability_score || 0
            };
        } catch (error) {
            logger.error('Failed to generate content:', error);
            throw error;
        }
    }

    // Data Analysis
    async analyzeCustomerData(customerId, analysisType) {
        try {
            validateInput({ customerId, analysisType });

            // Get customer data
            const customerData = await this.getCustomerData(customerId);
            
            const flowId = process.env.DATA_ANALYSIS_FLOW_ID;
            const inputs = {
                customer_data: JSON.stringify(customerData),
                analysis_type: analysisType,
                time_period: '30d' // Default to last 30 days
            };

            const result = await this.client.runFlow(flowId, inputs);

            return {
                insights: result.outputs.insights,
                recommendations: result.outputs.recommendations,
                metrics: result.outputs.metrics,
                trends: result.outputs.trends,
                riskFactors: result.outputs.risk_factors || []
            };
        } catch (error) {
            logger.error('Failed to analyze customer data:', error);
            throw error;
        }
    }

    // Email Campaign Optimization
    async optimizeEmailCampaign(campaignData) {
        try {
            validateInput({ campaignData });

            const flowId = process.env.EMAIL_OPTIMIZATION_FLOW_ID;
            const inputs = {
                subject_line: campaignData.subjectLine,
                content: campaignData.content,
                target_segment: campaignData.targetSegment,
                campaign_goal: campaignData.goal,
                historical_data: JSON.stringify(campaignData.historicalData || {})
            };

            const result = await this.client.runFlow(flowId, inputs);

            return {
                optimizedSubject: result.outputs.optimized_subject,
                optimizedContent: result.outputs.optimized_content,
                sendTimeRecommendation: result.outputs.send_time,
                expectedOpenRate: result.outputs.expected_open_rate,
                expectedClickRate: result.outputs.expected_click_rate,
                improvements: result.outputs.improvements || []
            };
        } catch (error) {
            logger.error('Failed to optimize email campaign:', error);
            throw error;
        }
    }

    // Helper Methods
    getContentFlowId(type) {
        const flowMap = {
            'blog_post': process.env.BLOG_POST_FLOW_ID,
            'social_media': process.env.SOCIAL_MEDIA_FLOW_ID,
            'email_template': process.env.EMAIL_TEMPLATE_FLOW_ID,
            'product_description': process.env.PRODUCT_DESC_FLOW_ID
        };
        return flowMap[type] || process.env.DEFAULT_CONTENT_FLOW_ID;
    }

    async getCustomerData(customerId) {
        // Implement customer data retrieval
        const db = require('../database');
        const result = await db.query(`
            SELECT c.*, 
                   COUNT(o.id) as total_orders,
                   SUM(o.total_amount) as total_spent,
                   AVG(o.total_amount) as avg_order_value,
                   MAX(o.created_at) as last_order_date
            FROM customers c
            LEFT JOIN orders o ON c.id = o.customer_id
            WHERE c.id = $1
            GROUP BY c.id
        `, [customerId]);
        
        return result.rows[0];
    }

    async logChatInteraction(customerId, message, response) {
        const db = require('../database');
        await db.query(`
            INSERT INTO chat_interactions (customer_id, message, response, created_at)
            VALUES ($1, $2, $3, NOW())
        `, [customerId, message, response]);
    }
}

module.exports = LangflowService;
```

## 🌐 API ENDPOINTS

### REST API Routes
```javascript
// routes/langflow.js
const express = require('express');
const router = express.Router();
const LangflowService = require('../services/langflowService');
const { authenticate, authorize } = require('../middleware/auth');
const { validateRequest } = require('../middleware/validation');
const { rateLimiter } = require('../middleware/rateLimiter');

const langflowService = new LangflowService();

// Chat endpoints
router.post('/chat/message', 
    authenticate,
    rateLimiter({ windowMs: 60000, max: 100 }),
    validateRequest({
        body: {
            customerId: 'required|string',
            message: 'required|string|max:1000',
            context: 'object'
        }
    }),
    async (req, res) => {
        try {
            const { customerId, message, context } = req.body;
            const result = await langflowService.processChatMessage(customerId, message, context);
            res.json({ success: true, data: result });
        } catch (error) {
            res.status(500).json({ success: false, error: error.message });
        }
    }
);

// Lead qualification
router.post('/leads/qualify',
    authenticate,
    authorize(['admin', 'sales_manager']),
    validateRequest({
        body: {
            leadData: 'required|object'
        }
    }),
    async (req, res) => {
        try {
            const { leadData } = req.body;
            const result = await langflowService.qualifyLead(leadData);
            res.json({ success: true, data: result });
        } catch (error) {
            res.status(500).json({ success: false, error: error.message });
        }
    }
);

// Content generation
router.post('/content/generate',
    authenticate,
    authorize(['admin', 'content_manager', 'marketing']),
    rateLimiter({ windowMs: 60000, max: 10 }),
    validateRequest({
        body: {
            type: 'required|string|in:blog_post,social_media,email_template,product_description',
            parameters: 'required|object'
        }
    }),
    async (req, res) => {
        try {
            const { type, parameters } = req.body;
            const result = await langflowService.generateContent(type, parameters);
            res.json({ success: true, data: result });
        } catch (error) {
            res.status(500).json({ success: false, error: error.message });
        }
    }
);

// Customer data analysis
router.post('/analytics/customer/:customerId',
    authenticate,
    authorize(['admin', 'analyst', 'sales_manager']),
    validateRequest({
        params: {
            customerId: 'required|string'
        },
        body: {
            analysisType: 'required|string|in:behavior,lifetime_value,churn_risk,preferences'
        }
    }),
    async (req, res) => {
        try {
            const { customerId } = req.params;
            const { analysisType } = req.body;
            const result = await langflowService.analyzeCustomerData(customerId, analysisType);
            res.json({ success: true, data: result });
        } catch (error) {
            res.status(500).json({ success: false, error: error.message });
        }
    }
);

// Email campaign optimization
router.post('/marketing/email/optimize',
    authenticate,
    authorize(['admin', 'marketing']),
    validateRequest({
        body: {
            campaignData: 'required|object'
        }
    }),
    async (req, res) => {
        try {
            const { campaignData } = req.body;
            const result = await langflowService.optimizeEmailCampaign(campaignData);
            res.json({ success: true, data: result });
        } catch (error) {
            res.status(500).json({ success: false, error: error.message });
        }
    }
);

// Flow management
router.get('/flows',
    authenticate,
    authorize(['admin']),
    async (req, res) => {
        try {
            const flows = await langflowService.client.getFlows();
            res.json({ success: true, data: flows });
        } catch (error) {
            res.status(500).json({ success: false, error: error.message });
        }
    }
);

router.get('/flows/:flowId',
    authenticate,
    authorize(['admin']),
    async (req, res) => {
        try {
            const { flowId } = req.params;
            const flow = await langflowService.client.getFlow(flowId);
            res.json({ success: true, data: flow });
        } catch (error) {
            res.status(500).json({ success: false, error: error.message });
        }
    }
);

// Health check
router.get('/health',
    async (req, res) => {
        try {
            const health = await langflowService.client.healthCheck();
            res.json({ success: true, data: health });
        } catch (error) {
            res.status(500).json({ success: false, error: error.message });
        }
    }
);

module.exports = router;
```

## 🔄 WEBHOOK INTEGRATION

### Webhook Handler
```javascript
// webhooks/langflowWebhook.js
const express = require('express');
const crypto = require('crypto');
const router = express.Router();
const { logger } = require('../utils/logger');
const { processWebhookEvent } = require('../services/webhookService');

// Webhook signature verification
function verifyWebhookSignature(req, res, next) {
    const signature = req.headers['x-langflow-signature'];
    const payload = JSON.stringify(req.body);
    const expectedSignature = crypto
        .createHmac('sha256', process.env.LANGFLOW_WEBHOOK_SECRET)
        .update(payload)
        .digest('hex');

    if (signature !== `sha256=${expectedSignature}`) {
        return res.status(401).json({ error: 'Invalid signature' });
    }

    next();
}

// Flow completion webhook
router.post('/flow-completed',
    express.raw({ type: 'application/json' }),
    verifyWebhookSignature,
    async (req, res) => {
        try {
            const event = JSON.parse(req.body);
            
            logger.info('Received flow completion webhook:', event);

            await processWebhookEvent('flow_completed', event);

            res.status(200).json({ received: true });
        } catch (error) {
            logger.error('Webhook processing failed:', error);
            res.status(500).json({ error: 'Webhook processing failed' });
        }
    }
);

// Flow error webhook
router.post('/flow-error',
    express.raw({ type: 'application/json' }),
    verifyWebhookSignature,
    async (req, res) => {
        try {
            const event = JSON.parse(req.body);
            
            logger.error('Received flow error webhook:', event);

            await processWebhookEvent('flow_error', event);

            res.status(200).json({ received: true });
        } catch (error) {
            logger.error('Webhook processing failed:', error);
            res.status(500).json({ error: 'Webhook processing failed' });
        }
    }
);

module.exports = router;
```

## 📊 MONITORING VÀ METRICS

### Metrics Collection
```javascript
// monitoring/langflowMetrics.js
const prometheus = require('prom-client');

// Define metrics
const flowExecutionCounter = new prometheus.Counter({
    name: 'langflow_flow_executions_total',
    help: 'Total number of flow executions',
    labelNames: ['flow_id', 'status']
});

const flowExecutionDuration = new prometheus.Histogram({
    name: 'langflow_flow_execution_duration_seconds',
    help: 'Flow execution duration in seconds',
    labelNames: ['flow_id'],
    buckets: [0.1, 0.5, 1, 2, 5, 10, 30, 60]
});

const apiRequestCounter = new prometheus.Counter({
    name: 'langflow_api_requests_total',
    help: 'Total number of API requests',
    labelNames: ['method', 'endpoint', 'status']
});

const activeSessionsGauge = new prometheus.Gauge({
    name: 'langflow_active_sessions',
    help: 'Number of active Langflow sessions'
});

class LangflowMetrics {
    static recordFlowExecution(flowId, status, duration) {
        flowExecutionCounter.inc({ flow_id: flowId, status });
        if (duration) {
            flowExecutionDuration.observe({ flow_id: flowId }, duration);
        }
    }

    static recordApiRequest(method, endpoint, status) {
        apiRequestCounter.inc({ method, endpoint, status });
    }

    static setActiveSessions(count) {
        activeSessionsGauge.set(count);
    }

    static getMetrics() {
        return prometheus.register.metrics();
    }
}

module.exports = LangflowMetrics;
```

## 🧪 TESTING

### Unit Tests
```javascript
// tests/langflowService.test.js
const LangflowService = require('../services/langflowService');
const LangflowClient = require('../clients/langflowClient');

jest.mock('../clients/langflowClient');

describe('LangflowService', () => {
    let langflowService;
    let mockClient;

    beforeEach(() => {
        mockClient = {
            runFlow: jest.fn(),
            getFlows: jest.fn(),
            healthCheck: jest.fn()
        };
        LangflowClient.mockImplementation(() => mockClient);
        langflowService = new LangflowService();
    });

    describe('processChatMessage', () => {
        it('should process chat message successfully', async () => {
            const mockResponse = {
                outputs: {
                    response: 'Hello! How can I help you?',
                    confidence: 0.9,
                    suggestions: ['Check order status', 'Contact support']
                }
            };

            mockClient.runFlow.mockResolvedValue(mockResponse);

            const result = await langflowService.processChatMessage(
                'customer123',
                'Hello',
                { source: 'web' }
            );

            expect(result.response).toBe('Hello! How can I help you?');
            expect(result.confidence).toBe(0.9);
            expect(mockClient.runFlow).toHaveBeenCalledWith(
                expect.any(String),
                expect.objectContaining({
                    message: 'Hello',
                    customer_id: 'customer123'
                }),
                expect.objectContaining({
                    sessionId: 'customer_customer123'
                })
            );
        });

        it('should handle errors gracefully', async () => {
            mockClient.runFlow.mockRejectedValue(new Error('API Error'));

            await expect(
                langflowService.processChatMessage('customer123', 'Hello')
            ).rejects.toThrow('API Error');
        });
    });

    describe('qualifyLead', () => {
        it('should qualify lead successfully', async () => {
            const mockResponse = {
                outputs: {
                    qualification_score: 85,
                    lead_category: 'hot',
                    priority: 'high',
                    next_actions: ['Schedule demo', 'Send pricing']
                }
            };

            mockClient.runFlow.mockResolvedValue(mockResponse);

            const leadData = {
                name: 'John Doe',
                email: 'john@example.com',
                company: 'Acme Corp',
                budget: 50000
            };

            const result = await langflowService.qualifyLead(leadData);

            expect(result.score).toBe(85);
            expect(result.category).toBe('hot');
            expect(result.priority).toBe('high');
        });
    });
});
```

### Integration Tests
```javascript
// tests/integration/langflowIntegration.test.js
const request = require('supertest');
const app = require('../../app');
const { setupTestDb, cleanupTestDb } = require('../helpers/database');

describe('Langflow Integration', () => {
    let authToken;

    beforeAll(async () => {
        await setupTestDb();
        // Get auth token
        const loginResponse = await request(app)
            .post('/api/auth/login')
            .send({
                email: 'test@example.com',
                password: 'testpassword'
            });
        authToken = loginResponse.body.token;
    });

    afterAll(async () => {
        await cleanupTestDb();
    });

    describe('POST /api/langflow/chat/message', () => {
        it('should process chat message', async () => {
            const response = await request(app)
                .post('/api/langflow/chat/message')
                .set('Authorization', `Bearer ${authToken}`)
                .send({
                    customerId: 'test-customer-123',
                    message: 'Hello, I need help with my order',
                    context: { source: 'web' }
                });

            expect(response.status).toBe(200);
            expect(response.body.success).toBe(true);
            expect(response.body.data.response).toBeDefined();
        });

        it('should return 400 for invalid input', async () => {
            const response = await request(app)
                .post('/api/langflow/chat/message')
                .set('Authorization', `Bearer ${authToken}`)
                .send({
                    customerId: '',
                    message: ''
                });

            expect(response.status).toBe(400);
        });
    });

    describe('POST /api/langflow/leads/qualify', () => {
        it('should qualify lead', async () => {
            const leadData = {
                name: 'Jane Smith',
                email: 'jane@company.com',
                company: 'Tech Corp',
                industry: 'Technology',
                budget: 100000,
                timeline: '3 months'
            };

            const response = await request(app)
                .post('/api/langflow/leads/qualify')
                .set('Authorization', `Bearer ${authToken}`)
                .send({ leadData });

            expect(response.status).toBe(200);
            expect(response.body.success).toBe(true);
            expect(response.body.data.score).toBeDefined();
            expect(response.body.data.category).toBeDefined();
        });
    });
});
```

---

*Tài liệu tích hợp API Langflow - Phiên bản 1.0*