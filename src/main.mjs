import { spawnSync } from 'node:child_process';
import { join } from 'node:path';
import process from 'node:process';

const script = join(import.meta.dirname, 'main.sh');
const { status, error } = spawnSync('bash', [script], { stdio: 'inherit' });

if (error) {
  console.log(`::error::cannot run main.sh: ${error.message}`);
}

process.exit(status ?? 1);
