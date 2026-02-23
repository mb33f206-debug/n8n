# n8n 免費雲端部署：HuggingFace Spaces + Supabase PostgreSQL

零成本將 n8n 工作流程自動化平台部署到雲端，隨時隨地存取你的自動化工作流程。

## 架構總覽

| 元件 | 服務 | 免費額度 |
|------|------|----------|
| n8n 應用程式 | HuggingFace Spaces (Docker) | 2 vCPU / 16GB RAM / 50GB Disk |
| 資料庫 | Supabase PostgreSQL | 500MB / 50,000 rows |

> **為什麼需要外部資料庫？** HuggingFace Spaces 閒置一段時間後會自動休眠，內建儲存會被清除。使用 Supabase 外部資料庫可以確保工作流程資料不會遺失。

---

## 步驟一：建立 Supabase 資料庫

### 1. 註冊帳號

前往 [supabase.com](https://supabase.com/dashboard/sign-up) 註冊（可用 GitHub 登入）。

### 2. 建立新專案

- 點擊 **New Project**
- 設定 **專案名稱**（例如 `n8n-db`）
- 設定 **資料庫密碼**（請記下來，稍後會用到）
- 選擇 **Region**（建議選離你最近的區域）
- 點擊 **Create new project**，等待建立完成

### 3. 取得連線資訊

1. 進入專案後，點擊左側 **Connect**（或 Project Settings → Database）
2. 選擇 **Transaction pooler** 區段
3. 記下以下資訊：

| 欄位 | 值 | 說明 |
|------|------|------|
| Host | `db.xxxxxxx.supabase.co` | 你的專案主機位址 |
| Port | `6543` | Transaction pooler 的 port |
| Database | `postgres` | 預設資料庫名稱 |
| User | `postgres.xxxxxxx` | 使用者名稱 |
| Password | 你剛設定的密碼 | 資料庫密碼 |

> **重要：** 請使用 **Transaction pooler** (port `6543`)，不要用 Direct connection (port `5432`)，因為 HuggingFace Spaces 的網路環境較適合使用 pooler 連線。

---

## 步驟二：產生加密金鑰

n8n 需要一個加密金鑰來保護你的 credentials 資料。在終端機執行：

```bash
openssl rand -base64 32
```

將產生的字串記下來，例如：`aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890+/=`

> 沒有 openssl？你也可以到 [隨機密碼產生器](https://www.random.org/strings/) 產生一組 32 字元以上的隨機字串。

---

## 步驟三：部署到 HuggingFace Spaces

### 1. 註冊 HuggingFace 帳號

前往 [huggingface.co/join](https://huggingface.co/join) 註冊，記住你的 **使用者名稱**（後面要用）。

### 2. 複製 n8n Space 模板

1. 前往模板頁面：[huggingface.co/spaces/tomowang/n8n](https://huggingface.co/spaces/tomowang/n8n)
2. 點擊右上角 **⋮** 選單 → **Duplicate this Space**

### 3. 填寫環境變數

在 Duplicate 彈出視窗中，設定以下 **Secrets**：

| 變數名稱 | 值 | 說明 |
|----------|------|------|
| `DB_POSTGRESDB_HOST` | `db.xxxxxxx.supabase.co` | Supabase 主機位址 |
| `DB_POSTGRESDB_PORT` | `6543` | Transaction pooler port |
| `DB_POSTGRESDB_USER` | `postgres.xxxxxxx` | Supabase 使用者名稱 |
| `DB_POSTGRESDB_PASSWORD` | 你的資料庫密碼 | Supabase 密碼 |
| `N8N_ENCRYPTION_KEY` | 步驟二產生的金鑰 | 加密金鑰 |
| `WEBHOOK_URL` | `https://<你的使用者名稱>-n8n.hf.space/` | Webhook 網址 |
| `N8N_EDITOR_BASE_URL` | `https://<你的使用者名稱>-n8n.hf.space/` | 編輯器網址 |
| `GENERIC_TIMEZONE` | `Asia/Taipei` | 時區設定 |
| `TZ` | `Asia/Taipei` | 系統時區 |

> **注意：** `WEBHOOK_URL` 和 `N8N_EDITOR_BASE_URL` 中的 `<你的使用者名稱>` 要替換成你的 HuggingFace 使用者名稱。例如使用者名稱是 `rex`，網址就是 `https://rex-n8n.hf.space/`。

### 4. 點擊 Duplicate Space

等待部署完成（第一次約需 3-5 分鐘），可以在 **Logs** 頁籤查看進度。

---

## 步驟四：存取你的 n8n

### 方法一：直接存取（推薦）

由於 n8n 使用 helmet 安全套件會阻擋 iframe 嵌入，建議直接在瀏覽器開啟：

```
https://<你的使用者名稱>-n8n.hf.space/
```

### 方法二：透過 HuggingFace Space 頁面

在 Space 頁面中可能會看到空白畫面，這是正常的（iframe 被阻擋），點擊右上角的外部連結圖示即可。

---

## 步驟五：驗證部署成功

1. 開啟 n8n 網址，你應該會看到 n8n 的設定畫面
2. 建立你的管理員帳號
3. 建立一個簡單的測試工作流程：
   - 新增 **Manual Trigger** 節點
   - 新增 **Set** 節點，設定一個測試值
   - 點擊 **Execute Workflow**
   - 確認資料正確傳遞
4. **重啟 Space** 後再次登入，確認工作流程還在（代表 Supabase 資料庫正常運作）

---

## 注意事項

### 休眠機制

HuggingFace Spaces 免費方案在閒置約 48 小時後會自動休眠。喚醒方式：

- 直接訪問你的 Space 網址
- 到 HuggingFace Space 頁面點擊 **Restart**

> **小技巧：** 可以使用 [UptimeRobot](https://uptimerobot.com/) 等免費監控服務，定時 ping 你的 Space 網址來防止休眠。

### 安全性建議

- `N8N_ENCRYPTION_KEY` 設定後**不要更改**，否則已儲存的 credentials 會無法解密
- 建議設定強密碼作為 n8n 管理員帳號
- 所有 secrets 請妥善保管，不要外洩

### 免費額度限制

| 服務 | 限制 |
|------|------|
| HuggingFace Spaces | 2 vCPU、16GB RAM、50GB 暫存磁碟 |
| Supabase | 500MB 資料庫、50,000 rows、500MB 頻寬/月 |

對於個人使用和小型自動化專案，這些額度通常綽綽有餘。

---

## 使用的 Dockerfile

本部署使用的 Dockerfile（由 [tomowang/n8n](https://huggingface.co/spaces/tomowang/n8n) 模板提供）：

```dockerfile
FROM node:18-alpine

RUN apk add --no-cache git python3 py3-pip make g++ build-base

ENV N8N_PORT=7860
ENV N8N_PROTOCOL=https

RUN npm install -g n8n

WORKDIR /data

EXPOSE 7860

CMD ["n8n", "start"]
```

> HuggingFace Spaces 要求應用程式監聽在 **port 7860**。

---

## 相關資源

- [n8n 官方文件](https://docs.n8n.io/)
- [HuggingFace Spaces 文件](https://huggingface.co/docs/hub/spaces-overview)
- [Supabase 文件](https://supabase.com/docs)
- [tomowang/n8n Space 模板](https://huggingface.co/spaces/tomowang/n8n)
- [tomo's blog - Deploy n8n for FREE](https://tomo.dev/en/posts/deploy-n8n-for-free-using-huggingface-space/)

---

## 授權

MIT License
