#!/usr/bin/env node

import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const manifestPath = path.join(__dirname, 'manifest');
const manifestDevPath = path.join(__dirname, 'manifest-dev');
const manifestBackupPath = path.join(__dirname, 'manifest.backup');

try {
  // Backup original manifest
  fs.copyFileSync(manifestPath, manifestBackupPath);
  console.log('Backed up original manifest');

  // Copy dev manifest to manifest
  fs.copyFileSync(manifestDevPath, manifestPath);
  console.log('Copied manifest-dev to manifest');

  // Run the build with the standard config
  execSync('npx rimraf build/ out/ && npx bsc --project bsconfig.json', { stdio: 'inherit' });

  // Restore original manifest
  fs.copyFileSync(manifestBackupPath, manifestPath);
  fs.unlinkSync(manifestBackupPath);
  console.log('Restored original manifest');

  console.log('Dev build completed successfully!');
} catch (error) {
  // Restore original manifest on error
  if (fs.existsSync(manifestBackupPath)) {
    fs.copyFileSync(manifestBackupPath, manifestPath);
    fs.unlinkSync(manifestBackupPath);
  }
  console.error('Build failed:', error.message);
  process.exit(1);
}
