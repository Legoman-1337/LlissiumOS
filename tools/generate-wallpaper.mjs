// Генератор обоев "Deep Eclipse" для LlissiumOS.
// Чистый Node.js без зависимостей: рисует RGBA-буфер и кодирует PNG (zlib).
// Запуск: node tools/generate-wallpaper.mjs
import zlib from 'node:zlib';
import fs from 'node:fs';
import path from 'node:path';

const W = Number(process.argv[2] ?? 1920), H = Number(process.argv[3] ?? 1080);
// Палитра темы: фон #08040C, пурпур #C026D3, янтарь #F59E0B
const BG_TOP = [8, 4, 12];
const BG_BOTTOM = [26, 10, 38];
const MAGENTA = [192, 38, 211];
const AMBER = [245, 158, 11];
const CX = W * 0.62, CY = H * 0.42;   // центр затмения
const R_CORE = 120;                    // радиус "луны"
const R_GLOW = 560;                    // радиус короны
let seed = 20261101;
const rnd = () => (seed = (seed * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff;

const px = new Uint8Array(W * H * 4);
const put = (x, y, r, g, b) => {
  const i = (y * W + x) * 4;
  px[i] = Math.min(255, r | 0); px[i + 1] = Math.min(255, g | 0);
  px[i + 2] = Math.min(255, b | 0); px[i + 3] = 255;
};
const lerp = (a, b, t) => a + (b - a) * t;

for (let y = 0; y < H; y++) {
  const ty = y / (H - 1);
  // фон: вертикальный градиент
  let r = lerp(BG_TOP[0], BG_BOTTOM[0], ty);
  let g = lerp(BG_TOP[1], BG_BOTTOM[1], ty);
  let b = lerp(BG_TOP[2], BG_BOTTOM[2], ty);
  // лёгкое боковое свечение по горизонтали к центру
  const dx = (x => x)(0);
  for (let x = 0; x < W; x++) {
    const d = Math.hypot(x - CX, y - CY);
    // корона: внешняя пурпурная и внутренняя янтарная
    const glowM = Math.max(0, 1 - d / R_GLOW) ** 3;
    const glowA = Math.max(0, 1 - d / (R_CORE * 3.2)) ** 4;
    // тонкая полоса лимба вокруг луны
    const limb = Math.exp(-Math.abs(d - R_CORE) / 6) * 0.9;
    // тёмный диск "луны"
    const moon = d < R_CORE ? 1 : 0;
    let rr = r + MAGENTA[0] * glowM * 0.55 + AMBER[0] * (glowA * 0.35 + limb * 0.5);
    let gg = g + MAGENTA[1] * glowM * 0.55 + AMBER[1] * (glowA * 0.35 + limb * 0.5);
    let bb = b + MAGENTA[2] * glowM * 0.55 + AMBER[2] * (glowA * 0.35 + limb * 0.5);
    if (moon) { rr = 4; gg = 2; bb = 6; }
    put(x, y, rr, gg, bb);
  }
}
// звёзды
for (let n = 0; n < 900; n++) {
  const x = (rnd() * W) | 0, y = (rnd() * H) | 0;
  const d = Math.hypot(x - CX, y - CY);
  if (d < R_CORE + 12) continue;
  const v = 40 + rnd() * 150;
  put(x, y, v * 0.95, v * 0.85, v);
  if (rnd() > 0.85) { put(x + 1, y, v * 0.5, v * 0.45, v * 0.55); put(x, y + 1, v * 0.5, v * 0.45, v * 0.55); }
}

// PNG-энкодер: IHDR + IDAT (фильтр 0 на строку) + IEND
const chunks = [];
const sig = Buffer.from([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
const chunk = (type, data) => {
  const len = Buffer.alloc(4); len.writeUInt32BE(data.length);
  const t = Buffer.from(type, 'ascii');
  const crc = Buffer.alloc(4); crc.writeUInt32BE(zlib.crc32 ? zlib.crc32(Buffer.concat([t, data])) : crc32(Buffer.concat([t, data])));
  return Buffer.concat([len, t, data, crc]);
};
// zlib.crc32 есть в Node >= 20.12; на всякий случай свой CRC
let crcTable;
function crc32(buf) {
  if (!crcTable) {
    crcTable = [];
    for (let n = 0; n < 256; n++) { let c = n; for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1; crcTable[n] = c >>> 0; }
  }
  let c = 0xffffffff;
  for (const byte of buf) c = crcTable[(c ^ byte) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}
const ihdr = Buffer.alloc(13);
ihdr.writeUInt32BE(W, 0); ihdr.writeUInt32BE(H, 4);
ihdr[8] = 8; ihdr[9] = 6; // 8 бит, RGBA
const raw = Buffer.alloc((W * 4 + 1) * H);
for (let y = 0; y < H; y++) {
  raw[y * (W * 4 + 1)] = 0;
  Buffer.from(px.buffer, y * W * 4, W * 4).copy(raw, y * (W * 4 + 1) + 1);
}
const png = Buffer.concat([sig, chunk('IHDR', ihdr), chunk('IDAT', zlib.deflateSync(raw, { level: 9 })), chunk('IEND', Buffer.alloc(0))]);

const outDir = path.dirname(process.argv[4] ? path.resolve(process.argv[4]) : path.resolve('archiso/airootfs/usr/share/wallpapers/deep-eclipse/contents/images/1920x1080.png'));
const outFile = path.basename(process.argv[4] ?? '1920x1080.png');
fs.mkdirSync(outDir, { recursive: true });
const out = path.join(outDir, outFile);
fs.writeFileSync(out, png);
console.log('OK:', out, (png.length / 1024 / 1024).toFixed(2) + ' MiB');
