# BMA HouseID Reverse Proxy (`bma-houseid`)

- **Path:** `C:\inetpub\bma-houseid-proxy` (เป็น IIS Application นอก wwwroot)
- **URL:** `/bma-houseid` ผ่าน Default Web Site
- **Type:** ไม่ใช่แอป — เป็น **URL Rewrite reverse proxy**

## หน้าที่

แค่ rewrite ทุก request ไปที่ปลายทางจริง:

```xml
<rule name="BMA HouseID Reverse Proxy" stopProcessing="true">
  <match url="(.*)" />
  <action type="Rewrite"
          url="https://gidapp.bangkok.go.th/bma-houseid/{R:1}"
          appendQueryString="true"
          logRewrittenUrl="true" />
</rule>
```

ดู [bma-houseid-proxy/web.config](C:/inetpub/bma-houseid-proxy/web.config)

## Tooling/data ที่เกี่ยวข้อง (อยู่ใน `C:\codex`)

- `export_bma_houseid_full.ps1` — export เต็มจากต้นทาง
- `run_bma_houseid_chunked.ps1` — รันแบบแบ่ง chunk
- `bma-houseid-all-full.csv` + `.gaps.json` — output ฉบับเต็ม
- `bma-houseid-test-1005-v1.csv`, `bma-houseid-test-1028-{v1..v5}.csv` (+ `.gaps.json`) — test snapshots
- `bma-houseid-index-data.csv`

## ต้องการ ARR

IIS Application Request Routing + URL Rewrite extension ต้องเปิด proxy mode (`Server Farms` → `Application Request Routing Cache` → enable proxy)
