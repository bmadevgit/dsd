# server-info — bma-chatbot
> ⚠️ ไฟล์นี้เก็บเฉพาะ IP · path · port — **ห้ามใส่ password / API key ที่นี่**  
> Credentials อยู่ใน Bitwarden (ดู link ด้านล่าง)

---

## Servers

| ชื่อ | IP | Role |
|---|---|---|
| prod-01 | 10.x.x.x | production IIS |
| dev-01  | 10.x.x.x | development / test |

## Paths สำคัญ

| อะไร | Path |
|---|---|
| webroot | `C:\inetpub\wwwroot\chatbot\` |
| PHP config | `C:\PHP\php.ini` |
| IIS logs | `C:\inetpub\logs\LogFiles\` |
| app config | `C:\inetpub\wwwroot\chatbot\config.php` |
| upload dir | `C:\inetpub\wwwroot\chatbot\uploads\` |

## Ports / Services

| Service | Port | หมายเหตุ |
|---|---|---|
| IIS HTTP | 80 | |
| IIS HTTPS | 443 | |
| MySQL | 3306 | localhost only |
| PHP-FPM | 9000 | |

## Credentials
- Bitwarden item: `[ใส่ชื่อ item ใน Bitwarden]`
- หรือ vault path: `bma / chatbot / prod-01`

## Deployment checklist
- [ ] backup database ก่อน deploy
- [ ] ตรวจ web.config ว่า `<remove>` ก่อน `<add>` เสมอ
- [ ] restart IIS หลัง deploy: `iisreset`
- [ ] ตรวจ PHP error log หลัง deploy 5 นาที

