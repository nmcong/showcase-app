import Keycloak from 'keycloak-js';

const keycloakConfig = {
  url: process.env.NEXT_PUBLIC_KEYCLOAK_URL || 'http://localhost:8080',
  realm: process.env.NEXT_PUBLIC_KEYCLOAK_REALM || 'showcase-realm',
  clientId: process.env.NEXT_PUBLIC_KEYCLOAK_CLIENT_ID || 'showcase-client',
};

let keycloakInstance: Keycloak | null = null;

export const getKeycloak = () => {
  if (typeof window === 'undefined') {
    return null;
  }
  
  if (!keycloakInstance) {
    keycloakInstance = new Keycloak(keycloakConfig);
  }
  
  return keycloakInstance;
};

export const initKeycloak = async (onAuthenticatedCallback?: () => void) => {
  const keycloak = getKeycloak();
  
  if (!keycloak) {
    return;
  }

  try {
    const authenticated = await keycloak.init({
      onLoad: 'check-sso',
      silentCheckSsoRedirectUri: window.location.origin + '/silent-check-sso.html',
      pkceMethod: 'S256',
    });

    if (authenticated && onAuthenticatedCallback) {
      onAuthenticatedCallback();
    }

    // Refresh token every 5 minutes
    setInterval(() => {
      keycloak.updateToken(300).catch(() => {
        console.error('Failed to refresh token');
      });
    }, 60000);

    return authenticated;
  } catch (error) {
    console.error('Failed to initialize Keycloak', error);
    return false;
  }
};

export const isAdmin = () => {
  const keycloak = getKeycloak();
  return keycloak?.hasRealmRole('admin') || false;
};

export const logout = () => {
  const keycloak = getKeycloak();
  keycloak?.logout();
};

export const login = () => {
  const keycloak = getKeycloak();
  keycloak?.login();
};

export const getToken = () => {
  const keycloak = getKeycloak();
  return keycloak?.token;
};

