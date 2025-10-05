/** @type {import('next').NextConfig} */
const nextConfig = {
  // Enable standalone output for Docker deployment
  output: 'standalone',
  
  // Disable telemetry in production
  telemetry: false,
  
  // Configure for production
  reactStrictMode: true,
  
  // Optional: Configure image optimization
  images: {
    domains: [],
    // unoptimized: true, // Uncomment if not using Next.js image optimization
  },

  // Optional: Configure headers
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
        ],
      },
    ]
  },
}

module.exports = nextConfig
