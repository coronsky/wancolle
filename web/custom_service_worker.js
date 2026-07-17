'use strict';

const CACHE_NAME = 'wancolle-pwa-__CACHE_VERSION__';
const APP_SHELL = [
  './',
  './index.html',
  './manifest.json',
  './favicon.png',
  './flutter_bootstrap.js',
  './flutter.js',
  './main.dart.js',
  './version.json',
  './icons/Icon-192.png',
  './icons/Icon-512.png',
  './icons/Icon-maskable-192.png',
  './icons/Icon-maskable-512.png',
];

const NETWORK_FIRST_PATHS = new Set([
  '/',
  '/index.html',
  '/manifest.json',
  '/flutter_bootstrap.js',
  '/flutter.js',
  '/main.dart.js',
  '/version.json',
]);

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) =>
      cache.addAll(APP_SHELL).catch(() => Promise.resolve()),
    ),
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      const keys = await caches.keys();
      await Promise.all(
        keys.map((key) => {
          if (key !== CACHE_NAME) {
            return caches.delete(key);
          }
          return Promise.resolve();
        }),
      );
      await self.clients.claim();

      const clients = await self.clients.matchAll({
        type: 'window',
        includeUncontrolled: true,
      });
      for (const client of clients) {
        client.postMessage({ type: 'WANCOLLE_SW_ACTIVATED' });
      }
    })(),
  );
});

self.addEventListener('message', (event) => {
  if (event.data?.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') {
    return;
  }

  const requestUrl = new URL(event.request.url);
  if (requestUrl.origin !== self.location.origin) {
    return;
  }

  if (event.request.mode === 'navigate') {
    event.respondWith(networkFirst(event.request, './index.html'));
    return;
  }

  const normalizedPath = normalizePath(requestUrl.pathname);
  if (NETWORK_FIRST_PATHS.has(normalizedPath)) {
    event.respondWith(networkFirst(event.request));
    return;
  }

  event.respondWith(cacheFirst(event.request));
});

function normalizePath(pathname) {
  if (pathname.endsWith('/')) {
    return pathname.slice(0, -1) || '/';
  }
  return pathname;
}

async function networkFirst(request, fallbackKey) {
  const cache = await caches.open(CACHE_NAME);

  try {
    const response = await fetch(request, { cache: 'no-store' });
    if (response && response.ok) {
      await cache.put(request, response.clone());
      if (fallbackKey != null) {
        await cache.put(fallbackKey, response.clone());
      }
    }
    return response;
  } catch (_) {
    const cached = await caches.match(request);
    if (cached) {
      return cached;
    }

    if (fallbackKey != null) {
      const fallback = await caches.match(fallbackKey);
      if (fallback) {
        return fallback;
      }
    }

    throw _;
  }
}

async function cacheFirst(request) {
  const cached = await caches.match(request);
  if (cached) {
    return cached;
  }

  const response = await fetch(request);
  if (response && response.ok) {
    const cache = await caches.open(CACHE_NAME);
    await cache.put(request, response.clone());
  }
  return response;
}
