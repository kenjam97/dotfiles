import * as zebar from 'https://esm.sh/zebar@3';

const providers = zebar.createProviderGroup({
  glazewm: { type: 'glazewm' },
  date: { type: 'date', formatting: 'EEE d MMM' },
  time: { type: 'date', formatting: 'HH:mm' },
  cpu: { type: 'cpu', refreshInterval: 3000 },
  memory: { type: 'memory', refreshInterval: 5000 },
  network: { type: 'network', refreshInterval: 5000 },
  battery: { type: 'battery', refreshInterval: 10000 },
  audio: { type: 'audio' },
  media: { type: 'media' },
});

const $ = id => document.getElementById(id);

const esc = s =>
  String(s ?? '').replace(
    /[&<>"']/g,
    c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c],
  );

const icon = (name, cls = '') => `<i class="nf ${name} ${cls}"></i>`;

// Only touch the DOM when a section's markup actually changes.
const lastHtml = {};
function set(id, html) {
  if (lastHtml[id] === html) return false;
  lastHtml[id] = html;
  $(id).innerHTML = html;
  return true;
}

function renderWorkspaces(wm) {
  if (!wm) return set('workspaces', '');
  set(
    'workspaces',
    wm.currentWorkspaces
      .map(ws => {
        const state = ws.hasFocus ? 'focused' : ws.isDisplayed ? 'displayed' : '';
        const occupied = ws.children?.length ? 'occupied' : '';
        return `<button class="ws ${state} ${occupied}" data-wm="focus --workspace ${esc(ws.name)}">${esc(ws.displayName ?? ws.name)}</button>`;
      })
      .join(''),
  );
}

function renderMode(wm) {
  if (!wm) return set('mode', '');
  const parts = [];
  if (wm.isPaused) {
    parts.push(`<button class="pill badge paused" data-wm="wm-toggle-pause">${icon('nf-md-pause')} paused</button>`);
  }
  for (const mode of wm.bindingModes ?? []) {
    parts.push(
      `<button class="pill badge mode" data-wm="wm-disable-binding-mode --name ${esc(mode.name)}">${icon('nf-md-resize')} ${esc(mode.displayName ?? mode.name)}</button>`,
    );
  }
  const dir = wm.tilingDirection === 'horizontal' ? 'nf-md-arrow_split_vertical' : 'nf-md-arrow_split_horizontal';
  parts.push(`<button class="pill badge tiling" title="Toggle tiling direction" data-wm="toggle-tiling-direction">${icon(dir)}</button>`);
  set('mode', parts.join(''));
}

function renderWindow(wm) {
  const focused = wm?.focusedContainer;
  if (!focused || focused.type !== 'window') return set('window', '');
  const proc = focused.processName ? `<span class="proc">${esc(focused.processName)}</span>` : '';
  set('window', `${proc}<span class="title">${esc(focused.title)}</span>`);
}

function renderClock(date, time) {
  set('clock', `${icon('nf-md-calendar_blank', 'accent-blue')}<span>${esc(date?.formatted)}</span><span class="sep"></span>${icon('nf-md-clock_outline', 'accent-mauve')}<span class="time">${esc(time?.formatted)}</span>`);
}

function renderMedia(media) {
  const session = media?.currentSession;
  const el = $('media');
  $('mascot').classList.toggle('dancing', !!session?.isPlaying);
  if (!session || !session.title) {
    el.classList.add('hidden');
    set('media-ctl', '');
    set('media-track', '');
    return;
  }
  el.classList.remove('hidden');

  // Controls and track are separate so play/pause doesn't restart the marquee.
  set(
    'media-ctl',
    `<button class="ctl" data-media="previous">${icon('nf-md-skip_previous')}</button>` +
      `<button class="ctl play" data-media="togglePlayPause">${icon(session.isPlaying ? 'nf-md-pause' : 'nf-md-play')}</button>` +
      `<button class="ctl" data-media="next">${icon('nf-md-skip_next')}</button>`,
  );

  const artist = session.artist ? `<span class="artist">${esc(session.artist)}</span>` : '';
  const changed = set(
    'media-track',
    `${icon('nf-md-music_note', 'accent-pink')}` +
      `<div class="marquee"><div class="marquee-inner"><span class="text"><span class="song">${esc(session.title)}</span>${artist}</span></div></div>`,
  );
  if (changed) fitMarquee();
}

// Scroll the track only when it overflows: hold, scroll one full copy, loop seamlessly.
const MARQUEE_GAP_PX = 48;
const MARQUEE_SPEED_PX_PER_S = 35;
const MARQUEE_HOLD_S = 2.5;

function fitMarquee() {
  const box = document.querySelector('#media-track .marquee');
  const inner = box?.querySelector('.marquee-inner');
  if (!inner) return;

  inner.getAnimations().forEach(a => a.cancel());
  inner.querySelectorAll('.text.clone').forEach(n => n.remove());
  box.classList.remove('scrolling');

  const text = inner.querySelector('.text');
  if (text.offsetWidth <= box.clientWidth) return;

  const clone = text.cloneNode(true);
  clone.classList.add('clone');
  clone.style.marginLeft = `${MARQUEE_GAP_PX}px`;
  clone.setAttribute('aria-hidden', 'true');
  inner.append(clone);
  box.classList.add('scrolling');

  const distance = text.offsetWidth + MARQUEE_GAP_PX;
  const travel = distance / MARQUEE_SPEED_PX_PER_S;
  const total = travel + MARQUEE_HOLD_S;
  const hold = MARQUEE_HOLD_S / total;
  inner.animate(
    [
      { transform: 'translateX(0)', offset: 0 },
      { transform: 'translateX(0)', offset: hold },
      { transform: `translateX(-${distance}px)`, offset: 1 },
    ],
    { duration: total * 1000, iterations: Infinity, easing: 'linear' },
  );
}

// Fonts load async; re-measure once they're in so widths are right.
document.fonts?.ready.then(fitMarquee);

// Pause the marquee while hovering so a long title can be read.
$('media-track').addEventListener('mouseenter', () =>
  document.querySelectorAll('#media-track .marquee-inner').forEach(n => n.getAnimations().forEach(a => a.pause())),
);
$('media-track').addEventListener('mouseleave', () =>
  document.querySelectorAll('#media-track .marquee-inner').forEach(n => n.getAnimations().forEach(a => a.play())),
);

function networkIcon(net) {
  switch (net?.defaultInterface?.type) {
    case 'ethernet':
      return icon('nf-md-ethernet', 'accent-teal');
    case 'proprietary_virtual':
      return icon('nf-md-shield_lock_outline', 'accent-teal');
    case 'wifi': {
      const s = net.defaultGateway?.signalStrength ?? 0;
      const level = s >= 80 ? 4 : s >= 65 ? 3 : s >= 40 ? 2 : s >= 25 ? 1 : 'outline';
      return icon(`nf-md-wifi_strength_${level}`, 'accent-teal');
    }
    default:
      return icon('nf-md-wifi_strength_off_outline', 'accent-red');
  }
}

function batteryIcon(pct, charging) {
  if (charging) return icon('nf-md-battery_charging', 'accent-green');
  const step = Math.max(1, Math.min(10, Math.round(pct / 10))) * 10;
  const cls = pct <= 20 ? 'accent-red' : 'accent-green';
  return step === 100 ? icon('nf-md-battery', cls) : icon(`nf-md-battery_${step}`, cls);
}

// Fixed-width percentage so 5% → 42% → 100% doesn't resize the pill.
const pct = n => `<span class="num">${n}%</span>`;

function renderStats({ cpu, memory, network, battery, audio }) {
  const parts = [];

  const vol = audio?.defaultPlaybackDevice;
  if (vol) {
    const v = Math.round(vol.volume);
    const name = vol.isMuted || v === 0 ? 'nf-md-volume_off' : v < 35 ? 'nf-md-volume_low' : v < 70 ? 'nf-md-volume_medium' : 'nf-md-volume_high';
    parts.push(`<span class="stat volume" title="Scroll to change volume">${icon(name, 'accent-peach')}${pct(v)}</span>`);
  }
  if (cpu) {
    const u = Math.round(cpu.usage);
    parts.push(`<span class="stat ${u > 85 ? 'hot' : ''}">${icon('nf-oct-cpu', 'accent-blue')}${pct(u)}</span>`);
  }
  if (memory) {
    const u = Math.round(memory.usage);
    parts.push(`<span class="stat ${u > 85 ? 'hot' : ''}">${icon('nf-fae-chip', 'accent-mauve')}${pct(u)}</span>`);
  }
  if (network) {
    const ssid = network.defaultGateway?.ssid;
    parts.push(`<span class="stat">${networkIcon(network)}${ssid ? `<span class="ssid">${esc(ssid)}</span>` : ''}</span>`);
  }
  if (battery) {
    const p = Math.round(battery.chargePercent);
    parts.push(`<span class="stat">${batteryIcon(p, battery.isCharging)}${pct(p)}</span>`);
  }
  set('stats', parts.join(''));
}

// One failing section (or provider) must not blank the rest of the bar.
function safe(name, fn) {
  try {
    fn();
  } catch (err) {
    console.error(`[bar] ${name}`, err);
  }
}

function render() {
  const o = providers.outputMap;
  safe('workspaces', () => renderWorkspaces(o.glazewm));
  safe('mode', () => renderMode(o.glazewm));
  safe('window', () => renderWindow(o.glazewm));
  safe('clock', () => renderClock(o.date, o.time));
  safe('media', () => renderMedia(o.media));
  safe('stats', () => renderStats(o));
  const errors = Object.entries(providers.errorMap ?? {}).filter(([, e]) => e);
  if (errors.length) console.warn('[bar] provider errors', errors);}

// Event delegation: buttons carry the GlazeWM command or media action.
document.addEventListener('click', e => {
  const wmBtn = e.target.closest('[data-wm]');
  if (wmBtn) {
    providers.outputMap.glazewm?.runCommand(wmBtn.dataset.wm);
    return;
  }
  const mediaBtn = e.target.closest('[data-media]');
  if (mediaBtn) {
    const media = providers.outputMap.media;
    media?.[mediaBtn.dataset.media]?.();
  }
});

// Scroll on the volume stat to change it.
document.addEventListener(
  'wheel',
  e => {
    if (!e.target.closest('.volume')) return;
    const audio = providers.outputMap.audio;
    const device = audio?.defaultPlaybackDevice;
    if (!device || !audio.setVolume) return;
    const next = Math.max(0, Math.min(100, Math.round(device.volume) + (e.deltaY < 0 ? 2 : -2)));
    audio.setVolume(next);
  },
  { passive: true },
);

providers.onOutput(render);
render();
