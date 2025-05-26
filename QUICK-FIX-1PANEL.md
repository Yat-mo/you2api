# 🚨 1Panel 端口衝突快速修復指南

老闆您好！我看到您遇到了443端口衝突的問題。這是因為1Panel已經佔用了443端口。

## 🔧 立即修復步驟

### 1. 完全清理之前的部署（推薦）：

```bash
# 進入項目目錄
cd /root/you2api/you2api

# 拉取最新配置（包含清理腳本）
git pull origin main

# 徹底清理之前失敗的部署
chmod +x cleanup.sh
./cleanup.sh

# 使用1Panel專屬部署腳本重新部署
chmod +x deploy-1panel.sh
./deploy-1panel.sh
```

### 2. 快速修復（如果清理腳本不可用）：

```bash
# 進入項目目錄
cd /root/you2api/you2api

# 停止衝突的服務
docker-compose -f docker-compose.prod.yml down

# 拉取最新的1Panel適配配置
git pull origin main

# 使用1Panel專屬部署腳本
chmod +x deploy-1panel.sh
./deploy-1panel.sh
```

### 3. 手動清理（如果自動清理失敗）：

```bash
# 停止所有相關容器
docker stop you2api you2api-nginx you2api-prometheus you2api-grafana 2>/dev/null || true
docker rm you2api you2api-nginx you2api-prometheus you2api-grafana 2>/dev/null || true

# 只啟動API服務（避免端口衝突）
docker-compose -f docker-compose.1panel.yml up -d you2api
```

### 4. 驗證服務運行：

```bash
# 檢查服務狀態
docker ps | grep you2api

# 測試API
curl http://localhost:8080/v1/models
```

## 🎛️ 1Panel 反向代理設置

1. **登錄1Panel面板**
2. **網站 → 創建網站 → 反向代理**
   - 主域名: `your-domain.com`
   - 代理地址: `http://127.0.0.1:8080`
3. **啟用SSL證書**
4. **測試訪問**: `https://your-domain.com/v1/models`

## 📊 服務信息

- **API地址**: `http://your-vps-ip:8080`
- **健康檢查**: `http://localhost:8080/v1/models`
- **您的API Key**: 已安全配置
- **容器名稱**: `you2api`

## 🔍 故障排除

如果還有問題，請執行：

```bash
# 查看日誌
docker logs you2api

# 檢查端口佔用
netstat -tlnp | grep -E ":(80|443|8080) "

# 重啟服務
docker restart you2api
```

---

**這個配置專門為1Panel環境優化，避免了所有端口衝突！** 🎯 