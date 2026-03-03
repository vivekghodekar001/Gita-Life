export interface AudioTrack {
    title: string;
    url: string;
}

const FOLDER_PATH = '/02_-_ISKCON_Swamis/ISKCON_Swamis_-_D_to_P/His_Holiness_Lokanath_Swami/Bhajans/Hare_Krishna_Kirtan';
const DIRECTORY_URL = `https://audio.iskcondesiretree.com/index.php?q=f&f=${encodeURIComponent(FOLDER_PATH)}`;
const BASE_AUDIO_URL = `https://audio.iskcondesiretree.com${FOLDER_PATH}/`;
const PROXY_URL = `/api/audio-proxy/index.php?q=f&f=${encodeURIComponent(FOLDER_PATH)}`;

function parseAudioTracks(html: string): AudioTrack[] {
    const parser = new DOMParser();
    const doc = parser.parseFromString(html, 'text/html');
    const tracks: AudioTrack[] = [];

    const links = doc.querySelectorAll('a[href]');
    links.forEach(link => {
        const href = (link as HTMLAnchorElement).href;
        const text = link.textContent?.trim() || '';
        // Match .mp3 links either as full URLs or relative paths
        if (href.endsWith('.mp3') || text.endsWith('.mp3')) {
            const filename = text.endsWith('.mp3') ? text : decodeURIComponent(href.split('/').pop() || '');
            const title = filename
                .replace(/\.mp3$/i, '')
                .replace(/_/g, ' ')
                .trim();
            const url = href.startsWith('http')
                ? href
                : `${BASE_AUDIO_URL}${encodeURIComponent(filename)}`;
            if (title) {
                tracks.push({ title, url });
            }
        }
    });

    return tracks;
}

export async function fetchKirtanTracks(): Promise<AudioTrack[]> {
    // Try Vercel proxy first (avoids CORS)
    try {
        const response = await fetch(PROXY_URL);
        if (response.ok) {
            const html = await response.text();
            const tracks = parseAudioTracks(html);
            if (tracks.length > 0) return tracks;
        }
    } catch {
        // fall through to allorigins
    }

    // Fallback: allorigins CORS proxy
    try {
        const allOriginsUrl = `https://api.allorigins.win/get?url=${encodeURIComponent(DIRECTORY_URL)}`;
        const response = await fetch(allOriginsUrl);
        if (response.ok) {
            const data = await response.json();
            const tracks = parseAudioTracks(data.contents || '');
            if (tracks.length > 0) return tracks;
        }
    } catch {
        // fall through
    }

    return [];
}
