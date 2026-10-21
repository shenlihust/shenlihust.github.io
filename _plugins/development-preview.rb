# frozen_string_literal: true

# Keep local previews fresh without changing production PWA behavior.
if Jekyll.env == "development"
  Jekyll::Hooks.register :site, :after_init do |site|
    site.config["pwa"] = (site.config["pwa"] || {}).merge("enabled" => false)
    site.config["webrick"] ||= {}
    site.config["webrick"]["headers"] ||= {}
    site.config["webrick"]["headers"]["Cache-Control"] = "no-store"
  end

  # Existing browsers still check this URL for updates even when the new HTML
  # no longer registers a worker. Replace the old cache-first worker in place.
  Jekyll::Hooks.register :pages, :post_render do |page|
    next unless page.name == "sw.min.js" && page.url == "/sw.min"

    page.output = <<~JS
      // Development preview: retire Chirpy's offline cache on this origin.
      self.addEventListener('install', () => self.skipWaiting());
      self.addEventListener('activate', event => {
        event.waitUntil((async () => {
          const keys = await caches.keys();
          await Promise.all(keys.filter(key => key.startsWith('chirpy-'))
            .map(key => caches.delete(key)));
          await self.clients.claim();
          await self.registration.unregister();
        })());
      });
      // No fetch handler: all requests go directly to the preview server.
    JS
  end
end
