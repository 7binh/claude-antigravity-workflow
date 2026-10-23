#!/usr/bin/env node
// validate.mjs — kiểm tra cấu trúc repo skills, không cần cài thư viện.
// Chạy: node scripts/validate.mjs
// Kiểm tra: frontmatter, name == tên thư mục, kebab-case, công thức description,
// độ dài, script có cú pháp bash hợp lệ, tham chiếu references/ tồn tại, bản sao mẫu không lệch.
import { readdirSync, readFileSync, statSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const skillsDir = join(root, 'skills');
let errors = 0, warns = 0;
const err = (m) => { errors++; console.error(`  ✗ ${m}`); };
const warn = (m) => { warns++; console.warn(`  ! ${m}`); };

function walk(dir) {
  return readdirSync(dir).flatMap((n) => {
    const p = join(dir, n);
    return statSync(p).isDirectory() ? walk(p) : [p];
  });
}

function parseFrontmatter(text) {
  const m = text.replace(/\r\n/g, '\n').match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
  if (!m) return null;
  const fields = {};
  for (const line of m[1].split('\n')) {
    const kv = line.match(/^([A-Za-z_][\w-]*):\s*(.*)$/);
    if (kv) fields[kv[1]] = kv[2];
    else if (line.trim() && !/^\s/.test(line)) return { error: `dòng frontmatter không hợp lệ: "${line}"` };
  }
  return { fields, body: m[2] };
}

const skills = readdirSync(skillsDir).filter((n) => statSync(join(skillsDir, n)).isDirectory()).sort();
console.log(`Tìm thấy ${skills.length} skill\n`);
const seen = new Set();

for (const s of skills) {
  console.log(`• ${s}`);
  const dir = join(skillsDir, s);
  const file = join(dir, 'SKILL.md');
  if (!existsSync(file)) { err('thiếu SKILL.md'); continue; }
  const fm = parseFrontmatter(readFileSync(file, 'utf8'));
  if (!fm) { err('không có frontmatter YAML (---)'); continue; }
  if (fm.error) { err(fm.error); continue; }
  const { name, description } = fm.fields;

  if (!name) err('thiếu name');
  else {
    if (name !== s) err(`name "${name}" khác tên thư mục "${s}"`);
    if (!/^[a-z0-9]+(-[a-z0-9]+)*$/.test(name)) err(`name "${name}" không phải kebab-case`);
    if (seen.has(name)) err(`name "${name}" bị trùng`);
    seen.add(name);
  }
  if (!description) err('thiếu description');
  else {
    if (/^["'>|]/.test(description)) warn('description dùng dấu nháy hoặc block scalar; kiểm tra lại YAML');
    else if (/: /.test(description)) err('description chứa ": " ngoài dấu nháy, YAML sẽ lỗi');
    if (/ #/.test(description)) err('description chứa " #", YAML sẽ coi là comment');
    if (description.length > 1024) err(`description dài ${description.length} ký tự (tối đa 1024)`);
    if (!/Dùng (khi|ngay|mỗi|sau|trước)/.test(description)) warn('description thiếu mệnh đề "Dùng khi ..."');
    if (!/Không dùng/.test(description)) warn('description thiếu mệnh đề "Không dùng ..."');
  }

  const bodyLines = fm.body.split('\n').length;
  if (bodyLines > 90) warn(`thân SKILL.md dài ${bodyLines} dòng (khuyến nghị khoảng 80)`);
  for (const sect of ['## Mục tiêu', '## Các bước', '## Điều kiện dừng']) {
    if (!fm.body.includes(sect)) warn(`thiếu mục "${sect}"`);
  }

  // file hỗ trợ
  for (const f of walk(dir)) {
    const base = f.split(/[\\/]/).pop();
    if (base.startsWith('_')) err(`${f.replace(root + '/', '')}: tên bắt đầu bằng "_" sẽ bị CLI loại khỏi bản cài`);
    if (f.endsWith('.sh')) {
      const r = spawnSync('bash', ['-n', f], { encoding: 'utf8' });
      if (r.status !== 0) err(`${base}: lỗi cú pháp bash: ${r.stderr.trim()}`);
      if (readFileSync(f, 'utf8').includes('\r')) err(`${base}: có ký tự CR (CRLF), bash sẽ lỗi`);
    }
  }
  for (const ref of fm.body.matchAll(/\b(references|assets|scripts)\/([\w./-]+\.\w+)/g)) {
    if (!existsSync(join(dir, ref[1], ref[2]))) err(`tham chiếu ${ref[1]}/${ref[2]} không tồn tại`);
  }
}

// Bản sao mẫu phải khớp nhau
const pairs = [
  ['skills/report-writer/references/REPORT_TEMPLATE.md', 'skills/workflow-bootstrap/assets/templates/REPORT.md'],
];
console.log('\n• đồng bộ bản sao');
for (const [a, b] of pairs) {
  if (readFileSync(join(root, a), 'utf8') !== readFileSync(join(root, b), 'utf8')) err(`${a} khác ${b}`);
}

// Workflow phải nhỏ hơn 4000 ký tự và chỉ gọi skill có thật
console.log('\n• workflows');
const wfDir = join(skillsDir, 'workflow-bootstrap', 'assets', 'workflows');
for (const f of readdirSync(wfDir)) {
  const t = readFileSync(join(wfDir, f), 'utf8');
  if (t.length > 4000) err(`${f}: ${t.length} ký tự (tối đa 4000)`);
  for (const m of t.matchAll(/skill ([a-z][a-z0-9-]+)/g)) {
    if (!seen.has(m[1])) err(`${f}: gọi skill "${m[1]}" không tồn tại`);
  }
  for (const m of t.matchAll(/\.agents\/skills\/([a-z0-9-]+)\/(scripts\/[\w.]+)/g)) {
    if (!existsSync(join(skillsDir, m[1], m[2]))) err(`${f}: script ${m[1]}/${m[2]} không tồn tại`);
  }
}

const agents = readFileSync(join(skillsDir, 'workflow-bootstrap/assets/AGENTS.md'), 'utf8').split('\n').length;
console.log(`\n• AGENTS.md mẫu: ${agents} dòng`);
if (agents > 60) err(`AGENTS.md dài ${agents} dòng (tối đa 60)`);

console.log(`\n${errors} lỗi, ${warns} cảnh báo`);
process.exit(errors ? 1 : 0);
