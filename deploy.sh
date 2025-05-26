#!/bin/bash

# You2API VPS 一鍵部署腳本
# 作者：您的專屬程序員
# 版本：1.0

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# 檢查是否為 root 用戶
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_warning "建議不要使用 root 用戶運行此腳本"
        read -p "是否繼續？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# 檢查系統
check_system() {
    log_info "檢查系統環境..."
    
    if [[ ! -f /etc/os-release ]]; then
        log_error "無法檢測系統版本"
        exit 1
    fi
    
    . /etc/os-release
    
    if [[ "$ID" != "ubuntu" && "$ID" != "debian" && "$ID" != "centos" ]]; then
        log_warning "此腳本主要針對 Ubuntu/Debian/CentOS 系統測試"
    fi
    
    log_success "系統檢查完成: $PRETTY_NAME"
}

# 安裝 Docker
install_docker() {
    if command -v docker &> /dev/null; then
        log_success "Docker 已安裝"
        return
    fi
    
    log_info "安裝 Docker..."
    
    # 更新包管理器
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y curl
    elif command -v yum &> /dev/null; then
        sudo yum update -y
        sudo yum install -y curl
    fi
    
    # 安裝 Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    
    # 添加用戶到 docker 組
    sudo usermod -aG docker $USER
    
    log_success "Docker 安裝完成"
}

# 安裝 Docker Compose
install_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        log_success "Docker Compose 已安裝"
        return
    fi
    
    log_info "安裝 Docker Compose..."
    
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    log_success "Docker Compose 安裝完成"
}

# 創建項目目錄
setup_project() {
    log_info "設置項目目錄..."
    
    PROJECT_DIR="/opt/you2api"
    
    if [[ -d "$PROJECT_DIR" ]]; then
        log_warning "項目目錄已存在，是否重新部署？"
        read -p "繼續將會覆蓋現有配置 (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
        sudo rm -rf "$PROJECT_DIR"
    fi
    
    sudo mkdir -p "$PROJECT_DIR"
    sudo chown $USER:$USER "$PROJECT_DIR"
    cd "$PROJECT_DIR"
    
    log_success "項目目錄創建完成: $PROJECT_DIR"
}

# 克隆項目
clone_project() {
    log_info "克隆 You2API 項目..."
    
    if ! command -v git &> /dev/null; then
        log_info "安裝 Git..."
        if command -v apt &> /dev/null; then
            sudo apt install -y git
        elif command -v yum &> /dev/null; then
            sudo yum install -y git
        fi
    fi
    
    git clone https://github.com/bohesocool/you2api.git .
    
    log_success "項目克隆完成"
}

# 配置防火牆
setup_firewall() {
    log_info "配置防火牆..."
    
    if command -v ufw &> /dev/null; then
        sudo ufw allow ssh
        sudo ufw allow 80
        sudo ufw allow 443
        sudo ufw allow 8080
        sudo ufw --force enable
        log_success "UFW 防火牆配置完成"
    elif command -v firewall-cmd &> /dev/null; then
        sudo firewall-cmd --permanent --add-service=ssh
        sudo firewall-cmd --permanent --add-port=80/tcp
        sudo firewall-cmd --permanent --add-port=443/tcp
        sudo firewall-cmd --permanent --add-port=8080/tcp
        sudo firewall-cmd --reload
        log_success "Firewalld 防火牆配置完成"
    else
        log_warning "未檢測到防火牆，請手動配置端口 80, 443, 8080"
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

# 創建系統服務
create_systemd_service() {
    log_info "創建系統服務..."
    
    sudo tee /etc/systemd/system/you2api.service > /dev/null << EOF
[Unit]
Description=You2API Service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF
    
    sudo systemctl daemon-reload
    sudo systemctl enable you2api.service
    
    log_success "系統服務創建完成"
}

# 顯示部署信息
show_deployment_info() {
    echo
    log_success "🎉 You2API 部署完成！"
    echo
    echo "📋 服務信息："
    echo "   - API 地址: http://$(curl -s ifconfig.me):8080"
    echo "   - 本地地址: http://localhost:8080"
    echo "   - 健康檢查: curl http://localhost:8080/v1/models"
    echo
    echo "🔧 管理命令："
    echo "   - 查看狀態: docker-compose ps"
    echo "   - 查看日誌: docker-compose logs -f you2api"
    echo "   - 重啟服務: docker-compose restart"
    echo "   - 停止服務: docker-compose down"
    echo
    echo "📊 監控面板（如果啟用）："
    echo "   - Prometheus: http://$(curl -s ifconfig.me):9090"
    echo "   - Grafana: http://$(curl -s ifconfig.me):3000 (admin/admin123)"
    echo
    echo "📁 項目目錄: $PROJECT_DIR"
    echo
}

# 主函數
main() {
    echo "🚀 You2API VPS 一鍵部署腳本"
    echo "================================"
    echo
    
    check_root
    check_system
    install_docker
    install_docker_compose
    setup_project
    clone_project
    setup_firewall
    start_services
    wait_for_service
    create_systemd_service
    show_deployment_info
    
    log_success "部署完成！感謝您的信任！"
}

# 錯誤處理
trap 'log_error "部署過程中發生錯誤，請檢查上面的錯誤信息"' ERR

# 執行主函數
main "$@" 