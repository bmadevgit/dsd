# BMA Data Lake Portal (`bma-lake`)

- **Path:** `C:\inetpub\wwwroot\lake`
- **Public URL:** `https://172.27.15.6/lake/`
- **Stack:** Next.js 14 · React 18 · Tailwind 3 · TypeScript 5
- **Process:** PM2 (`bma-lake`, port 3000) → IIS ARR proxy
- **DB:** dual — CKAN PostgreSQL (read-only, `pg`) + lake MySQL (write, `mysql2`)
- **Auth:** NextAuth + bcrypt
- **AI:** vLLM gateway `http://172.27.15.60:8000/v1`, model `Qwen/Qwen3-14B`

## Structure

```
src/app/
├── (public)/        # public routes
│   ├── datasets/
│   ├── organizations/
│   └── page.tsx
├── admin/           # admin console
│   ├── datasets/
│   ├── login/
│   ├── organizations/
│   └── source-checks/
├── api/             # route handlers
│   ├── ai/
│   ├── auth/        # NextAuth
│   ├── datasets/
│   ├── files/
│   ├── organizations/
│   ├── resources/
│   └── stats/
└── layout.tsx
```

## Run

```powershell
# Build
cd C:\inetpub\wwwroot\lake
npm run build

# Start (already managed by PM2)
pm2 restart bma-lake
pm2 logs bma-lake
```

PM2 config: [ecosystem.config.js](C:/inetpub/wwwroot/lake/ecosystem.config.js)
- Output dir: `.next/standalone/server.js`
- Logs: `C:\inetpub\lake-data\pm2-{out,error}.log`
- Env: `NEXTAUTH_URL=https://172.27.15.6/lake`, `AI_GATEWAY_URL`, `AI_MODEL=Qwen/Qwen3-14B`

## IIS reverse proxy

[lake/web.config](C:/inetpub/wwwroot/lake/web.config) — Force HTTPS + URL rewrite ทุก path ไป `http://localhost:3000/lake/...`, มี outbound rule แก้ `Location` header
