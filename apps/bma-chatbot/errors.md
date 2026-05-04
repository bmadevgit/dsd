# errors — bma-chatbot
> Log ปัญหาที่เจอ — เขียนตอนเจอ แก้ทีหลังได้

---

## 🔴 ยังไม่แก้ (pending)

### [ERR-001] ชื่อ error หรืออาการสั้นๆ
- **วันที่:** yyyy-mm-dd
- **ไฟล์/เส้นทาง:** `C:\inetpub\wwwroot\chatbot\...`
- **อาการ:** อธิบายว่าเกิดอะไร เห็นอะไรบน screen
- **reproduce:** ทำยังไงถึงเจอ error นี้ซ้ำ
- **suspect:** คิดว่าน่าจะมาจากอะไร (ใส่ถ้ามี ไม่มีก็ข้ามได้)
- **log snippet:**
```
วาง error message / stack trace ที่นี่
```
- **ref:** #todo-item หรือ link อื่น

---

## 🟡 กำลังแก้ / รอ test


---

## ✅ แก้แล้ว

### [ERR-XXX] ชื่อ error
- **แก้วันที่:** yyyy-mm-dd
- **root cause:** 
- **วิธีแก้:**
```
code หรือ config ที่เปลี่ยน
```
- **หมายเหตุ:** สิ่งที่ควรระวังในอนาคต

---

## 📋 known gotchas (อย่าลืม)
- **IIS 500.19** — ต้อง `<remove value="..."/>` ก่อน `<add>` ใน defaultDocument เสมอ
- **PHP `??` + in_array** — ต้องใส่ `??` ทั้งสองฝั่งของ in_array() กัน DivisionByZero เมื่อ `$_GET` key หาย
- เพิ่มเองได้ที่นี่

