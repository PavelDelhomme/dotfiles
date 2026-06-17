import test from 'node:test';
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdtempSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const bin = join(root, '../../bin/dotcli-tui');

function runMenu(extraArgs, input = '') {
  try {
    const stdout = execFileSync(bin, ['menu', ...extraArgs], {
      encoding: 'utf8',
      input,
      env: { ...process.env, DOTFILES_DOTCLI_MENU_NO_TUI: '1' },
    });
    return { code: 0, stdout: stdout.trim(), stderr: '' };
  } catch (err) {
    return {
      code: err.status ?? 1,
      stdout: (err.stdout ?? '').trim(),
      stderr: (err.stderr ?? '').trim(),
    };
  }
}

test('doctor exits 0', () => {
  const out = execFileSync(bin, ['doctor'], { encoding: 'utf8' });
  assert.match(out, /dotcli-tui doctor/);
});

test('menu simulate-index', () => {
  const dir = mkdtempSync(join(tmpdir(), 'dotcli-tui-'));
  const file = join(dir, 'menu.txt');
  writeFileSync(file, 'A|1\nB|2\n', 'utf8');
  const res = runMenu(['--prompt', 't', '--items-file', file, '--simulate-index', '2']);
  assert.equal(res.code, 0);
  assert.equal(res.stdout, '2');
});

test('menu query match', () => {
  const dir = mkdtempSync(join(tmpdir(), 'dotcli-tui-'));
  const file = join(dir, 'menu.txt');
  writeFileSync(file, 'Alpha|a\nBeta|b\n', 'utf8');
  const res = runMenu(['--prompt', 't', '--items-file', file, '--query', 'b']);
  assert.equal(res.code, 0);
  assert.equal(res.stdout, 'b');
});
