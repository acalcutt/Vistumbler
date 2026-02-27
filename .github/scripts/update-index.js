const fs = require('fs');
const path = require('path');

function safeRead(file) {
  try { return fs.readFileSync(file, 'utf8'); } catch (e) { return null; }
}

function safeWrite(file, data) {
  fs.writeFileSync(file, data, 'utf8');
}

function pickAsset(assets, re) {
  if (!Array.isArray(assets)) return null;
  return assets.find(a => re.test(a.name || '') || re.test(a.browser_download_url || '')) || null;
}

function extractChangelogForVersion(changelogText, version){
  if (!changelogText) return null;
  const esc = version.replace(/[.*+?^${}()|[\]\\]/g,'\\$&');
  const headerRegex = new RegExp('^##\\s+' + esc + '\\s*$', 'm');
  const m = changelogText.match(headerRegex);
  if (!m) return null;
  const rest = changelogText.slice(m.index + m[0].length);
  const lines = rest.split(/\r?\n/);
  const out = [];
  for (const line of lines){
    if (/^##\s+/.test(line)) break;
    out.push(line);
  }
  while(out.length && out[0].trim()==='') out.shift();
  while(out.length && out[out.length-1].trim()==='') out.pop();
  if (!out.length) return null;
  return out.join('\n');
}

async function main(){
  const eventPath = process.env.GITHUB_EVENT_PATH;
  let release = null;
  if (eventPath) {
    const event = JSON.parse(fs.readFileSync(eventPath, 'utf8'));
    release = event.release || event;
    if (!release) {
      console.error('No release object in event payload');
      process.exit(1);
    }
  } else if (process.argv[2]) {
    // CLI mode: accept version argument (e.g. 10.9.7 or v10.9.7)
    const provided = String(process.argv[2] || '');
    const ver = provided.replace(/^v/i, '');
    release = {
      tag_name: ver.startsWith('v') ? ver : `v${ver}`,
      name: ver.startsWith('v') ? ver : `v${ver}`,
      published_at: new Date().toISOString(),
      body: '',
      assets: []
    };
    console.log('Running in CLI mode for version', ver);
  } else {
    console.error('GITHUB_EVENT_PATH not set and no version argument provided. This script expects to run on a release event or be passed a version.');
    process.exit(1);
  }

  const title = release.name || release.tag_name || '';
  const tag = release.tag_name || '';
  const published = release.published_at ? new Date(release.published_at).toLocaleDateString('en-US') : '';
  let body = release.body ? release.body.split('\n').filter(Boolean).slice(0,3).join(' ') : '';
  const assets = release.assets || [];

  // If the release body is empty, attempt to extract the notes from VistumblerMDB/CHANGELOG.md
  try{
    const ver = (tag || '').replace(/^v/i, '');
    if (!body && ver){
      const changelogPath = path.join(process.cwd(), 'VistumblerMDB', 'CHANGELOG.md');
      const changelogText = safeRead(changelogPath);
      if (changelogText){
        const extracted = extractChangelogForVersion(changelogText, ver);
        if (extracted){
          body = extracted.split(/\r?\n/).filter(Boolean).slice(0,3).join(' ');
          // also write a debug file so the action logs can show the full extracted notes
          safeWrite(path.join(process.cwd(), 'changelog_for_version.txt'), extracted);
          console.log('Using changelog from', changelogPath, 'for version', ver);
        }
      }
    }
  }catch(e){ /* best-effort only */ }

  const exe = pickAsset(assets, /\.exe$/i);
  const zip = pickAsset(assets, /(?<!portable)\.zip$/i) || pickAsset(assets, /\.zip$/i);
  const portable = assets.find(a => /portable/i.test(a.name || '') ) || null;

  // Read index.html
  const idxPath = path.join(process.cwd(), 'Website', 'Vistumbler.net', 'index.html');
  const html = safeRead(idxPath);
  if (html === null) {
    console.error('Could not read index.html at', idxPath);
    process.exit(1);
  }

  // Build new hero section
  // Determine repository for constructing download URLs
  const repo = process.env.GITHUB_REPOSITORY || (() => {
    try {
      const remote = require('child_process').execSync('git config --get remote.origin.url', { encoding: 'utf8' }).trim();
      const m = remote.match(/github\.com[:/](.+?)(?:\.git)?$/);
      return m ? m[1] : 'acalcutt/Vistumbler';
    } catch (e) { return 'acalcutt/Vistumbler'; }
  })();

  const tagForUrl = (release.tag_name || '').startsWith('v') ? (release.tag_name || '') : `v${release.tag_name || ''}`;
  const numericVer = (tagForUrl || '').replace(/^v/i, '');
  const exeFilename = `Vistumbler_v${numericVer.replace(/\./g,'-')}.exe`;
  const zipFilename = `Vistumbler_v${numericVer}.zip`;
  const portableFilename = `Vistumbler_v${numericVer}_Portable.zip`;

  const baseReleaseUrl = `https://github.com/${repo}/releases/download/${tagForUrl}`;

  const exeUrl = exe ? exe.browser_download_url : `${baseReleaseUrl}/${exeFilename}`;
  const zipUrl = zip ? zip.browser_download_url : `${baseReleaseUrl}/${zipFilename}`;
  const portableUrl = portable ? portable.browser_download_url : `${baseReleaseUrl}/${portableFilename}`;

  const hero = `
                            <section class="hero feature">
                                <div class="feature-body">
                                    <div>
                                        <h2>${escapeHtml(title)}</h2>
                                        <p class="inside_text">Released: <strong>${escapeHtml(published)}</strong></p>
                                        <p class="inside_text">${escapeHtml(body || 'Vistumbler is an open-source wireless network scanner for Windows. It maps and visualises nearby access points using wireless and GPS data.')}</p>
                                        <div class="hero-actions">
                                            <a class="download-btn" href="${exeUrl}">EXE Installer</a>
                                            <a class="download-btn" href="${zipUrl}">ZIP Source</a>
                                            <a class="download-btn" href="${portableUrl}">ZIP Portable</a>
                                            <a href="donate.htm"><img alt="Donate" src="images/donate-paypal-bitcoin.png" style="vertical-align:middle; margin-left:12px;"/></a>
                                        </div>
                                    </div>
                                    <div class="feature-media">
                                        <img alt="Vistumbler Screenshot" src="images/vi_preview.jpg" width="268" height="181" />
                                    </div>
                                </div>
                            </section>`;

  // Replace existing hero section
  const newHtml = html.replace(/<section class="hero feature">[\s\S]*?<\/section>/, hero);

  if (newHtml === html) {
    console.log('No replacement performed — hero section not found or unchanged.');
    return;
  }

  safeWrite(idxPath, newHtml);
  console.log('Updated', idxPath, 'with release', title || tag);
}

function escapeHtml(s){
  if (!s) return '';
  return String(s)
    .replace(/&/g,'&amp;')
    .replace(/</g,'&lt;')
    .replace(/>/g,'&gt;')
    .replace(/"/g,'&quot;')
    .replace(/'/g,'&apos;');
}

main().catch(err => { console.error(err); process.exit(1); });
