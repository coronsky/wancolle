from pathlib import Path
import shutil


project_root = Path(__file__).resolve().parent.parent
source = project_root / 'web' / 'custom_service_worker.js'
target = project_root / 'build' / 'web' / 'flutter_service_worker.js'

if not source.exists():
    raise SystemExit(f'Missing source service worker: {source}')

if not target.parent.exists():
    raise SystemExit(f'Missing build output: {target.parent}')

shutil.copyfile(source, target)
print(f'Replaced service worker: {target}')
