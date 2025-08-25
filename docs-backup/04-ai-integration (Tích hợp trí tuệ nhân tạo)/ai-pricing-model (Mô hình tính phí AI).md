# MÔ HÌNH TÍNH PHÍ AI - Token-based Pricing

## 🎯 **TỔNG QUAN MÔ HÌNH TÍNH PHÍ**

NextFlow CRM-AI sử dụng **mô hình tính phí theo token** (Token-based Pricing) - phương pháp tính tiền dựa trên lượng AI thực sự sử dụng, giúp khách hàng chỉ trả tiền cho những gì họ dùng.

### **🔤 Định nghĩa thuật ngữ:**
- **Token**: Đơn vị tính nhỏ nhất của AI - 1 token ≈ 0.75 từ tiếng Anh hoặc 1 từ tiếng Việt
- **Input Token**: Token đầu vào - số token trong câu hỏi khách hàng gửi lên
- **Output Token**: Token đầu ra - số token trong câu trả lời AI tạo ra
- **Token-based Pricing**: Mô hình tính phí theo token - trả tiền theo lượng AI sử dụng
- **Usage-based Billing**: Thanh toán theo sử dụng - càng dùng nhiều càng trả nhiều
- **Free Tier**: Gói miễn phí - số lượng token được dùng free mỗi tháng
- **Overage**: Vượt mức - phí phát sinh khi dùng quá gói đã mua

---

## 💰 **BẢNG GIÁ NEXTFLOW AI (Chạy trên Laptop)**

### **📊 Cấu trúc giá theo gói:**

| Gói dịch vụ | Giá gói/tháng | Token miễn phí | Giá vượt mức | Phù hợp cho |
|-------------|---------------|----------------|--------------|-------------|
| **Starter** | 199.000 VNĐ | 1.000 tokens | 50 VNĐ/1K tokens | 5-20 nhân viên |
| **Pro** | 499.000 VNĐ | 5.000 tokens | 40 VNĐ/1K tokens | 20-100 nhân viên |
| **Enterprise** | Liên hệ | 20.000 tokens | 30 VNĐ/1K tokens | 100+ nhân viên |

### **🔢 Cách tính token:**
```
Ví dụ câu hỏi: "Khách hàng Nguyễn Văn A muốn mua sản phẩm X"
- Số từ: 10 từ
- Số token: ~10 tokens (tiếng Việt 1 từ ≈ 1 token)

Ví dụ câu trả lời AI: "Tôi sẽ giúp bạn tạo đơn hàng cho khách hàng Nguyễn Văn A. Sản phẩm X hiện có sẵn trong kho với giá 500.000 VNĐ. Bạn có muốn tôi tạo đơn hàng ngay không?"
- Số từ: 35 từ  
- Số token: ~35 tokens

Tổng token cho 1 lần chat: 10 + 35 = 45 tokens
```

### **💡 Ước tính sử dụng thực tế:**

**Nhân viên bán hàng trung bình:**
- **50 câu hỏi AI/ngày** × 45 tokens/câu = 2.250 tokens/ngày
- **2.250 tokens/ngày** × 22 ngày làm việc = 49.500 tokens/tháng
- **Chi phí với gói Pro**: 499K + (49.5K - 5K) × 40 VNĐ = 499K + 1.780K = **2.279K VNĐ/tháng**

**Nhân viên chăm sóc khách hàng:**
- **100 câu hỏi AI/ngày** × 30 tokens/câu = 3.000 tokens/ngày  
- **3.000 tokens/ngày** × 22 ngày = 66.000 tokens/tháng
- **Chi phí với gói Pro**: 499K + (66K - 5K) × 40 VNĐ = 499K + 2.440K = **2.939K VNĐ/tháng**

---

## 🌐 **BẢNG GIÁ BYOK (Bring Your Own Key)**

### **🔑 Khách hàng tự trả phí API:**

**OpenAI GPT-4 Turbo:**
- **Input**: 30 USD/1M tokens = 720 VNĐ/1K tokens
- **Output**: 90 USD/1M tokens = 2.160 VNĐ/1K tokens
- **Trung bình**: ~1.440 VNĐ/1K tokens (tỷ lệ input:output = 1:1)

**Anthropic Claude-3 Sonnet:**
- **Input**: 15 USD/1M tokens = 360 VNĐ/1K tokens
- **Output**: 75 USD/1M tokens = 1.800 VNĐ/1K tokens  
- **Trung bình**: ~1.080 VNĐ/1K tokens

**Google Gemini Pro:**
- **Input**: 7.5 USD/1M tokens = 180 VNĐ/1K tokens
- **Output**: 22.5 USD/1M tokens = 540 VNĐ/1K tokens
- **Trung bình**: ~360 VNĐ/1K tokens

### **💸 Ước tính chi phí BYOK:**

**Với GPT-4 (chất lượng cao nhất):**
- **49.500 tokens/tháng** × 1.440 VNĐ/1K tokens = **71.280 VNĐ/tháng/nhân viên**

**Với Claude-3 (cân bằng giá/chất lượng):**
- **49.500 tokens/tháng** × 1.080 VNĐ/1K tokens = **53.460 VNĐ/tháng/nhân viên**

**Với Gemini (giá rẻ nhất):**
- **49.500 tokens/tháng** × 360 VNĐ/1K tokens = **17.820 VNĐ/tháng/nhân viên**

---

## 📊 **SO SÁNH CHI PHÍ 2 LỰA CHỌN**

### **🏢 Công ty 20 nhân viên sử dụng AI:**

| Lựa chọn | Chi phí cố định | Chi phí biến đổi | Tổng chi phí/tháng | Chi phí/nhân viên |
|----------|-----------------|------------------|-------------------|-------------------|
| **NextFlow AI** | 499K VNĐ × 20 = 9.98M | 1.78M × 20 = 35.6M | **45.58M VNĐ** | **2.279K VNĐ** |
| **BYOK GPT-4** | 0 VNĐ | 71.28K × 20 = 1.426M | **1.426M VNĐ** | **71.3K VNĐ** |
| **BYOK Claude-3** | 0 VNĐ | 53.46K × 20 = 1.069M | **1.069M VNĐ** | **53.5K VNĐ** |
| **BYOK Gemini** | 0 VNĐ | 17.82K × 20 = 356K | **356K VNĐ** | **17.8K VNĐ** |

### **📈 Phân tích break-even point:**

**NextFlow AI có lợi khi:**
- Sử dụng **ít hơn 10K tokens/tháng/nhân viên** (sử dụng nhẹ)
- Ưu tiên **bảo mật dữ liệu** cao
- Có **kiến thức kỹ thuật** để vận hành

**BYOK có lợi khi:**
- Sử dụng **nhiều hơn 50K tokens/tháng/nhân viên** (sử dụng nặng)
- Cần **chất lượng AI cao nhất**
- Muốn **đơn giản vận hành**

---

## 🧮 **CÔNG CỤ TÍNH TOÁN CHI PHÍ**

### **📱 Calculator đơn giản:**

```javascript
// Hàm tính chi phí NextFlow AI
function calculateNextFlowCost(employees, tokensPerEmployee) {
    const plans = {
        starter: { price: 199000, freeTokens: 1000, overageRate: 50 },
        pro: { price: 499000, freeTokens: 5000, overageRate: 40 },
        enterprise: { price: 999000, freeTokens: 20000, overageRate: 30 }
    };
    
    // Chọn gói phù hợp
    let plan = plans.starter;
    if (employees > 20) plan = plans.pro;
    if (employees > 100) plan = plans.enterprise;
    
    // Tính chi phí
    const totalTokens = tokensPerEmployee * employees;
    const freeTokens = plan.freeTokens * employees;
    const overageTokens = Math.max(0, totalTokens - freeTokens);
    
    const fixedCost = plan.price * employees;
    const variableCost = overageTokens * plan.overageRate;
    
    return {
        fixedCost: fixedCost,
        variableCost: variableCost,
        totalCost: fixedCost + variableCost,
        costPerEmployee: (fixedCost + variableCost) / employees
    };
}

// Hàm tính chi phí BYOK
function calculateBYOKCost(employees, tokensPerEmployee, provider) {
    const rates = {
        gpt4: 1440,      // VNĐ per 1K tokens
        claude3: 1080,   // VNĐ per 1K tokens  
        gemini: 360      // VNĐ per 1K tokens
    };
    
    const totalTokens = tokensPerEmployee * employees;
    const totalCost = (totalTokens / 1000) * rates[provider];
    
    return {
        fixedCost: 0,
        variableCost: totalCost,
        totalCost: totalCost,
        costPerEmployee: totalCost / employees
    };
}

// Ví dụ sử dụng
const company = {
    employees: 20,
    tokensPerEmployee: 49500  // tokens/tháng
};

console.log("NextFlow AI:", calculateNextFlowCost(company.employees, company.tokensPerEmployee));
console.log("BYOK GPT-4:", calculateBYOKCost(company.employees, company.tokensPerEmployee, 'gpt4'));
```

### **📊 Kết quả ví dụ:**
```
NextFlow AI: {
    fixedCost: 9,980,000 VNĐ,
    variableCost: 35,600,000 VNĐ,
    totalCost: 45,580,000 VNĐ,
    costPerEmployee: 2,279,000 VNĐ
}

BYOK GPT-4: {
    fixedCost: 0 VNĐ,
    variableCost: 1,425,600 VNĐ,
    totalCost: 1,425,600 VNĐ,
    costPerEmployee: 71,280 VNĐ
}
```

---

## 💡 **CHIẾN LƯỢC TỐI ƯU CHI PHÍ**

### **🎯 Cho doanh nghiệp khởi nghiệp:**

**Giai đoạn 1 (0-10 nhân viên):**
- **Khuyến nghị**: NextFlow AI gói Starter
- **Lý do**: Chi phí thấp, học được cách sử dụng AI
- **Chi phí**: ~200K VNĐ/tháng/nhân viên

**Giai đoạn 2 (10-50 nhân viên):**
- **Khuyến nghị**: Hybrid (NextFlow AI + BYOK Gemini)
- **Lý do**: Cân bằng chi phí và chất lượng
- **Chi phí**: ~100-500K VNĐ/tháng/nhân viên

**Giai đoạn 3 (50+ nhân viên):**
- **Khuyến nghị**: BYOK Claude-3 hoặc GPT-4
- **Lý do**: Chi phí thấp hơn, chất lượng cao
- **Chi phí**: ~50-100K VNĐ/tháng/nhân viên

### **⚡ Tips tiết kiệm chi phí:**

**1. Tối ưu prompt (câu hỏi):**
- Viết câu hỏi ngắn gọn, rõ ràng
- Tránh lặp lại thông tin không cần thiết
- Sử dụng context (ngữ cảnh) hiệu quả

**2. Quản lý usage:**
- Giới hạn số lượng tokens/ngày cho mỗi nhân viên
- Monitor (giám sát) usage hàng ngày
- Alert (cảnh báo) khi sắp vượt budget

**3. Chọn model phù hợp:**
- Dùng model nhỏ cho tác vụ đơn giản
- Dùng model lớn cho tác vụ phức tạp
- A/B test để tìm model tối ưu

---

## 📈 **BÁO CÁO VÀ PHÂN TÍCH CHI PHÍ**

### **📊 Dashboard theo dõi:**
- **Daily usage**: Sử dụng hàng ngày
- **Monthly trend**: Xu hướng hàng tháng  
- **Cost breakdown**: Phân tích chi phí
- **ROI calculation**: Tính toán lợi nhuận

### **🔔 Cảnh báo tự động:**
- **80% budget**: Cảnh báo sắp hết budget
- **100% budget**: Tạm dừng AI để tránh overage
- **Unusual spike**: Cảnh báo sử dụng bất thường
- **Monthly report**: Báo cáo tổng kết hàng tháng

---

**Cập nhật lần cuối**: 2025-08-01  
**Tác giả**: NextFlow Team  
**Phiên bản**: Bootstrap v1.0
