#!/usr/bin/env node
/**
 * dotcli-tui — menu Ink/TypeScript (contrat dotcli menu).
 * Inspiration : Hermes Agent ui-tui (React + Ink), version minimale menus *man.
 */
import { existsSync, readFileSync } from 'node:fs';
import React, { useState } from 'react';
import { render, Text, Box, useInput, useApp } from 'ink';

type MenuItem = { label: string; key: string };

type CliArgs = {
  command: string;
  prompt: string;
  itemsFile: string;
  query: string;
  simulateIndex: number;
  noTui: boolean;
  dryRun: boolean;
};

function parseArgs(argv: string[]): CliArgs {
  const args: CliArgs = {
    command: 'help',
    prompt: 'Menu',
    itemsFile: '',
    query: '',
    simulateIndex: 0,
    noTui: process.env.DOTFILES_DOTCLI_MENU_NO_TUI === '1',
    dryRun: false,
  };

  const rest = [...argv];
  if (rest.length > 0 && !rest[0].startsWith('-')) {
    args.command = rest.shift() ?? 'help';
  }

  while (rest.length > 0) {
    const token = rest.shift() ?? '';
    switch (token) {
      case '--prompt':
        args.prompt = rest.shift() ?? args.prompt;
        break;
      case '--items-file':
        args.itemsFile = rest.shift() ?? '';
        break;
      case '--query':
        args.query = rest.shift() ?? '';
        break;
      case '--simulate-index': {
        const n = Number(rest.shift() ?? '0');
        args.simulateIndex = Number.isFinite(n) ? n : 0;
        break;
      }
      case '--no-tui':
        args.noTui = true;
        break;
      case '--dry-run':
        args.dryRun = true;
        break;
      case '-h':
      case '--help':
        args.command = 'help';
        break;
      default:
        break;
    }
  }

  return args;
}

function printHelp(): void {
  process.stdout.write(
    [
      'dotcli-tui — menu TUI Ink pour dotfiles (experimental)',
      '',
      'Usage:',
      '  dotcli-tui doctor',
      '  dotcli-tui menu --prompt TEXT --items-file PATH [--query TERM]',
      '                   [--simulate-index N] [--no-tui] [--dry-run]',
      '',
      'Contrat: lignes label|key ; stdout = clé choisie.',
      'Variables: DOTFILES_DOTCLI_MENU_NO_TUI=1',
      '',
    ].join('\n'),
  );
}

function loadItems(path: string): MenuItem[] {
  const raw = readFileSync(path, 'utf8');
  const items: MenuItem[] = [];
  for (const line of raw.split('\n')) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const sep = trimmed.indexOf('|');
    if (sep < 0) continue;
    const label = trimmed.slice(0, sep).trim();
    const key = trimmed.slice(sep + 1).trim();
    if (!key) continue;
    items.push({ label, key });
  }
  return items;
}

function pickNonTty(items: MenuItem[], query: string, simulateIndex: number): string {
  if (simulateIndex > 0 && simulateIndex <= items.length) {
    return items[simulateIndex - 1].key;
  }
  if (query) {
    const q = query.toLowerCase();
    const hit =
      items.find((it) => it.key.toLowerCase() === q) ??
      items.find((it) => it.label.toLowerCase().includes(q));
    if (hit) return hit.key;
  }
  return items[0]?.key ?? '';
}

type MenuAppProps = {
  items: MenuItem[];
  prompt: string;
  onDone: (key: string) => void;
};

function MenuApp({ items, prompt, onDone }: MenuAppProps): React.ReactElement {
  const [index, setIndex] = useState(0);
  const { exit } = useApp();

  useInput((input, key) => {
    if (key.upArrow || input === 'k') {
      setIndex((i) => Math.max(0, i - 1));
      return;
    }
    if (key.downArrow || input === 'j') {
      setIndex((i) => Math.min(items.length - 1, i + 1));
      return;
    }
    if (key.return) {
      onDone(items[index]?.key ?? '');
      exit();
      return;
    }
    if (input === 'q' && items.length > 0) {
      onDone(items[0].key);
      exit();
    }
  });

  return (
    <Box flexDirection="column">
      <Text bold color="cyan">
        {prompt}
      </Text>
      <Text dimColor>↑/↓ ou j/k · Entrée valider · q = premier item</Text>
      {items.map((item, i) => (
        <Text key={`${item.key}-${i}`} inverse={i === index}>
          {` ${item.label} `}
        </Text>
      ))}
    </Box>
  );
}

async function runMenu(args: CliArgs): Promise<number> {
  if (!args.itemsFile || !existsSync(args.itemsFile)) {
    process.stderr.write('dotcli-tui: --items-file manquant ou introuvable\n');
    return 1;
  }

  const items = loadItems(args.itemsFile);
  if (items.length === 0) {
    process.stderr.write('dotcli-tui: aucune entrée label|key\n');
    return 1;
  }

  const tty = process.stdin.isTTY && process.stdout.isTTY;
  let selected = '';

  if (!tty || args.noTui || args.simulateIndex > 0 || args.query) {
    selected = pickNonTty(items, args.query, args.simulateIndex);
  } else if (args.dryRun) {
    selected = items[0].key;
    process.stderr.write(`[dry-run] ${selected}\n`);
  } else {
    await new Promise<void>((resolve) => {
      render(
        <MenuApp
          items={items}
          prompt={args.prompt}
          onDone={(key) => {
            selected = key;
            resolve();
          }}
        />,
      );
    });
  }

  if (!selected) return 1;
  process.stdout.write(`${selected}\n`);
  return 0;
}

function runDoctor(): number {
  const lines = [
    'dotcli-tui doctor',
    `node: ${process.version}`,
    `ink: experimental menu backend`,
    `tty stdin: ${process.stdin.isTTY ? 'yes' : 'no'}`,
    `tty stdout: ${process.stdout.isTTY ? 'yes' : 'no'}`,
  ];
  process.stdout.write(`${lines.join('\n')}\n`);
  return 0;
}

async function main(): Promise<number> {
  const args = parseArgs(process.argv.slice(2));
  switch (args.command) {
    case 'doctor':
      return runDoctor();
    case 'menu':
      return runMenu(args);
    case 'help':
      printHelp();
      return 0;
    default:
      process.stderr.write(`dotcli-tui: commande inconnue: ${args.command}\n`);
      printHelp();
      return 1;
  }
}

main()
  .then((code) => {
    process.exitCode = code;
  })
  .catch((err: unknown) => {
    process.stderr.write(`dotcli-tui: ${String(err)}\n`);
    process.exitCode = 1;
  });
