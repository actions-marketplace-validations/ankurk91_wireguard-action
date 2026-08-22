import { spawnSync } from 'node:child_process';
import { join } from 'node:path';
import process from 'node:process';

const script = join(import.meta.dirname, 'post.sh');
const { status, error } = spawnSync('bash', [script], { stdio: 'inherit' });

if (error) {
  console.log(`::error::cannot run post.sh: ${error.message}`);
}

process.exit(status ?? 1);
