# RY21 Toolbox

A personal collection of free system utilities, OS tweaks and scripts, mostly for Windows and some for Linux, kept current against where each tool is officially published.

## Language

**Toolbox**:
The whole curated collection of entries, together with the means to fetch their latest versions.
_Avoid_: Kit, bundle, library

**Entry**:
One item in the toolbox, of exactly one kind: software, registry tweak or script. Every entry has a name, category, platform and description.
_Avoid_: Item, package, tool

**Software entry**:
An entry for a third-party program obtained from its upstream source (e.g. HWiNFO, a media player).
_Avoid_: App, utility, program

**Registry tweak**:
An entry that is a `.reg` file you author, which changes Windows behaviour. It must state what it changes and how to reverse it.
_Avoid_: Reg hack, registry mod

**Script**:
An entry that is a file you author and that runs on the OS to do something to it. It must state what it does and how to reverse it.
_Avoid_: Macro, batch (unless literally a `.bat`)

**Upstream source**:
The official release location owned by a software entry's vendor or maintainer (vendor download page or release feed). Only this counts as a valid origin; repackagers and re-uploads do not.
_Avoid_: Resource holder, mirror, download site

**Latest known version**:
The newest version published at an entry's upstream source. Only software entries have one; registry tweaks and scripts are versioned in this repo.
_Avoid_: Current version, newest build

**Platform**:
Which operating system an entry applies to: Windows, Linux or both.
_Avoid_: OS target, compatibility

**License type**:
The terms under which an entry's software may be used (e.g. open source, freeware, free for personal use only). Recorded on every software entry.
_Avoid_: Pricing, edition

**Category**:
The single group an entry belongs to, chosen from a fixed list the project owns (e.g. monitoring, stress-test, benchmark, media, drivers, tweaks).
_Avoid_: Tag, label

**Delivery**:
How a software entry is obtained and run: as a portable build or as an installer. Portable is preferred whenever the upstream offers one.
_Avoid_: Package type, format

**Version source**:
How a software entry's latest known version is discovered at its upstream source (e.g. a winget package, a GitHub Releases feed, or, as a flagged last resort, a scraped page).
_Avoid_: Update feed, checker

**Fragile entry**:
A software entry whose version source is scraped from a page rather than a stable feed, so it may break when the vendor changes the page.
_Avoid_: Unstable entry

**Installed version**:
The version of a software entry actually present on the machine, read from the system and never from a record the toolbox keeps.
_Avoid_: Local version, tracked version

**Outdated**:
The state of an entry whose installed version is older than its latest known version.
_Avoid_: Stale, behind

**Undo**:
The paired file that reverses a registry tweak or script. An entry of those kinds is invalid without one.
_Avoid_: Rollback, revert script

**Driver check**:
A toolbox feature, separate from entries, that reads the installed hardware and its driver version, finds the vendor's upstream, and reports whether the driver is out of date. It reports only and never installs. Covers NVIDIA and AMD graphics and the motherboard.
_Avoid_: Driver updater, driver scan

**Motherboard identity**:
The manufacturer and model of the board, read from the machine, used by a driver check to point to that vendor's support page.
_Avoid_: Board info, mobo name

**Risky entry**:
A registry tweak or script, flagged as such because it modifies the OS and needs a description and a reversal.
_Avoid_: Dangerous, advanced
