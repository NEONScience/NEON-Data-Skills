---
syncID: 8ab4445008fd408fab9992c5c8751505
title: "Test reticulate tabs"
description: Test for tabbed tutorials with R and Python code. Do not publish this tutorial.
dateCreated: '2024-04-25'
dataProducts: 
authors: Claire K. Lunch
contributors: 
estimatedTime: 0 hours
packagesLibraries: neonUtilities, neonutilities
topics: data-management, rep-sci
languageTool: R, Python
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Other/Concept-intros/testing/test_code_tabs.R
tutorialSeries:
urlTitle: test-code-tabs
---




<!--html_preserve-->

// find an element with class `tabset` and convert its subsequent bullet list or headings to tabs;
// see documentation at: https://yihui.org/en/2023/10/section-tabsets/
document.querySelectorAll('.tabset').forEach(h => {
  const links = [...h.querySelectorAll(':scope > .tab-link')],
        panes = [...h.querySelectorAll(':scope > .tab-pane')];
  function activate(i) {
    function a(x, i) {
      x.forEach((el, k) => el.classList[k === i ? 'add' : 'remove']('active'));
    }
    a(links, i); a(panes, i);
  }
  function newEl(tag, cls) {
    const el = document.createElement(tag);
    el.className = cls;
    return el;
  }
  let n = -1, el = h.nextElementSibling, p;
  // if the first sibling is <ul>, try to convert it to tabset
  if (links.length === 0 && el.tagName === 'UL') {
    [...el.children].forEach(li => {
      const l = li.firstElementChild;
      if (!l) return;
      const l2 = newEl('div', 'tab-link');
      l2.append(l);
      l.outerHTML = l.innerHTML;
      if (/<!--active-->/.test(l2.innerHTML)) l2.classList.add('active');
      el.before(l2);
      const p = newEl('div', 'tab-pane');
      l2.after(p);
      [...li.children].forEach(l => p.append(l));
      links.push(l2); panes.push(p);
    });
    el.remove();
  }
  // create a tabset using headings if the above didn't work
  if (links.length === 0) while (el) {
    // convert headings to tabs
    if (el.nodeName === '#comment' && el.nodeValue.trim() === `tabset:${h.id}`)
      break;  // quit after <!--tabset:id-->
    const t = el.tagName;
    if (/^H[1-6]$/.test(t)) {
      const n2 = +t.replace('H', '');
      if (n2 <= n) break;  // quit after a higher-level heading
      if (n < 0) n = n2 - 1;
      // find the next lower-level heading and start creating a tab
      if (n2 === n + 1) {
        p = newEl('div', 'tab-pane');
        el.after(p);
        el.classList.add('tab-link');
        el.querySelector('.anchor')?.remove();
        el.outerHTML = el.outerHTML.replace(/^<h[1-6](.*)h[1-6]>$/, '<div$1div>');
        el = p.previousElementSibling;
        links.push(el); panes.push(p);
        el = p.nextSibling;
        continue;
      }
    }
    if (p) {
      p.append(el);
      el = p;
    }
    el = el.nextSibling;
  }
  // if the initial tabset container is empty, move links and panes into it
  if (h.innerText.trim() == '') {
    links.forEach(l => h.append(l));
    panes.forEach(p => h.append(p));
  }
  // activate one tab initially if none is active
  let init = 0;
  links.forEach((l, i) => {
    i > 0 && links[i - 1].after(l);  // move tab links together
    l.onclick = () => activate(i);  // add the click event
    if (l.classList.contains('active')) init = i;
  });
  activate(init);
});

<div id="load-neonutilities-or-neonutilities-package" class="section level2 tabset">
<h2 class="tabset">Load neonUtilities or neonutilities package</h2>
<div id="r" class="section level3">
<h3>R</h3>
<pre class="r"><code>library(neonUtilities)</code></pre>
</div>
<div id="python" class="section level3">
<h3>Python</h3>
<pre class="python"><code>import neonutilities as nu</code></pre>
</div>
</div>
<div id="get-a-citation" class="section level2 tabset">
<h2 class="tabset">Get a citation</h2>
<div id="r-1" class="section level3">
<h3>R</h3>
<pre class="r"><code>getCitation(dpID=&#39;DP1.20093.001&#39;, release=&#39;RELEASE-2024&#39;)</code></pre>
<pre><code>## [1] &quot;@misc{https://doi.org/10.48443/fdfd-d514,\n  doi = {10.48443/FDFD-D514},\n  url = {https://data.neonscience.org/data-products/DP1.20093.001/RELEASE-2024},\n  author = {{National Ecological Observatory Network (NEON)}},\n  keywords = {chemistry, water quality, anions, cations, alkalinity, nutrients, surface water, nitrogen (N), carbon (C), total carbon (TC), acid neutralizing capacity (ANC), analytes, grab samples, chemical properties, swc, phosphorus (P)},\n  language = {en},\n  title = {Chemical properties of surface water (DP1.20093.001)},\n  publisher = {National Ecological Observatory Network (NEON)},\n  year = {2024},\n  copyright = {Creative Commons Zero v1.0 Universal}\n}\n&quot;</code></pre>
</div>
<div id="python-1" class="section level3">
<h3>Python</h3>
<pre class="python"><code>nu.get_citation(dpID=&#39;DP1.20093.001&#39;, release=&#39;RELEASE-2024&#39;)</code></pre>
<pre><code>## &#39;@misc{https://doi.org/10.48443/fdfd-d514,\n  doi = {10.48443/FDFD-D514},\n  url = {https://data.neonscience.org/data-products/DP1.20093.001/RELEASE-2024},\n  author = {{National Ecological Observatory Network (NEON)}},\n  keywords = {chemistry, water quality, anions, cations, alkalinity, nutrients, surface water, nitrogen (N), carbon (C), total carbon (TC), acid neutralizing capacity (ANC), analytes, grab samples, chemical properties, swc, phosphorus (P)},\n  language = {en},\n  title = {Chemical properties of surface water (DP1.20093.001)},\n  publisher = {National Ecological Observatory Network (NEON)},\n  year = {2024},\n  copyright = {Creative Commons Zero v1.0 Universal}\n}\n&#39;</code></pre>
</div>
</div>
<!--/html_preserve-->
