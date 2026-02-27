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

function buildHeroSection(title, published, body, exeUrl, zipUrl, portableUrl, sectionIndent) {
  // sectionIndent = the tabs that go before <section ...>
  // Each level of nesting adds one more tab
  const s  = sectionIndent;          // <section>, </section>
  const d1 = s  + '\t';             // <div class="feature-body">, </div>
  const d2 = d1 + '\t';             // <div>, <div class="feature-media">, </div>
  const d3 = d2 + '\t';             // <h2>, <p>, <div class="hero-actions">, </div>
  const d4 = d3 + '\t';             // <a ...>, <img ...> (inside hero-actions or feature-media)

  const lines = [
    `${s}<section class="hero feature">`,
    `${d1}<div class="feature-body">`,
    `${d2}<div>`,
    `${d3}<h2>${escapeHtml(/^v\d/i.test(title) ? 'Vistumbler ' + title : title)}</h2>`,
    `${d3}<p class="inside_text">Released: <strong>${escapeHtml(published)}</strong></p>`,
    `${d3}<p class="inside_text">${escapeHtml(body || 'Vistumbler is an open-source wireless network scanner for Windows. It maps and visualises nearby access points using wireless and GPS data.')}</p>`,
    `${d3}<div class="hero-actions">`,
    `${d4}<a class="download-btn" href="${exeUrl}">EXE Installer</a>`,
    `${d4}<a class="download-btn" href="${zipUrl}">ZIP Source</a>`,
    `${d4}<a class="download-btn" href="${portableUrl}">ZIP Portable</a>`,
    `${d4}<a href="donate.htm"><img alt="Donate" src="images/donate-paypal-bitcoin.png" style="vertical-align:middle; margin-left:12px;"/></a>`,
    `${d3}</div>`,
    `${d2}</div>`,
    `${d2}<div class="feature-media">`,
    `${d3}<img alt="Vistumbler Screenshot" src="images/vi_preview.jpg" width="268" height="181" />`,
    `${d2}</div>`,
    `${d1}</div>`,
    `${s}</section>`,
  ];

  return lines.join('\n');
}

async function main(){
  // Prefer CLI-provided version if available (used by bump workflow)
  let release = null;
  if (process.argv[2]) {
    const provided = String(process.argv[2] || '');
    const ver = provided.replace(/^v/i, '');
    release = {
      tag_name: `v${ver}`,
      name: `v${ver}`,
      published_at: new Date().toISOString(),
      body: '',
      assets: []
    };
    console.log('Running in CLI mode for version', ver);
  } else {
    const eventPath = process.env.GITHUB_EVENT_PATH;
    if (eventPath) {
      const event = JSON.parse(fs.readFileSync(eventPath, 'utf8'));
      release = event.release || event;
      if (!release) {
        console.error('No release object in event payload');
        process.exit(1);
      }
    } else {
      console.error('GITHUB_EVENT_PATH not set and no version argument provided. This script expects to run on a release event or be passed a version.');
      process.exit(1);
    }
  }

  const title = release.name || release.tag_name || '';
  const tag = release.tag_name || '';
  const published = release.published_at ? new Date(release.published_at).toLocaleDateString('en-US') : '';
  let body = release.body ? release.body.split('\n').filter(Boolean).slice(0,3).join(' ') : '';
  const assets = release.assets || [];

  // If the release body is empty, attempt to extract the notes from VistumblerMDB/CHANGELOG.md
  let extractedChangelog = null;
  try{
    const ver = (tag || '').replace(/^v/i, '');
    if (ver){
      const changelogPath = path.join(process.cwd(), 'VistumblerMDB', 'CHANGELOG.md');
      const changelogText = safeRead(changelogPath);
      if (changelogText){
        const extracted = extractChangelogForVersion(changelogText, ver);
        if (extracted){
          extractedChangelog = extracted;
          safeWrite(path.join(process.cwd(), 'changelog_for_version.txt'), extracted);
          console.log('Extracted changelog from', changelogPath, 'for version', ver);
        }
      }
    }
  }catch(e){ /* best-effort only */ }

  const exe      = pickAsset(assets, /\.exe$/i);
  const zip      = pickAsset(assets, /(?<!portable)\.zip$/i) || pickAsset(assets, /\.zip$/i);
  const portable = assets.find(a => /portable/i.test(a.name || '')) || null;

  // Read index.html
  const idxPath = path.join(process.cwd(), 'Website', 'Vistumbler.net', 'index.html');
  const html = safeRead(idxPath);
  if (html === null) {
    console.error('Could not read index.html at', idxPath);
    process.exit(1);
  }

  // Determine repository for constructing download URLs
  const repo = process.env.GITHUB_REPOSITORY || (() => {
    try {
      const remote = require('child_process').execSync('git config --get remote.origin.url', { encoding: 'utf8' }).trim();
      const m = remote.match(/github\.com[:/](.+?)(?:\.git)?$/);
      return m ? m[1] : 'acalcutt/Vistumbler';
    } catch (e) { return 'acalcutt/Vistumbler'; }
  })();

  const tagForUrl    = (release.tag_name || '').startsWith('v') ? (release.tag_name || '') : `v${release.tag_name || ''}`;
  const numericVer   = (tagForUrl || '').replace(/^v/i, '');
  const exeFilename  = `Vistumbler_v${numericVer.replace(/\./g,'-')}.exe`;
  const zipFilename  = `Vistumbler_v${numericVer}.zip`;
  const portableFilename = `Vistumbler_v${numericVer}_Portable.zip`;

  const baseReleaseUrl = `https://github.com/${repo}/releases/download/${tagForUrl}`;

  const exeUrl      = exe      ? exe.browser_download_url      : `${baseReleaseUrl}/${exeFilename}`;
  const zipUrl      = zip      ? zip.browser_download_url      : `${baseReleaseUrl}/${zipFilename}`;
  const portableUrl = portable ? portable.browser_download_url : `${baseReleaseUrl}/${portableFilename}`;

  // Detect the indentation that the existing <section class="hero feature"> uses
  const leadMatch = html.match(/(^[\t ]*)<section class="hero feature">/m);
  const sectionIndent = leadMatch ? leadMatch[1] : '';

  // Build the replacement hero block with perfectly matching indentation
  const heroWithBase = buildHeroSection(title, published, body, exeUrl, zipUrl, portableUrl, sectionIndent);

  // Replace the entire existing hero section (including its leading whitespace)
  const newHtml = html.replace(/^[\t ]*<section class="hero feature">[\s\S]*?<\/section>/m, heroWithBase);

  if (newHtml === html) {
    console.log('No replacement performed — hero section not found or unchanged.');
    return;
  }

  safeWrite(idxPath, newHtml);
  console.log('Updated', idxPath, 'with release', title || tag);

  // If we extracted changelog notes, attempt to prepend an entry to Downloads/index.htm
  if (extractedChangelog) {
    try{
      const downloadsPath = path.join(process.cwd(), 'Website', 'Vistumbler.net', 'Downloads', 'index.htm');
      let dhtml = safeRead(downloadsPath);
      if (dhtml !== null) {
        const exists = dhtml.includes(`Vistumbler v${numericVer}`) || dhtml.includes(`/releases/download/${tagForUrl}`);
        if (!exists) {
          const items = extractedChangelog.split(/\r?\n/).map(l => l.trim()).filter(Boolean).map(l => l.replace(/^[-*]\s*/, ''));
          const lis = items.map(i => `\t\t\t\t\t\t<li>${escapeHtml(i)}</li>`).join('\n');

          const releaseBlock = `\n\t\t\t\t<div class="inside_dark_header">\n\t\t\t\t\tVistumbler v${numericVer} ${escapeHtml(published)}\n\t\t\t\t</div>\n\t\t\t\t<div>\n\t\t\t\t\t<ul>\n\t\t\t\t\t\t<li>Download EXE: \n\t\t\t\t\t\t<a href="${exeUrl}" onclick="trackOutboundLink('${exeUrl}'); return false;">\n\t\t\t\t\t\tVistumbler v${numericVer}</a></li>\n\t\t\t\t\t\t<li>Download ZIP: \n\t\t\t\t\t\t<a href="${zipUrl}" onclick="trackOutboundLink('${zipUrl}'); return false;">\n\t\t\t\t\t\tVistumbler v${numericVer} source</a></li>\n\t\t\t\t\t\t<li>Download Portable: \n\t\t\t\t\t\t<a href="${portableUrl}" onclick="trackOutboundLink('${portableUrl}'); return false;">\n\t\t\t\t\t\tVistumbler v${numericVer} Portable</a></li>\n\t\t\t\t\t</ul>\n\t\t\t\t</div>\n\t\t\t\t<div class="verchanges_text">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>Changes </strong></div>\n\t\t\t\t<ul>\n${lis}\n\t\t\t\t</ul>\n\n`;

          const anchor = '<td class="leftalign">';
          const idx = dhtml.indexOf(anchor);
          if (idx !== -1){
            const insertPos = dhtml.indexOf('>', idx) + 1;
            const newDhtml = dhtml.slice(0, insertPos) + releaseBlock + dhtml.slice(insertPos);
            safeWrite(downloadsPath, newDhtml);
            console.log('Prepended release entry to', downloadsPath);
          } else {
            const tableIdx = dhtml.indexOf('<table');
            if (tableIdx !== -1) {
              const tdPos = dhtml.indexOf('<td', tableIdx);
              if (tdPos !== -1) {
                const insertPos2 = dhtml.indexOf('>', tdPos) + 1;
                const newDhtml2 = dhtml.slice(0, insertPos2) + releaseBlock + dhtml.slice(insertPos2);
                safeWrite(downloadsPath, newDhtml2);
                console.log('Inserted release entry into', downloadsPath);
              }
            }
          }
        } else {
          console.log('Downloads page already contains this version, skipping insertion.');
        }
      }
    }catch(e){ console.error('Failed to update Downloads page:', e); }
  }
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
