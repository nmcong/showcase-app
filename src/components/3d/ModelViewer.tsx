'use client';

import { Suspense, useEffect } from 'react';
import { Canvas } from '@react-three/fiber';
import { OrbitControls, Environment, useGLTF, Center } from '@react-three/drei';

interface ModelViewerProps {
  modelUrl: string;
  className?: string;
}

function Model({ url }: { url: string }) {
  const { scene } = useGLTF(url);
  return (
    <Center>
      <primitive object={scene} />
    </Center>
  );
}

function Loader() {
  return (
    <div id="model-loader" className="model-loader absolute inset-0 flex items-center justify-center bg-gradient-to-br from-slate-900 to-slate-800">
      <div className="loader-content text-center">
        <div className="loader-spinner animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600 mx-auto"></div>
        <p className="loader-text mt-4 text-slate-300 font-medium">Loading 3D Model...</p>
        <p className="loader-subtext text-xs text-slate-500 mt-2">Please wait...</p>
      </div>
    </div>
  );
}

export function ModelViewer({ modelUrl, className = '' }: ModelViewerProps) {
  useEffect(() => {
    // Disable right-click context menu
    const handleContextMenu = (e: MouseEvent) => {
      e.preventDefault();
      return false;
    };

    // Disable save shortcuts
    const handleKeyDown = (e: KeyboardEvent) => {
      if (
        (e.ctrlKey && e.key === 's') ||
        (e.metaKey && e.key === 's') ||
        e.key === 'F12' ||
        (e.ctrlKey && e.shiftKey && e.key === 'I')
      ) {
        e.preventDefault();
        return false;
      }
    };

    document.addEventListener('contextmenu', handleContextMenu);
    document.addEventListener('keydown', handleKeyDown);

    return () => {
      document.removeEventListener('contextmenu', handleContextMenu);
      document.removeEventListener('keydown', handleKeyDown);
    };
  }, []);

  return (
    <div 
      id="model-viewer"
      className={`model-viewer-wrapper relative w-full h-full ${className}`}
      data-model-url={modelUrl}
      style={{ 
        userSelect: 'none',
        WebkitUserSelect: 'none',
        MozUserSelect: 'none',
        msUserSelect: 'none'
      }}
      onContextMenu={(e) => e.preventDefault()}
    >
      <Canvas
        camera={{ position: [0, 0, 5], fov: 50 }}
        style={{ 
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
          userSelect: 'none',
          width: '100%',
          height: '100%'
        }}
        gl={{ 
          preserveDrawingBuffer: false,
          antialias: true 
        }}
      >
        <ambientLight intensity={0.6} />
        <spotLight position={[10, 10, 10]} angle={0.15} penumbra={1} intensity={0.8} />
        <spotLight position={[-10, 10, -10]} angle={0.15} penumbra={1} intensity={0.5} />
        <pointLight position={[-10, -10, -10]} intensity={0.3} />
        
        <Suspense fallback={null}>
          <Model url={modelUrl} />
          <Environment preset="city" />
        </Suspense>
        
        <OrbitControls
          enablePan={true}
          enableZoom={true}
          enableRotate={true}
          minDistance={1}
          maxDistance={20}
          enableDamping={true}
          dampingFactor={0.05}
          makeDefault
        />
      </Canvas>
      
      <Suspense fallback={<Loader />} />
      
      {/* Controls hint */}
      <div id="viewer-controls-hint" className="viewer-controls-hint absolute bottom-4 left-4 bg-black/70 backdrop-blur-sm text-white text-xs px-4 py-2.5 rounded-lg shadow-lg pointer-events-none">
        <p className="controls-text font-medium">🖱️ Drag to rotate | Scroll to zoom</p>
      </div>
    </div>
  );
}
