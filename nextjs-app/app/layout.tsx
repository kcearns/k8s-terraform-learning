import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Next.js on EKS',
  description: 'Next.js application deployed on AWS EKS',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
