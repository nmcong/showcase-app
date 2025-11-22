'use client';

import { useEffect, useState } from 'react';
import { useAuthStore } from '@/store/useAuthStore';
import { getKeycloak, initKeycloak } from '@/lib/keycloak';

export function KeycloakProvider({ children }: { children: React.ReactNode }) {
  const [initialized, setInitialized] = useState(false);
  const { setKeycloak, setAuthenticated, setUser } = useAuthStore();

  useEffect(() => {
    const init = async () => {
      const keycloak = getKeycloak();
      if (!keycloak) {
        setInitialized(true);
        return;
      }

      const authenticated = await initKeycloak(() => {
        setAuthenticated(true);
        if (keycloak.tokenParsed) {
          setUser({
            name: keycloak.tokenParsed.name,
            email: keycloak.tokenParsed.email,
            roles: keycloak.tokenParsed.realm_access?.roles || [],
          });
        }
      });

      setKeycloak(keycloak);
      setAuthenticated(authenticated || false);

      if (authenticated && keycloak.tokenParsed) {
        setUser({
          name: keycloak.tokenParsed.name,
          email: keycloak.tokenParsed.email,
          roles: keycloak.tokenParsed.realm_access?.roles || [],
        });
      }

      setInitialized(true);
    };

    init();
  }, [setKeycloak, setAuthenticated, setUser]);

  if (!initialized) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  return <>{children}</>;
}

