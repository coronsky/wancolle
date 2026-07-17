from hashlib import sha1
from pathlib import Path


project_root = Path(__file__).resolve().parent.parent
source = project_root / 'web' / 'custom_service_worker.js'
target = project_root / 'build' / 'web' / 'flutter_service_worker.js'
version_file = project_root / 'build' / 'web' / 'version.json'

if not source.exists():
    raise SystemExit(f'Missing source service worker: {source}')

if not target.parent.exists():
    raise SystemExit(f'Missing build output: {target.parent}')

source_text = source.read_text(encoding='utf-8')
version_seed = version_file.read_text(encoding='utf-8') if version_file.exists() else 'dev'
cache_version = sha1(version_seed.encode('utf-8')).hexdigest()[:12]
rendered = source_text.replace('__CACHE_VERSION__', cache_version)

target.write_text(rendered, encoding='utf-8')
print(f'Replaced service worker: {target}')
print(f'Cache version: {cache_version}')
