<style>
@import url("https://fonts.googleapis.com/css2?family=LXGW+WenKai+TC:wght@300;400;700&display=swap");
.markdown-body {
  font-family: "Times New Roman", "LXGW WenKai TC", serif;
  font-size: 16px;
  line-height: 1.9;
}
.markdown-body h1, .markdown-body h2, .markdown-body h3 {
  font-family: "LXGW WenKai TC", "Times New Roman", serif;
  font-weight: 700;
}
.markdown-body blockquote {
  border-left: 4px solid #6c5ce7;
  background: #f8f9fa;
  padding: 12px 20px;
}
.markdown-body code {
  font-family: "Cascadia Code", "Fira Code", monospace;
}
.markdown-body table {
  font-size: 15px;
}
.markdown-body img {
  max-width: 100%;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  margin: 16px 0;
}
</style>

# n8n 免費雲端部署：HuggingFace Spaces + Supabase PostgreSQL

> 手把手教你用 HuggingFace Spaces + Supabase PostgreSQL 免費部署 n8n 工作流程自動化平台。從申辦帳號、建立資料庫、設定環境變數到啟用 License Key，全程圖文教學，零成本、零基礎也能上手。

---

## 架構總覽

我們要做的事情很簡單：把 n8n 跑在 HuggingFace 的免費 Docker 空間上，資料庫則用 Supabase 的免費 PostgreSQL。

| 元件 | 服務 | 免費額度 |
|------|------|----------|
| n8n 應用程式 | HuggingFace Spaces (Docker) | 2 vCPU / 16GB RAM / 50GB Disk |
| 資料庫 | Supabase PostgreSQL | 500MB / 50,000 rows |

> **為什麼需要外部資料庫？** HuggingFace Spaces 閒置後會自動休眠，內建儲存會被清除。接上 Supabase 外部資料庫，你的工作流程和設定才不會消失。

---

## 步驟一：申辦帳號

開始之前，先準備好兩個免費帳號：

- **HuggingFace**：到 [huggingface.co/join](https://huggingface.co/join) 註冊，可以直接用 GitHub 登入。記住你的**使用者名稱**，等等會用到。
- **Supabase**：到 [supabase.com/dashboard/sign-up](https://supabase.com/dashboard/sign-up) 註冊，一樣建議用 GitHub 登入。

---

## 步驟二：建立 Supabase 資料庫

### 1. 建立 Organization 與新專案

登入 Supabase 後，先建一個 Organization（組織），然後點右上角的 **+ New project**。

<img src="pic/supabase/001.png" width="700">

### 2. 設定專案資訊

在建立專案的頁面，填好以下資料：

- **Organization**：選剛才建的那個，免費方案就好
- **Project name**：填 `n8n`（或你喜歡的名稱）
- **Database password**：設一組強密碼，然後**點 Copy 複製起來，貼到安全的地方**
- **Region**：選 `Asia-Pacific`

> ⚠️ **Database password 非常重要！** 等等設定 HuggingFace 環境變數一定會用到，忘了就要重設。

其他 Security 設定維持預設，點 **Create new project** 就完成了。

<img src="pic/supabase/003.png" width="500">

---

## 步驟三：取得 Supabase 連線資訊

### 1. 點擊 Connect

專案建好後，點頂部導覽列右上角的 **Connect**。

<img src="pic/supabase/004.png" width="700">

### 2. 記下連線參數

在彈出的面板裡：

1. **Type** 選 `SQLAlchemy`
2. **Method** 選 `Transaction pooler`
3. 往下看第 3 區塊 **Connect to your database**

<img src="pic/supabase/005.png" width="700">

把以下五個參數記下來，等等設定 HuggingFace 會全部用到：

| 參數 | 範例 | 說明 |
|------|------|------|
| **user** | `postgres.xxxxxxxx` | 使用者名稱 |
| **password** | 你步驟二設的密碼 | 記得替換 `[YOUR-PASSWORD]` |
| **host** | `aws-1-ap-southeast-2.pooler.supabase.com` | 主機位址 |
| **port** | `6543` | Transaction pooler 的 port |
| **dbname** | `postgres` | 資料庫名稱 |

> 點 **View parameters** 可以一個一個看得更清楚。

---

## 步驟四：產生加密金鑰

n8n 會用一組加密金鑰來保護你存的 API Key 和帳密。打開終端機跑這行：

```bash
openssl rand -base64 32
```

把產生的那串亂碼記下來，等等要填進 HuggingFace。

> 沒裝 openssl？到 [隨機密碼產生器](https://www.random.org/strings/) 生一組 32 字元以上的字串也行。

---

## 步驟五：部署到 HuggingFace Spaces

### 1. 搜尋 n8n 模板

登入 HuggingFace，點上方的 **Spaces**，搜尋 `n8n`，排序選 **Most likes**，找到 **baoyin2024** 的 N8n 空間，點進去。

<img src="pic/huggingface/001.png" width="700">

### 2. Duplicate this Space

進去後點右上角 **⋮** → **Duplicate this Space**。

<img src="pic/huggingface/002.png" width="300">

### 3. 設定環境變數

這步最關鍵！Duplicate 視窗會帶入模板預設值，但**紅框的欄位都要改成你自己的**：

<img src="pic/huggingface/003.png" width="500">

下圖是填好之後的對照，上面是 Supabase 的連線字串，對照著填就對了：

<img src="pic/huggingface/004.png" width="500">

#### 基本設定

- **Owner**：你的 HuggingFace 帳號
- **Space name**：`n8n-free`（或自訂）
- **Visibility**：`Public`
- **Space hardware**：`Free`

#### Secrets（私密，3 個都要改）

| 變數 | 改成 | 說明 |
|------|------|------|
| `DB_POSTGRESDB_PASSWORD` | 你的 Supabase 密碼 | 步驟二設的那組 |
| `DB_POSTGRESDB_USER` | 你的 Supabase user | 像 `postgres.xxxxxxxx` |
| `N8N_ENCRYPTION_KEY` | 步驟四產生的金鑰 | **千萬別用預設的 `n8n`** |

#### Variables（公開，7 個要改）

| 變數 | 改成 | 說明 |
|------|------|------|
| `GENERIC_TIMEZONE` | `Asia/Taipei` | 時區 |
| `TZ` | `Asia/Taipei` | 系統時區 |
| `DB_POSTGRESDB_HOST` | 你的 Supabase host | 步驟三記的那個 |
| `DB_POSTGRESDB_PORT` | `6543` | ⚠️ 預設 5432 要改！ |
| `N8N_EDITOR_BASE_URL` | `https://<帳號>-n8n-free.hf.space` | 換成你的帳號 |
| `WEBHOOK_URL` | `https://<帳號>-n8n-free.hf.space` | 同上 |
| `N8N_HOST` | `https://<帳號>-n8n-free.hf.space` | 同上 |

> ⚠️ **三個最常犯的錯：**
> 1. `N8N_ENCRYPTION_KEY` 沒改，還是預設的 `n8n` → credentials 等於沒加密
> 2. `DB_POSTGRESDB_PORT` 沒從 `5432` 改成 `6543` → 連不上資料庫
> 3. 三個網址忘了換帳號 → webhook 和編輯器網址錯誤

其他變數（`DB_TYPE`、`N8N_PORT`、`EXECUTIONS_DATA_*` 等等）維持預設就好，不用動。

全部填好，按下 **Duplicate Space** 開始部署！

### 4. 等待部署完成

點上方 **Logs** → **Container**，可以看編譯進度。第一次會比較久，耐心等。

看到這行就代表成功了：

```text
Editor is now accessible via:
https://<你的帳號>-n8n-free.hf.space
```

> ⚠️ 請直接在瀏覽器開這個網址，不要用 HuggingFace 內嵌的畫面（會被 n8n 的安全機制擋住）。

<img src="pic/huggingface/005.png" width="700">

---

## 步驟六：設定 n8n 管理員帳號

### 1. 建立帳號

打開你的 n8n 網址，會看到 **Set up owner account** 畫面。

這邊要注意 **Email 要填能收信的**，等等需要用來接收 License Key。密碼要求 8 字元以上、至少 1 個數字和 1 個大寫字母。填好按 **Next**。

<img src="pic/huggingface/006.png" width="400">

### 2. 填寫問卷

會有一份簡單問卷，隨便填就好，不影響功能。

### 3. 申請免費 License Key

問卷結束後會看到 **Get paid features for free (forever)**，可以免費解鎖幾個實用功能：

- **Advanced debugging** — 錯誤的工作流可以直接重跑
- **Execution search and tagging** — 搜尋歷史執行記錄
- **Folders** — 用資料夾整理工作流程

填入 Email 後按 **Send me a free license key**，或按 Skip 之後再弄。

<img src="pic/huggingface/007.png" width="400">

### 4. 啟用 License Key

送出後右下角會跳通知，點 **usage and plan** 進入啟用頁面。

<img src="pic/huggingface/008.png" width="350">

去信箱找 n8n.io 寄來的信，複製 **Your license key**：

> 如果錯過了通知，從 **Settings → Usage and plan → Enter activation key** 也能進去。License key 有 **14 天**啟用期限，別忘了。

<img src="pic/huggingface/010.png" width="500">

回到 n8n，點 **Enter activation key**，貼上 key，按 **Activate** 完成。

<img src="pic/huggingface/009.png" width="700">

---

## 步驟七：開始使用吧！

啟用完成，回到首頁就能建立你的第一個工作流程了！

> **關於速度：** 免費方案跑起來會有點卡，這是正常的。拿來做 Email 通知、RSS 訂閱之類的輕量工作流完全夠用。
>
> 如果需要更好的效能，可以考慮自建伺服器。站長 **@harry123180** 有樹莓派自建 n8n 的教學，有興趣可以找他。

---

## 注意事項

### 休眠機制

HuggingFace 免費方案閒置約 48 小時會自動休眠。要喚醒的話直接訪問 Space 網址，或到 HuggingFace 點 **Restart** 就好。

> **防休眠小技巧：** 用 [UptimeRobot](https://uptimerobot.com/) 之類的免費監控服務定時 ping 你的網址。

### 安全性

- `N8N_ENCRYPTION_KEY` 設了就**別再改**，不然之前存的 API Key 全部解不開
- n8n 管理員帳號請用強密碼

### 免費額度

| 服務 | 限制 |
|------|------|
| HuggingFace Spaces | 2 vCPU、16GB RAM、50GB 暫存磁碟 |
| Supabase | 500MB 資料庫、50,000 rows、500MB 頻寬/月 |

個人用、小型自動化，這些額度綽綽有餘。

---

## 相關資源

- [n8n 官方文件](https://docs.n8n.io/)
- [HuggingFace Spaces 文件](https://huggingface.co/docs/hub/spaces-overview)
- [Supabase 文件](https://supabase.com/docs)
- [baoyin2024/n8n Space 模板](https://huggingface.co/spaces/baoyin2024/n8n-free)
