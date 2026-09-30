import { useCallback, useEffect, useState } from 'react';

export class ApiError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

let onUnauthorized = () => {};

/** Called when a request comes back 401 (session expired or user disabled). */
export function setUnauthorizedHandler(fn) {
  onUnauthorized = fn;
}

/** JSON fetch against the Spring Boot API. Errors carry the server's {"error"} message. */
export async function api(path, { method = 'GET', body } = {}) {
  const res = await fetch(`/api${path}`, {
    method,
    credentials: 'same-origin',
    headers: body !== undefined ? { 'Content-Type': 'application/json' } : undefined,
    body: body !== undefined ? JSON.stringify(body) : undefined
  });
  if (res.status === 204) return null;
  const data = await res.json().catch(() => null);
  if (!res.ok) {
    if (res.status === 401 && path !== '/auth/login' && path !== '/auth/me') onUnauthorized();
    throw new ApiError(res.status, data?.error || `Request failed (${res.status})`);
  }
  return data;
}

/** Loads `path` on mount (null skips); `reload()` fetches again. */
export function useApi(path) {
  const [state, setState] = useState({ data: null, error: null, loading: path !== null });
  const [tick, setTick] = useState(0);

  useEffect(() => {
    if (path === null) return undefined;
    let cancelled = false;
    setState(s => ({ ...s, loading: true }));
    api(path).then(
      data => !cancelled && setState({ data, error: null, loading: false }),
      err => !cancelled && setState({ data: null, error: err.message, loading: false })
    );
    return () => { cancelled = true; };
  }, [path, tick]);

  const reload = useCallback(() => setTick(t => t + 1), []);
  return { ...state, reload };
}
