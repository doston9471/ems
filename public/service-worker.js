// No-op service worker. Browsers (and some extensions) probe this path;
// serve an empty script instead of a Rails RoutingError.
self.addEventListener("install", () => self.skipWaiting());
self.addEventListener("activate", (event) => event.waitUntil(self.clients.claim()));
