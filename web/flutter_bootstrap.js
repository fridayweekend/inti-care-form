{{flutter_js}}
{{flutter_build_config}}

// Remove stale Flutter service workers so GitHub Pages always loads the latest
// deployed Dart bundle instead of an older cached dialog design.
async function startFreshFlutter() {
  if ('serviceWorker' in navigator) {
    const registrations = await navigator.serviceWorker.getRegistrations();
    await Promise.all(registrations.map((registration) => registration.unregister()));
  }
  await _flutter.loader.load();
}

startFreshFlutter();
