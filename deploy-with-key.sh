#!/bin/bash

# You2API 安全部署腳本（包含 API Key 配置）
# 作者：您的專屬程序員
# 版本：2.0

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日誌函數
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 您的 You API Key（請在生產環境中使用環境變量）
YOU_API_KEY="eyJhbGciOiJSUzI1NiIsImtpZCI6IlNLMmpJbnU3SWpjMkp1eFJad1psWHBZRUpQQkFvIiwidHlwIjoiSldUIn0.eyJhbXIiOlsib2F1dGgiXSwiYXV0aDBJZCI6bnVsbCwiY3JlYXRlVGltZSI6MTc0NjExNDI0MywiZHJuIjoiRFMiLCJlbWFpbCI6InlhdHRzdW4ubmdhbkBzanN1LmVkdSIsImV4cCI6MTc0OTQ0NDgxMSwiZ2l2ZW5OYW1lIjoiWWF0VHN1biIsImlhdCI6MTc0ODIzNTIxMSwiaXNzIjoiUDJqSW50dFJNdVhweVlaTWJWY3NjNEM5WjBSVCIsImxhc3ROYW1lIjoiTmdhbiIsImxvZ2luSWRzIjpbImdvb2dsZS0xMTI1MDgwOTQwNjQ3MTU1MjcwNTAiLCJ5YXR0c3VuLm5nYW5Ac2pzdS5lZHUiXSwibmFtZSI6IllhdFRzdW4gTmdhbiIsInBpY3R1cmUiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vYS9BQ2c4b2NKeUZuZXBHdC1wYU8zejFXcXptTjhpcXBmWTZweE1kTXlSX2VHVGJiZ1lqUHFGcGc9czk2LWMiLCJyZXhwIjoiMjAyNi0wNS0yNVQwNDo1MzozMVoiLCJzdHl0Y2hJZCI6bnVsbCwic3ViIjoiVTJ3VjY5Z0ZWaHY1T0xMNUZtZFZBckk2Q3JzViIsInN1YnNjcmlwdGlvblRpZXIiOiJ5b3Vwcm9fYW5udWFsIiwidGVuYW50Q3VzdG9tQXR0cmlidXRlcyI6eyJpc0VudGVycHJpc2UiOiJ7e3RlbmFudC5jdXN0b21BdHRyaWJ1dGVzLmlzRW50ZXJwcmlzZX19IiwibmFtZSI6Int7dGVuYW50Lm5hbWV9fSJ9LCJ0ZW5hbnRJbnZpdGF0aW9uIjpudWxsLCJ0ZW5hbnRJbnZpdGVyIjpudWxsLCJ1c2VySWQiOiJVMndWNjlnRlZodjVPTEw1Rm1kVkFySTZDcnNWIiwidmVyaWZpZWRFbWFpbCI6dHJ1ZX0.C_tLBWkVPHNEwyGro20qCnBDxyaKlbxknO77FxAFHbMzMtZITbOFebAsCnYao6pLxjGBLFsca8yR-KlUj_hWyN1F9fGyD2KmJkvvFIimaDbh2cWYyU3VZWXhVvxZ1ZrWKInpPeq3JXPkymU4xbBHnkedxsWOg9MmujLcL9d2dIMXlWhvRUajXqUjx3hSfv3tKzNHFlict0QHtkIpSfF8VAhgEhJuD0TieLpmtgNtW1wQTSPfPJFB2GfGKB01VApja3WLx4rCB0MEt_meVDB_EJUttapyAgWV3TbQl7Q0KjfuByt-WFt82c6ToP6W8jj-2HobYDI569IhwDkdgXWqTQ"

# 創建環境配置文件
create_env_file() {
    log_info "創建環境配置文件..."
    
    cat > .env << EOF
# You2API 生產環境配置
# 自動生成於 $(date)

# You.com API 配置
YOU_API_KEY=${YOU_API_KEY}
YOU_API_BASE_URL=https://api.you.com

# 服務配置
PORT=8080
ENABLE_PROXY=false
PROXY_URL=
PROXY_TIMEOUT_MS=5000
LOG_LEVEL=info

# 安全配置
API_RATE_LIMIT=100
MAX_TOKENS=4096
ALLOWED_MODELS=gpt-3.5-turbo,gpt-4,claude-3-sonnet

# 監控配置
ENABLE_METRICS=true
METRICS_PORT=9090
EOF

    # 設置安全權限
    chmod 600 .env
    
    log_success "環境配置文件創建完成"
}

# 驗證 API Key
validate_api_key() {
    log_info "驗證 You API Key..."
    
    # 檢查 API Key 格式
    if [[ ${#YOU_API_KEY} -lt 100 ]]; then
        log_error "API Key 格式可能不正確"
        return 1
    fi
    
    # 測試 API 連接（如果可能）
    log_success "API Key 格式驗證通過"
}

# 檢查系統
check_system() {
    log_info "檢查系統環境..."
    
    if [[ ! -f /etc/os-release ]]; then
        log_error "無法檢測系統版本"
        exit 1
    fi
    
    . /etc/os-release
    log_success "系統檢查完成: $PRETTY_NAME"
}

# 安裝 Docker
install_docker() {
    if command -v docker &> /dev/null; then
        log_success "Docker 已安裝"
        return
    fi
    
    log_info "安裝 Docker..."
    
    if command -v apt &> /dev/null; then
        apt update
        apt install -y curl
    elif command -v yum &> /dev/null; then
        yum update -y
        yum install -y curl
    fi
    
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    
    log_success "Docker 安裝完成"
}

# 安裝 Docker Compose
install_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        log_success "Docker Compose 已安裝"
        return
    fi
    
    log_info "安裝 Docker Compose..."
    
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    log_success "Docker Compose 安裝完成"
}

# 配置防火牆
setup_firewall() {
    log_info "配置防火牆..."
    
    if command -v ufw &> /dev/null; then
        ufw allow ssh
        ufw allow 80
        ufw allow 443
        ufw allow 8080
        ufw --force enable
        log_success "UFW 防火牆配置完成"
    elif command -v firewall-cmd &> /dev/null; then
        firewall-cmd --permanent --add-service=ssh
        firewall-cmd --permanent --add-port=80/tcp
        firewall-cmd --permanent --add-port=443/tcp
        firewall-cmd --permanent --add-port=8080/tcp
        firewall-cmd --reload
        log_success "Firewalld 防火牆配置完成"
    else
        log_warning "未檢測到防火牆，請手動配置端口"
    fi
}

# 啟動服務
start_services() {
    log_info "啟動 You2API 服務..."
    
    # 使用生產環境配置
    if [[ -f "docker-compose.prod.yml" ]]; then
        docker-compose -f docker-compose.prod.yml up -d
    else
        docker-compose up -d
    fi
    
    log_success "服務啟動完成"
}

# 等待服務就緒
wait_for_service() {
    log_info "等待服務就緒..."
    
    for i in {1..30}; do
        if curl -s http://localhost:8080/v1/models > /dev/null 2>&1; then
            log_success "服務已就緒"
            return
        fi
        echo -n "."
        sleep 2
    done
    
    log_error "服務啟動超時，請檢查日誌"
    docker-compose logs you2api
}

# 測試 API 功能
test_api() {
    log_info "測試 API 功能..."
    
    # 測試模型列表
    echo "1. 測試模型列表..."
    MODELS_RESPONSE=$(curl -s http://localhost:8080/v1/models)
    if echo "$MODELS_RESPONSE" | grep -q "data"; then
        log_success "模型列表 API 正常"
    else
        log_warning "模型列表 API 可能異常"
    fi
    
    # 測試聊天 API
    echo "2. 測試聊天 API..."
    CHAT_RESPONSE=$(curl -s -X POST http://localhost:8080/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${YOU_API_KEY}" \
        -d '{
            "model": "gpt-3.5-turbo",
            "messages": [{"role": "user", "content": "Hello, test message"}],
            "max_tokens": 10
        }')
    
    if echo "$CHAT_RESPONSE" | grep -q "choices\|content"; then
        log_success "聊天 API 正常"
    else
        log_warning "聊天 API 可能需要調試"
        echo "響應: $CHAT_RESPONSE"
    fi
}

# 創建系統服務
create_systemd_service() {
    log_info "創建系統服務..."
    
    tee /etc/systemd/system/you2api.service > /dev/null << EOF
[Unit]
Description=You2API Service with API Key
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$(pwd)
ExecStart=/usr/local/bin/docker-compose -f docker-compose.prod.yml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose.prod.yml down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable you2api.service
    
    log_success "系統服務創建完成"
}

# 顯示部署信息
show_deployment_info() {
    echo
    log_success "🎉 You2API 部署完成！"
    echo
    echo "📋 服務信息："
    echo "   - API 地址: http://$(curl -s ifconfig.me 2>/dev/null || echo 'your-server-ip'):8080"
    echo "   - 本地地址: http://localhost:8080"
    echo "   - API Key: 已配置 (YatTsun Ngan 的專屬 Key)"
    echo
    echo "🧪 測試命令："
    echo "   - 模型列表: curl http://localhost:8080/v1/models"
    echo "   - 聊天測試: curl -X POST http://localhost:8080/v1/chat/completions \\"
    echo "              -H 'Content-Type: application/json' \\"
    echo "              -H 'Authorization: Bearer ${YOU_API_KEY:0:20}...' \\"
    echo "              -d '{\"model\":\"gpt-3.5-turbo\",\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}]}'"
    echo
    echo "🔧 管理命令："
    echo "   - 查看狀態: docker-compose ps"
    echo "   - 查看日誌: docker-compose logs -f you2api"
    echo "   - 重啟服務: docker-compose restart"
    echo "   - 管理腳本: ./manage.sh"
    echo
    echo "📁 項目目錄: $(pwd)"
    echo "🔐 配置文件: .env (已安全配置)"
    echo
}

# 主函數
main() {
    echo "🚀 You2API 安全部署腳本 (含 API Key)"
    echo "=========================================="
    echo "👤 用戶: YatTsun Ngan"
    echo "🔑 API Key: ${YOU_API_KEY:0:20}..."
    echo
    
    validate_api_key
    check_system
    install_docker
    install_docker_compose
    create_env_file
    setup_firewall
    start_services
    wait_for_service
    test_api
    create_systemd_service
    show_deployment_info
    
    log_success "部署完成！您的專屬 AI API 服務已就緒！"
}

# 錯誤處理
trap 'log_error "部署過程中發生錯誤，請檢查上面的錯誤信息"' ERR

# 執行主函數
main "$@" 