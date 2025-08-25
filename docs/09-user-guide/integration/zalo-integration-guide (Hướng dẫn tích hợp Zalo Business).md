# HƯỚNG DẪN TÍCH HỢP ZALO BUSINESS - NextFlow CRM-AI

## 📱 GIỚI THIỆU

Tích hợp Zalo Business với NextFlow CRM-AI giúp bạn bán hàng trực tiếp trên Zalo, tự động hóa chăm sóc khách hàng và đồng bộ dữ liệu giữa hai hệ thống.

### 🎯 **Lợi ích tích hợp:**
- ✅ **Bán hàng trên Zalo**: Tạo đơn hàng trực tiếp từ chat
- ✅ **Chatbot AI**: Tự động trả lời 24/7
- ✅ **Đồng bộ khách hàng**: Tự động lưu thông tin từ Zalo
- ✅ **Marketing automation**: Gửi tin nhắn hàng loạt
- ✅ **Analytics tích hợp**: Báo cáo hiệu quả bán hàng
- ✅ **Miễn phí Zalo Pro**: Tiết kiệm 2.4M VND/năm

---

## 📋 **BƯỚC 1: CHUẨN BỊ ZALO BUSINESS**

### 1.1. Tạo Zalo Official Account (OA)

1. **Truy cập**: https://oa.zalo.me
2. **Đăng ký tài khoản** với:
   - Số điện thoại doanh nghiệp
   - Email công ty
   - Giấy phép kinh doanh
3. **Xác thực OA**:
   - Upload giấy tờ pháp lý
   - Chờ Zalo duyệt (1-3 ngày)
4. **Lưu thông tin**:
   - **OA ID**: ZOA_xxxxxxxxx
   - **App ID**: xxxxxxxxx
   - **App Secret**: xxxxxxxxx

### 1.2. Cấu hình Zalo OA

1. **Thông tin cơ bản**:
   - Tên OA: Tên công ty/thương hiệu
   - Avatar: Logo công ty
   - Cover photo: Banner sản phẩm
   - Mô tả: Giới thiệu ngắn gọn

2. **Cài đặt tin nhắn**:
   - **Tin nhắn chào**: "Xin chào! Chúng tôi có thể hỗ trợ gì cho bạn?"
   - **Tin nhắn vắng mặt**: "Cảm ơn bạn đã nhắn tin. Chúng tôi sẽ phản hồi sớm nhất!"
   - **Menu nhanh**: Sản phẩm, Hỗ trợ, Liên hệ

### 1.3. Kích hoạt Zalo Business API

1. **Vào "Cài đặt"** → **"API & Webhook"**
2. **Tạo App**:
   - App Name: NextFlow CRM Integration
   - Callback URL: https://yoursite.com/zalo/callback
   - Webhook URL: https://yoursite.com/zalo/webhook
3. **Lấy credentials**:
   - App ID
   - App Secret
   - OA ID
4. **Cấp quyền**:
   - Gửi tin nhắn
   - Quản lý người theo dõi
   - Truy cập thông tin cơ bản

---

## 🔗 **BƯỚC 2: TÍCH HỢP VỚI NEXTFLOW CRM-AI**

### 2.1. Kết nối Zalo trong NextFlow

1. **Đăng nhập NextFlow CRM-AI**
2. **Vào "Integrations"** → **"Zalo Business"**
3. **Nhấn "Connect Zalo OA"**
4. **Nhập thông tin**:
   - **OA ID**: ZOA_xxxxxxxxx
   - **App ID**: xxxxxxxxx
   - **App Secret**: xxxxxxxxx
   - **Webhook Secret**: (tự tạo)
5. **Nhấn "Test Connection"**
6. **Nếu thành công, nhấn "Save"**

### 2.2. Cấu hình Webhook

1. **Copy Webhook URL** từ NextFlow:
   ```
   https://api.nextflow.com/webhooks/zalo/{your-org-id}
   ```

2. **Vào Zalo OA Dashboard**:
   - Settings → Webhook
   - Paste URL vào Webhook URL
   - Chọn events: message, follow, unfollow
   - Nhấn "Save"

3. **Test webhook**:
   - Gửi tin nhắn test từ Zalo
   - Kiểm tra trong NextFlow → Integrations → Zalo → Logs

### 2.3. Đồng bộ dữ liệu

1. **Sync existing followers**:
   - Vào Zalo Integration → "Sync Followers"
   - Chọn "Import All" hoặc "Import New Only"
   - Chờ quá trình hoàn thành

2. **Mapping fields**:
   - Zalo Display Name → Customer Name
   - Zalo User ID → External ID
   - Avatar → Profile Picture
   - Phone (nếu có) → Phone Number

---

## 🤖 **BƯỚC 3: THIẾT LẬP CHATBOT AI**

### 3.1. Kích hoạt Zalo Chatbot

1. **Vào "AI Chatbot"** → **"Zalo Bot"**
2. **Nhấn "Enable Zalo Bot"**
3. **Chọn template**:
   - 🛒 E-commerce Support
   - 📞 Lead Generation
   - 🎯 Customer Service
   - 🎨 Custom (tự tạo)

### 3.2. Cấu hình Bot Responses

**Tin nhắn chào:**
```
Xin chào {customer_name}! 👋

Tôi là AI Assistant của {company_name}. Tôi có thể giúp bạn:

🛒 Xem sản phẩm và đặt hàng
📞 Tư vấn và hỗ trợ
📋 Tra cứu đơn hàng
💬 Kết nối với tư vấn viên

Bạn cần hỗ trợ gì ạ?
```

**Menu nhanh:**
- 🛒 "Xem sản phẩm" → Hiển thị catalog
- 📞 "Tư vấn" → Kết nối sales
- 📋 "Tra cứu đơn hàng" → Form nhập số đơn
- 💬 "Chat với người" → Transfer to human

### 3.3. Product Catalog Integration

1. **Sync product catalog**:
   - Vào Products → Zalo Integration
   - Chọn products để sync
   - Nhấn "Sync to Zalo"

2. **Product display format**:
   ```
   📱 {product_name}
   💰 Giá: {price} VND
   📦 Còn: {stock} sản phẩm
   
   📸 [Hình ảnh sản phẩm]
   
   🛒 Đặt hàng ngay
   📞 Tư vấn thêm
   ```

---

## 🛒 **BƯỚC 4: BÁN HÀNG TRÊN ZALO**

### 4.1. Tạo đơn hàng từ Zalo Chat

**Quy trình tự động:**
1. **Khách hàng chat** → Bot nhận diện intent
2. **Hiển thị sản phẩm** → Khách chọn sản phẩm
3. **Thu thập thông tin** → Tên, SĐT, địa chỉ
4. **Tạo đơn hàng** → Tự động trong CRM
5. **Xác nhận** → Gửi thông tin đơn hàng
6. **Thanh toán** → Link thanh toán online

**Template đặt hàng:**
```
✅ Đơn hàng #{order_number} đã được tạo!

👤 Khách hàng: {customer_name}
📞 SĐT: {phone}
📍 Địa chỉ: {address}

🛒 Sản phẩm:
- {product_name} x{quantity}
- Giá: {price} VND

💰 Tổng tiền: {total} VND
🚚 Phí ship: {shipping_fee} VND
💳 Thanh toán: {payment_method}

🔗 Thanh toán online: {payment_link}

📞 Hotline: {phone_number}
```

### 4.2. Order Management từ Zalo

1. **Tra cứu đơn hàng**:
   - Khách gửi mã đơn hàng
   - Bot tự động tra cứu
   - Hiển thị trạng thái real-time

2. **Cập nhật đơn hàng**:
   - Thay đổi địa chỉ
   - Hủy đơn hàng
   - Yêu cầu hoàn tiền

3. **Thông báo tự động**:
   - Xác nhận đơn hàng
   - Chuẩn bị hàng
   - Đang giao hàng
   - Giao hàng thành công

---

## 📊 **BƯỚC 5: MARKETING AUTOMATION**

### 5.1. Broadcast Messages

1. **Tạo campaign**:
   - Vào Marketing → Zalo Campaigns
   - Chọn audience segment
   - Tạo nội dung tin nhắn
   - Lên lịch gửi

2. **Message types**:
   - **Text**: Tin nhắn văn bản
   - **Image**: Hình ảnh + caption
   - **List**: Danh sách sản phẩm
   - **Carousel**: Nhiều sản phẩm cuộn ngang

### 5.2. Automated Workflows

**Welcome Series:**
```
Day 0: Chào mừng + giới thiệu
Day 1: Sản phẩm bestseller
Day 3: Mã giảm giá 10%
Day 7: Hướng dẫn sử dụng
Day 14: Feedback survey
```

**Abandoned Cart:**
```
1 hour: "Bạn quên sản phẩm trong giỏ hàng"
24 hours: "Mã giảm giá 5% cho đơn hàng"
3 days: "Sản phẩm sắp hết hàng"
7 days: "Gợi ý sản phẩm tương tự"
```

### 5.3. Customer Segmentation

**Phân khúc theo hành vi:**
- 🔥 **Active**: Tương tác trong 7 ngày
- 😴 **Inactive**: Không tương tác 30 ngày
- 🛒 **Buyers**: Đã mua hàng
- 👀 **Browsers**: Chỉ xem, chưa mua

**Personalized messaging:**
- VIP customers: Ưu đãi đặc biệt
- New followers: Welcome series
- Repeat buyers: Loyalty rewards
- Cart abandoners: Recovery campaigns

---

## 📈 **BƯỚC 6: ANALYTICS VÀ BÁO CÁO**

### 6.1. Zalo Performance Dashboard

**Metrics chính:**
- 👥 **Followers**: Tổng số người theo dõi
- 💬 **Messages**: Tin nhắn gửi/nhận
- 📈 **Engagement**: Tỷ lệ tương tác
- 🛒 **Conversions**: Đơn hàng từ Zalo
- 💰 **Revenue**: Doanh thu từ Zalo

### 6.2. Detailed Reports

1. **Message Analytics**:
   - Open rates
   - Click rates
   - Response rates
   - Best performing content

2. **Sales Analytics**:
   - Revenue by time period
   - Top selling products
   - Customer acquisition cost
   - Lifetime value

3. **Customer Analytics**:
   - Demographics
   - Behavior patterns
   - Purchase history
   - Engagement trends

### 6.3. ROI Calculation

**Zalo Marketing ROI:**
```
ROI = (Revenue from Zalo - Marketing Cost) / Marketing Cost × 100%

Example:
Revenue: 50,000,000 VND
Cost: 5,000,000 VND
ROI = (50M - 5M) / 5M × 100% = 900%
```

---

## 🔧 **BƯỚC 7: TROUBLESHOOTING**

### 7.1. Common Issues

**Webhook không hoạt động:**
- Kiểm tra URL webhook
- Verify SSL certificate
- Check firewall settings
- Test với ngrok (development)

**Bot không trả lời:**
- Kiểm tra bot status
- Verify API credentials
- Check rate limits
- Review error logs

**Đồng bộ dữ liệu sai:**
- Check field mapping
- Verify data format
- Review sync logs
- Manual data correction

### 7.2. Error Codes

| Code | Meaning | Solution |
|------|---------|----------|
| 1001 | Invalid access token | Refresh token |
| 1002 | Rate limit exceeded | Reduce request frequency |
| 1003 | Invalid OA ID | Check OA configuration |
| 2001 | Message format error | Fix message template |
| 3001 | Webhook verification failed | Check webhook secret |

### 7.3. Best Practices

1. **Message Frequency**:
   - Không spam khách hàng
   - Respect opt-out requests
   - Segment based on preferences

2. **Content Quality**:
   - Valuable, relevant content
   - Clear call-to-actions
   - Mobile-optimized images

3. **Compliance**:
   - Follow Zalo policies
   - Respect privacy laws
   - Maintain data security

---

## 💡 **TIPS VÀ TRICKS**

### 🚀 **Tăng hiệu quả bán hàng**

1. **Quick Replies**: Thiết lập câu trả lời nhanh
2. **Rich Messages**: Sử dụng hình ảnh, video
3. **Persistent Menu**: Menu cố định dễ truy cập
4. **Live Chat Handover**: Chuyển từ bot sang người

### 📱 **Mobile Optimization**

1. **Short Messages**: Tin nhắn ngắn gọn
2. **Visual Content**: Hình ảnh chất lượng cao
3. **Fast Loading**: Tối ưu tốc độ tải
4. **Touch-Friendly**: Buttons dễ nhấn

### 🎯 **Conversion Optimization**

1. **Clear CTAs**: Call-to-action rõ ràng
2. **Social Proof**: Reviews, testimonials
3. **Urgency**: Limited time offers
4. **Personalization**: Nội dung cá nhân hóa

---

## 📞 **HỖ TRỢ VÀ LIÊN HỆ**

### 🆘 **Cần hỗ trợ?**

- **📞 Zalo Integration Support**: 1900-xxxx (ext. 3)
- **💬 Live Chat**: Trong NextFlow → Integrations → Help
- **📧 Email**: zalo-support@nextflow.com
- **📱 Zalo OA**: @nextflowsupport

### 📚 **Tài liệu thêm**

- **🎥 Video Setup**: youtube.com/nextflow-zalo
- **📖 Zalo API Docs**: developers.zalo.me
- **👥 Community**: facebook.com/groups/nextflow-zalo
- **📱 Best Practices**: help.nextflow.com/zalo

---

**🎉 Chúc bạn tích hợp Zalo Business thành công và tăng doanh số bán hàng!**

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: v2.0.0  
**Độ khó**: ⭐⭐⭐☆☆ (Trung bình)
