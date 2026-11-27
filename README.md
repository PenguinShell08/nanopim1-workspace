# nanopim1-armbian

Armbiani kompileerimise töölogi NanoPi M1 jaoks, teostatud kohalikus VBOX Ubuntu VM-is.

Platvorm NanoPi M1 (Allwinner H3), Debian trixie, current kernel 6.18.65.
Tõmbel on forensilised kablid (hooks): journald püsivus, machine-id
normaliseerimine, journal-mirror / shutdown-snapshot / auto-diag (tty1) –
neid kasutatakse taaskäivitustsükkli ja sarnaste probleemide jälgede
kinnijäämiseks.

## Kataloogid
- `scripts/`     kompileerimiseks, eraldamiseks ja diagnostikaks mõeldud skriptid
- `evidence/`    referenstõmmelt eraldatud forensiliste kablite failid, musterina võrdlemiseks
- `screenshots/` VM-i kompileerimisprotsessi kuvatõmmised
- `build-info/`  väljundfailide sha256 kontrollsumma ja kompileerimisinfo

## Tõmbelallaadimine
Releases: <https://github.com/PenguinShell08/nanopim1-armbian/releases>

## Kablite lähtekood
Eraldi repo: <https://github.com/PenguinShell08/nanopim1-forensic>

## Teadaolevad probleemid

### Parandatud (uues tõmmel)
- `machine-id` oli sidekriipsudega UUID-vormingus → journald ei salvestanud püsivalt. Nüüd 32-tähemärgiline hex.
- Puudus `default.target` → süsteem käivitus emergency režiimis. Lisatud.
- Puudusid forensilised kablid → lisatud journald püsivus, journal-mirror, shutdown-snapshot, auto-diag (tty1).

### Diagnoosimata (ootab reaalset riistvara)
- **Taaskäivitustsükkel (reboot-loop):** tõmmbel on vaid diagnoosivahend, põhjuse pole veel leitud.
- Korda probleemi NanoPi M1-l ja saada tagasi logid:
  - `/root/loop-diag.txt`
  - `/var/log/journal-live.txt`
  - `/var/log/shutdown-snapshot.txt`

---

## 中文版

在本地 VBOX Ubuntu VM 里编译 Armbian for NanoPi M1 的工作记录。

板型 NanoPi M1（Allwinner H3），Debian trixie，current 内核 6.18.65。
镜像带取证钩子：journald 持久化、machine-id 规范化、journal-mirror /
shutdown-snapshot / auto-diag（tty1），用来抓重启循环之类问题的现场。

### 目录
- `scripts/`     构建、提取、诊断用的脚本
- `evidence/`    从参考镜像里提取的取证钩子文件，作模板对照
- `screenshots/` VM 构建过程截图
- `build-info/`  产物的 sha256 和构建信息

### 下载镜像
Releases：<https://github.com/PenguinShell08/nanopim1-armbian/releases>

### 钩子源码
单独仓库：<https://github.com/PenguinShell08/nanopim1-forensic>

### 已知问题

#### 已修复（新镜像已解决）
- `machine-id` 为带连字符的 UUID 格式 → journald 不持久化。已规范化为 32 位 hex。
- 缺少 `default.target` → 启动进 emergency 模式。已补回。
- 无取证钩子 → 已加入 journald 持久化、journal-mirror、shutdown-snapshot、auto-diag（tty1）。

#### 未诊断（待真实硬件验证）
- **重启循环（reboot-loop）：** 当前镜像仅为诊断工具，根因尚未定位。
- 请在 NanoPi M1 上复现并回传日志：
  - `/root/loop-diag.txt`
  - `/var/log/journal-live.txt`
  - `/var/log/shutdown-snapshot.txt`
