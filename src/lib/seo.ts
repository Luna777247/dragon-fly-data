export interface SEOMetaTags {
  title: string;
  description: string;
  keywords?: string[];
  image?: string;
  url?: string;
}

export function setMetaTags(meta: SEOMetaTags): void {
  const title = meta.title;
  const description = meta.description;
  const keywords = meta.keywords?.join(', ');
  const image = meta.image || '/placeholder.svg';
  const url = meta.url || window.location.href;

  document.title = title;

  updateMetaTag('description', description);
  if (keywords) updateMetaTag('keywords', keywords);

  updateOgTag('og:title', title);
  updateOgTag('og:description', description);
  updateOgTag('og:image', image);
  updateOgTag('og:url', url);
  updateOgTag('og:type', 'website');

  updateMetaTag('twitter:card', 'summary_large_image');
  updateMetaTag('twitter:title', title);
  updateMetaTag('twitter:description', description);
  updateMetaTag('twitter:image', image);
}

function updateMetaTag(name: string, content: string): void {
  let tag = document.querySelector(`meta[name="${name}"]`) as HTMLMetaElement | null;

  if (!tag) {
    tag = document.createElement('meta');
    tag.setAttribute('name', name);
    document.head.appendChild(tag);
  }

  tag.setAttribute('content', content);
}

function updateOgTag(property: string, content: string): void {
  let tag = document.querySelector(`meta[property="${property}"]`) as HTMLMetaElement | null;

  if (!tag) {
    tag = document.createElement('meta');
    tag.setAttribute('property', property);
    document.head.appendChild(tag);
  }

  tag.setAttribute('content', content);
}

export function setCanonicalURL(url: string): void {
  let canonical = document.querySelector('link[rel="canonical"]') as HTMLLinkElement | null;

  if (!canonical) {
    canonical = document.createElement('link');
    canonical.setAttribute('rel', 'canonical');
    document.head.appendChild(canonical);
  }

  canonical.setAttribute('href', url);
}

export function generateStructuredData(data: Record<string, unknown>): void {
  let script = document.querySelector('script[type="application/ld+json"]') as HTMLScriptElement | null;

  if (!script) {
    script = document.createElement('script');
    script.setAttribute('type', 'application/ld+json');
    document.head.appendChild(script);
  }

  script.textContent = JSON.stringify(data);
}
