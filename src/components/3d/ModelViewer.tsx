'use client';

import React, { Suspense, useEffect, useState, useRef } from 'react';
import { Canvas } from '@react-three/fiber';
import { OrbitControls, Environment, useGLTF, Center } from '@react-three/drei';
import * as THREE from 'three';

interface ModelViewerProps {
  modelUrl: string;
  className?: string;
  texturesPath?: string;
  enableTextureToggle?: boolean;
}

interface TextureSet {
  baseColor?: THREE.Texture;
  ao?: THREE.Texture;
  metallic?: THREE.Texture;
  normal?: THREE.Texture;
  roughness?: THREE.Texture;
}

function Model({ url, texturesPath, onProgress }: { url: string; texturesPath?: string; onProgress?: (progress: number) => void }) {
  const { scene } = useGLTF(url);
  const [isTexturesLoaded, setIsTexturesLoaded] = useState(false);
  const hasLoadedRef = React.useRef(false);

  useEffect(() => {
    // Prevent multiple loads
    if (hasLoadedRef.current) return;
    
    if (!texturesPath) {
      setIsTexturesLoaded(true);
      return;
    }

    hasLoadedRef.current = true;

    const loadTextures = async () => {
      try {
        const textureLoader = new THREE.TextureLoader();
        
        // Define texture sets for each material
        const materialSets = [
          {
            name: 'blade',
            prefix: 'bladeoldbamboo',
            materialNames: ['blade', 'Blade', 'BLADE']
          },
          {
            name: 'guard',
            prefix: 'guardfoxstandard',
            materialNames: ['guard', 'Guard', 'GUARD']
          },
          {
            name: 'handle',
            prefix: 'handlebamboostandard',
            materialNames: ['handle', 'Handle', 'HANDLE']
          },
          {
            name: 'scabbard',
            prefix: 'scabbardbamboostandard',
            materialNames: ['scabbard', 'Scabbard', 'SCABBARD']
          }
        ];

        const totalTextures = materialSets.length * 5; // 5 textures per material
        let loadedCount = 0;

        const updateProgress = () => {
          loadedCount++;
          const progress = Math.round((loadedCount / totalTextures) * 100);
          if (onProgress) onProgress(progress);
        };

        // Load all textures
        const textureSets: { [key: string]: TextureSet } = {};

        for (const set of materialSets) {
          const textures: TextureSet = {};

          // Load base color (from images folder)
          try {
            textures.baseColor = await new Promise((resolve, reject) => {
              textureLoader.load(
                `${texturesPath}/images/${set.prefix}_basecolor.jpg`,
                (texture) => {
                  texture.colorSpace = THREE.SRGBColorSpace;
                  texture.flipY = false;
                  updateProgress();
                  resolve(texture);
                },
                undefined,
                reject
              );
            });
          } catch (e) {
            console.warn(`Failed to load basecolor for ${set.name}`);
            updateProgress();
          }

          // Load AO
          try {
            textures.ao = await new Promise((resolve, reject) => {
              textureLoader.load(
                `${texturesPath}/${set.prefix}_ambientocclusion.jpg`,
                (texture) => {
                  texture.flipY = false;
                  updateProgress();
                  resolve(texture);
                },
                undefined,
                reject
              );
            });
          } catch (e) {
            console.warn(`Failed to load AO for ${set.name}`);
            updateProgress();
          }

          // Load Metallic
          try {
            textures.metallic = await new Promise((resolve, reject) => {
              textureLoader.load(
                `${texturesPath}/${set.prefix}_metallic.jpg`,
                (texture) => {
                  texture.flipY = false;
                  updateProgress();
                  resolve(texture);
                },
                undefined,
                reject
              );
            });
          } catch (e) {
            console.warn(`Failed to load metallic for ${set.name}`);
            updateProgress();
          }

          // Load Normal
          try {
            textures.normal = await new Promise((resolve, reject) => {
              textureLoader.load(
                `${texturesPath}/${set.prefix}_normal_directx.jpg`,
                (texture) => {
                  texture.flipY = false;
                  updateProgress();
                  resolve(texture);
                },
                undefined,
                reject
              );
            });
          } catch (e) {
            console.warn(`Failed to load normal for ${set.name}`);
            updateProgress();
          }

          // Load Roughness
          try {
            textures.roughness = await new Promise((resolve, reject) => {
              textureLoader.load(
                `${texturesPath}/${set.prefix}_roughness.jpg`,
                (texture) => {
                  texture.flipY = false;
                  updateProgress();
                  resolve(texture);
                },
                undefined,
                reject
              );
            });
          } catch (e) {
            console.warn(`Failed to load roughness for ${set.name}`);
            updateProgress();
          }

          textureSets[set.name] = textures;
        }

        // Apply textures to materials
        scene.traverse((child: any) => {
          if (child.isMesh && child.material) {
            const material = child.material;
            const materialName = material.name?.toLowerCase() || child.name?.toLowerCase() || '';

            // Find matching texture set
            for (const set of materialSets) {
              if (set.materialNames.some(name => materialName.includes(name.toLowerCase()))) {
                const textures = textureSets[set.name];
                
                // Apply textures to material
                if (textures.baseColor) material.map = textures.baseColor;
                if (textures.ao) material.aoMap = textures.ao;
                if (textures.metallic) material.metalnessMap = textures.metallic;
                if (textures.normal) material.normalMap = textures.normal;
                if (textures.roughness) material.roughnessMap = textures.roughness;
                
                material.needsUpdate = true;
                console.log(`Applied textures to ${set.name} material`);
                break;
              }
            }
          }
        });

        setIsTexturesLoaded(true);
      } catch (error) {
        console.error('Error loading textures:', error);
        setIsTexturesLoaded(true);
      }
    };

    loadTextures();
    
    return () => {
      // Cleanup on unmount
      hasLoadedRef.current = false;
    };
  }, []); // Empty deps - only run once

  if (!isTexturesLoaded && texturesPath) {
    return null; // Don't render until textures are loaded
  }

  return (
    <Center>
      <primitive object={scene} />
    </Center>
  );
}

function Loader({ progress = 0 }: { progress?: number }) {
  return (
    <div id="model-loader" className="model-loader w-full h-full flex items-center justify-center bg-black">
      <div className="loader-content text-center">
        {/* Simple Spinner */}
        <div className="relative w-16 h-16 mx-auto mb-6">
          <div className="absolute inset-0 border-4 border-indigo-500/20 rounded-full"></div>
          <div className="absolute inset-0 border-4 border-transparent border-t-indigo-500 rounded-full animate-spin"></div>
        </div>
        
        <p className="loader-text text-slate-300 font-bold text-lg mb-2">Loading 3D Model...</p>
        <p className="loader-subtext text-sm text-slate-500">Please wait...</p>
      </div>
    </div>
  );
}

export function ModelViewer({ modelUrl, className = '', texturesPath, enableTextureToggle = false }: ModelViewerProps) {
  const [loadingProgress, setLoadingProgress] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [useCustomTextures, setUseCustomTextures] = useState(!!texturesPath);
  const progressRef = useRef(0);
  const loadingTimerRef = useRef<NodeJS.Timeout | undefined>(undefined);

  useEffect(() => {
    // Clear any existing timer
    if (loadingTimerRef.current) {
      clearTimeout(loadingTimerRef.current);
    }

    // Always show loading first
    setIsLoading(true);
    setLoadingProgress(0);
    progressRef.current = 0;
    
    if (!texturesPath || !useCustomTextures) {
      // No textures to load, simulate progress for model loading
      let progress = 0;
      const interval = setInterval(() => {
        progress += 10;
        setLoadingProgress(progress);
        
        if (progress >= 100) {
          clearInterval(interval);
          loadingTimerRef.current = setTimeout(() => {
            setIsLoading(false);
          }, 500);
        }
      }, 150);
      
      return () => {
        clearInterval(interval);
        if (loadingTimerRef.current) {
          clearTimeout(loadingTimerRef.current);
        }
      };
    }
    
    return () => {
      if (loadingTimerRef.current) {
        clearTimeout(loadingTimerRef.current);
      }
    };
  }, [texturesPath, useCustomTextures]);

  const handleProgress = (progress: number) => {
    // Only update if progress increased
    if (progress > progressRef.current) {
      progressRef.current = progress;
      setLoadingProgress(progress);
      
      if (progress >= 100) {
        // Clear any existing timer
        if (loadingTimerRef.current) {
          clearTimeout(loadingTimerRef.current);
        }
        // Hide loading after textures are done
        loadingTimerRef.current = setTimeout(() => {
          setIsLoading(false);
        }, 1000);
      }
    }
  };

  const toggleTextures = () => {
    const newValue = !useCustomTextures;
    setUseCustomTextures(newValue);
    setIsLoading(true);
    progressRef.current = 0;
    setLoadingProgress(0);
  };
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
      {/* Loading Overlay - Always on top */}
      {isLoading && (
        <div className="absolute inset-0 z-50">
          <Loader progress={loadingProgress} />
        </div>
      )}
      
      <Canvas
        camera={{ position: [0, 0, 1.5], fov: 50 }}
        style={{ 
          background: 'linear-gradient(135deg, #0f172a 0%, #1e293b 100%)',
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
          <Model 
            url={modelUrl} 
            texturesPath={useCustomTextures ? texturesPath : undefined} 
            onProgress={handleProgress} 
          />
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
      
      {/* Controls hint */}
      {!isLoading && (
        <>
          <div id="viewer-controls-hint" className="viewer-controls-hint absolute bottom-4 left-4 bg-black/70 backdrop-blur-sm text-white text-xs px-4 py-2.5 rounded-lg shadow-lg pointer-events-none">
            <p className="controls-text font-medium">🖱️ Drag to rotate | Scroll to zoom</p>
          </div>
          
          {/* Texture Quality Toggle */}
          {enableTextureToggle && texturesPath && (
            <div className="absolute top-4 right-4 bg-black/70 backdrop-blur-sm rounded-lg shadow-lg overflow-hidden">
              <button
                onClick={toggleTextures}
                className="px-4 py-2.5 text-white text-xs font-semibold hover:bg-white/10 transition-colors flex items-center gap-2"
              >
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
                <span>{useCustomTextures ? 'High Quality' : 'Standard'}</span>
              </button>
            </div>
          )}
        </>
      )}
    </div>
  );
}
