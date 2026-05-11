# Hermes Agent — server-a

ติดตั้ง [Hermes Agent](https://hermes-agent.nousresearch.com/) (NousResearch) บน Windows Server 2025 ใช้งาน AI Gateway ภายใน ไม่กระทบ IIS/MySQL ที่รันอยู่

## Environment

| Component | ค่า |
|---|---|
| OS | Windows Server 2025 |
| Hermes API Server | http://localhost:**8080** |
| AI Gateway | http://100.99.107.27:8000/v1 |
| Model default | Qwen/Qwen3-14B |
| IIS | port 80/443 (ไม่ถูกกระทบ) |
| MySQL | port 3306 (ไม่ถูกกระทบ) |

## โครงสร้างไฟล์

```
server-a/hermes/
├── README.md
├── install.ps1              ← รัน script เดียวติดตั้งทุกอย่าง
├── config.yaml              ← Hermes config template
├── .env.example             ← ตัวอย่าง environment variables
├── tasks/
│   ├── hermes-gateway.bat   ← batch ที่ Task Scheduler เรียก
│   ├── setup-task.ps1       ← สร้าง Scheduled Task
│   └── remove-task.ps1      ← ลบ Scheduled Task
└── skills/
    ├── iis-monitor/         ← ตรวจ IIS sites & app pools
    ├── mysql-monitor/       ← ตรวจ MySQL status
    └── server-dashboard/    ← dashboard รวมทุกอย่าง
```

## การติดตั้ง

### ขั้นตอนเดียว (PowerShell as Administrator)

```powershell
cd C:\path\to\server-a\hermes
.\install.ps1
```

Script นี้จะ:
1. ตรวจ prerequisite (Git, network ถึง AI Gateway)
2. ติดตั้ง Hermes Agent (official installer จาก NousResearch)
3. Copy `config.yaml` → `%LOCALAPPDATA%\hermes\config.yaml`
4. Copy `.env.example` → `%LOCALAPPDATA%\hermes\.env`
5. Copy custom skills → `%LOCALAPPDATA%\hermes\skills\`
6. ติดตั้ง `official/browser-use` skill
7. สร้าง Windows Scheduled Task "Hermes Gateway" (auto-start on boot)

### ตั้งค่าหลัง install

1. แก้ไข API key (ถ้า gateway ต้องการ):
   ```
   %LOCALAPPDATA%\hermes\.env
   HERMES_API_KEY=your-key-here
   ```

2. เปลี่ยน model (ถ้าต้องการ):
   ```powershell
   hermes model
   ```

3. ทดสอบ:
   ```powershell
   hermes -q "สวัสดี"
   ```

## VSCode Extension

1. เปิด VSCode → Extensions (`Ctrl+Shift+X`)
2. ค้นหา **"Hermes AI Agent"** โดย `joaompfp`
3. Install
4. Click ไอคอน Hermes ในแถบ Activity Bar ด้านซ้าย
5. ส่งข้อความทดสอบ

> Hermes gateway ต้องรันก่อน (Scheduled Task จะ start อัตโนมัติ)

## Skills ที่ติดตั้ง

| Skill | Trigger | ความสามารถ |
|---|---|---|
| **iis-monitor** | "check IIS", "ตรวจ IIS" | แสดง IIS sites/app pools (read-only) |
| **mysql-monitor** | "check MySQL", "ตรวจ MySQL" | connections, uptime, databases (read-only) |
| **server-dashboard** | "check server", "/dashboard" | ภาพรวม server ทั้งหมด |
| **browser-use** | "browse ...", "search web" | เปิด browser, เข้าเว็บ, อ่านหน้าเว็บ |

## Scheduled Task Management

```powershell
# ดู status
Get-ScheduledTask -TaskName "Hermes Gateway"

# Start manually
Start-ScheduledTask -TaskName "Hermes Gateway"

# Stop
Stop-ScheduledTask -TaskName "Hermes Gateway"

# ลบทิ้ง
.\tasks\remove-task.ps1
```

## Verification

```powershell
# 1. ตรวจ install
hermes doctor

# 2. ทดสอบ AI Gateway
hermes -q "สวัสดี"

# 3. ทดสอบ API Server
Invoke-WebRequest http://localhost:8080/health

# 4. ทดสอบ IIS skill
# ใน hermes chat: "check IIS status"

# 5. ทดสอบ MySQL skill
# ใน hermes chat: "check MySQL status"
```

## ข้อควรระวัง

- Hermes ใช้ port **8080** เท่านั้น ไม่ชนกับ IIS (80/443) หรือ MySQL (3306)
- Skills เป็น read-only ทั้งหมด ไม่แก้ IIS config / MySQL data
- Hermes ติดตั้งใน `%LOCALAPPDATA%\hermes\` แยกออกจาก `C:\inetpub\`
