import { createContext, useContext } from 'react';

/** { me, logout } for the logged-in user; see App.jsx. */
export const AuthContext = createContext(null);

export function useAuth() {
  return useContext(AuthContext);
}
