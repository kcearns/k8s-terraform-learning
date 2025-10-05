export default function Home() {
  return (
    <main style={{ 
      minHeight: '100vh', 
      display: 'flex', 
      flexDirection: 'column', 
      alignItems: 'center', 
      justifyContent: 'center',
      padding: '2rem',
      fontFamily: 'system-ui, sans-serif'
    }}>
      <h1 style={{ fontSize: '3rem', marginBottom: '1rem' }}>
        🚀 Next.js on AWS EKS
      </h1>
      <p style={{ fontSize: '1.25rem', color: '#666', textAlign: 'center', maxWidth: '600px' }}>
        This Next.js application is running on Amazon EKS (Elastic Kubernetes Service)
      </p>
      <div style={{ marginTop: '2rem', display: 'flex', gap: '1rem' }}>
        <a 
          href="/api/health" 
          style={{ 
            padding: '0.75rem 1.5rem', 
            background: '#0070f3', 
            color: 'white', 
            borderRadius: '0.5rem',
            textDecoration: 'none'
          }}
        >
          Check Health
        </a>
        <a 
          href="https://github.com/kcearns/k8s-terraform-learning" 
          target="_blank"
          rel="noopener noreferrer"
          style={{ 
            padding: '0.75rem 1.5rem', 
            border: '2px solid #0070f3', 
            color: '#0070f3', 
            borderRadius: '0.5rem',
            textDecoration: 'none'
          }}
        >
          View Repository
        </a>
      </div>
    </main>
  )
}
