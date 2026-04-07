async function getSession() {
  const res = await fetch('/api/session', { credentials: 'include' });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) return null;
  return data.user || null;
}

function redirectIfGuest() {
  return getSession().then((user) => {
    if (!user) {
      window.location.href = '/';
      return null;
    }
    return user;
  });
}

async function apiJson(url, options = {}) {
  const res = await fetch(url, {
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' },
    ...options
  });
  let data = {};
  try {
    data = await res.json();
  } catch (_) {}

  if (res.status === 401) {
    window.location.href = '/';
    return { res, data: null };
  }

  return { res, data };
}

function showNav(user) {
  const maintenanceLink = document.getElementById('nav-maintenance');
  if (maintenanceLink && user.role !== 'admin') {
    maintenanceLink.classList.add('hidden');
  }
}
