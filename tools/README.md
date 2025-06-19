# Công cụ hỗ trợ

Thư mục này chứa các công cụ và script hỗ trợ cho dự án.

## Cấu trúc thư mục

- `n8n_pipe.py`: Script Python để xử lý dữ liệu cho n8n
- `n8n-tool-workflows/`: Các workflow mẫu cho n8n
  - `Create_Google_Doc.json`: Workflow tạo Google Doc
  - `Get_Postgres_Tables.json`: Workflow lấy danh sách bảng từ PostgreSQL
  - `Post_Message_to_Slack.json`: Workflow gửi tin nhắn đến Slack
  - `Summarize_Slack_Conversation.json`: Workflow tóm tắt cuộc trò chuyện Slack
- `Local_RAG_AI_Agent_n8n_Workflow.json`: Workflow RAG AI Agent cho n8n

## Cách sử dụng

### n8n_pipe.py

Script này được sử dụng để xử lý dữ liệu cho n8n. Để sử dụng:

```bash
python tools/n8n_pipe.py [tham số]
```

### n8n-tool-workflows

Các workflow mẫu cho n8n có thể được import vào n8n thông qua giao diện web.

1. Truy cập giao diện web n8n
2. Chọn "Workflows" > "Import from file"
3. Chọn file workflow từ thư mục `tools/n8n-tool-workflows`

### Local_RAG_AI_Agent_n8n_Workflow.json

Workflow RAG AI Agent cho n8n có thể được import vào n8n thông qua giao diện web.

1. Truy cập giao diện web n8n
2. Chọn "Workflows" > "Import from file"
3. Chọn file `tools/Local_RAG_AI_Agent_n8n_Workflow.json`
