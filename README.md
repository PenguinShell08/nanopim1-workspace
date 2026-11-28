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
- **`auto-diag.service` plokkis sisselogimist ~31 s.** Ühik oli `multi-user.target` kriitilisel teel ja skript lõppes `sleep 30` (tty1 fotode aken). Nüüd on ühel `After=multi-user.target` — 30 s aken jookseb pärast sisselogimise saadavust; multi-user saavutatakse ~9,5 s (varem ~40 s).
- **Forensiliste logide kadumine pärast toiteühenduse katkestamist.** `/var/log` on zram (RAM). `journal-mirror` kirjutab nüüd `/root/journal-live.txt` (SD-kaardil) ja `auto-diag.sh` luged seda. (`journalctl -b -1` töötab endiselt, sest `armbian-ramlog` sünkab `/var/log` → `/var/log.hdd` puhas väljalülituse ajal.)
- `journal-mirror.service` ja `shutdown-snapshot.service`: `WantedBy=` oli vale sektsioonis `[Unit]` (systemd hoiatas "Unknown key"). Viidi `[Install]` sektsiooni — `systemd-analyze verify` on nüüd puhas.

### Taaskäivitustsükkel (reboot-loop) — uued andmed (reaalne riistvara)
- Ajaloo `journalctl --list-boots` järgi oli kaks lühikest käivitust (11-27: 4 s; 11-28: 2 s), kuid **ühelgi polnud panic/oops/error** — logid lõpevad järsku tavaoperatsiooni keskel. See viitab välistele pingutusele (toite-/resetnupuvajutusele), mitte tarkvaravigale.
- Paranduste tegemise järel taaskäivitustsükkli pole kordunud (praegune käivitus stabiilne). **Põhjus on jätkuvalt "konkluusiooni vaba"** — pole kordunud pärast parandusi.
- Pärast toiteühenduse katkestamist mitte kaduvad failid (SD-kaardil):
  - `/root/loop-diag.txt` — iga käivituse täielik journal
  - `/root/journal-live.txt` — reaalajas peegel (journal-mirror)
  - `/var/log/shutdown-snapshot.txt` — luuakse ainult puhas väljalülituse/reboot ajal

### Kahjutu kernel/käivituse müra (pole viga, ära segi)
- `simple-framebuffer already registered` — sunxi mainline teadaolev.
- `lima Failed to register cooling device` — GPU jahutusseade puudub, kahjutu.
- `90-alsa-restore.rules` GOTO no matching label — distro udev reegli viga, ei mõjuta.
- `systemd-tmpfiles cannot set flags on /var/log/journal` — zram on tmpfs, lippide seadmine ei tööta, kahjutu.
- `armbian-ramlog e2label Bad magic number on /dev/zram0` — kosmeetiline, zram0 on swap.
- `System is tainted: unmerged-bin` — Armbiani eelnimetatud, pole viga.
- `end0: Failed to reset the dma` — sunxi eripära, link tuleb üles normaalne (100 Mbps/Full).
- `armbian-led-state.service` ~9,8 s — upstream, pole kriitilisel teel.

### Võrgu seadistamine esimesel käivitusel

- Minimal-tõmmel on `/etc/systemd/network/` all vaid `00-armbian.network.readme` — **ühtegi tegelikku `.network` faili ei ole**; `NetworkManager` ega `ifupdown` pole paigaldatud.
- Liidet nimetatakse käivitamisel ümber `eth0` → `end0` (systemd ennustatav nimekus), seega isegi olemasolev konfiguratsioon ei jõuaks rakendatud.
- Tulemus: füüsiline link toimib (100 Mbps täisdupleks), kuid `end0` ei saa IPv4 aadressi; `ip addr` näitab ainult IPv6 link-local-aadressi.
- **Lahendus** (üks kord, jääb pärast taaskäivitust alles):

```sh
cat > /etc/systemd/network/10-end0.network <<'EOF'
[Match]
Name=end0

[Network]
DHCP=yes
EOF

systemctl enable --now systemd-networkd
```

- Kui ühendad Windowsi ICS-i kaudu, saab plaat aadressi `192.168.137.x`. **Sulgevärav `192.168.137.1` ei vasta pingile — see on normaalse** (Windowsi Public-tülfirefüürib vaikimisi sissetuleva ICMP Echo päringu, mis ei mõjuta NAT-edastamist ega DNS-i). Kontrolli välisvõrgu `ping 223.5.5.5` ja `curl` käsuga.
- Kui haldad plaati kaugühenduse kaudu, soovita seada staatiline IP või ruuterile DHCP-reservatsioon plaadi MAC-i järgi — muidu võib aadress pärast taaskäivitust vahetada (nähtud `.22 → .241`).

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
- **`auto-diag.service` 曾阻塞登录约 31 秒。** 该单元在 `multi-user.target` 关键路径上，脚本末尾的 `sleep 30`（tty1 拍照窗口）会挡住登录/SSH。现已加 `After=multi-user.target`——30 秒窗口在登录就绪后才运行；multi-user 约 9.5 秒达成（原约 40 秒）。
- **取证日志硬断电丢失。** `/var/log` 是 zram（内存）。`journal-mirror` 改写到 `/root/journal-live.txt`（SD 卡上），`auto-diag.sh` 同步改读该路径。（`journalctl -b -1` 仍可用，因为 `armbian-ramlog` 在干净关机时把 `/var/log` 落盘到 `/var/log.hdd`。）
- `journal-mirror.service` 和 `shutdown-snapshot.service`：`WantedBy=` 误放在 `[Unit]` 段（systemd 报 "Unknown key"），已移入 `[Install]` 段——`systemd-analyze verify` 现在干净无警告。

#### 重启循环（reboot-loop）—— 真机新进展
- `journalctl --list-boots` 历史中有两次短暂启动（11-27：4 秒；11-28：2 秒），但**均无 panic/oops/error**——日志在正常运行中戛然而止，更像外部断电/复位，而非软件故障。
- 应用上述修复后**未再复现重启循环**（当前启动稳定）。**根因仍"待定"**——修复后未复现，无法定位。
- 断电不丢的取证文件（在 SD 卡上）：
  - `/root/loop-diag.txt` —— 每次启动的完整 journal
  - `/root/journal-live.txt` —— 实时镜像（journal-mirror）
  - `/var/log/shutdown-snapshot.txt` —— 仅在干净关机/重启时生成

#### 无害的内核/启动噪声（不是 bug，勿误判）
- `simple-framebuffer already registered` —— sunxi mainline 已知问题。
- `lima Failed to register cooling device` —— GPU 无散热设备，无害。
- `90-alsa-restore.rules` GOTO no matching label —— 发行版 udev 规则问题，无影响。
- `systemd-tmpfiles cannot set flags on /var/log/journal` —— zram 是 tmpfs，无法设标记，无害。
- `armbian-ramlog e2label Bad magic number on /dev/zram0` —— 纯提示，zram0 是 swap。
- `System is tainted: unmerged-bin` —— Armbian 预置，非错误。
- `end0: Failed to reset the dma` —— sunxi 特性，链路正常起来（100Mbps/全双工）。
- `armbian-led-state.service` ~9.8s —— upstream 行为，不在关键路径上。

#### 首次启动无网络（需手动配置一次）
- minimal 镜像的 `/etc/systemd/network/` 下只有 `00-armbian.network.readme` 说明文件，**没有任何 `.network` 配置**；`NetworkManager` 和 `ifupdown` 也都未安装。
- 接口在启动时被从 `eth0` 重命名为 `end0`（systemd 可预测命名），所以即使有配置也不会命中。
- 现象：物理链路正常（100M 全双工），但 `end0` 拿不到 IPv4，`ip addr` 只有 IPv6 link-local。
- **修复**（一次即可，重启后保留）：

```sh
cat > /etc/systemd/network/10-end0.network <<'EOF'
[Match]
Name=end0

[Network]
DHCP=yes
EOF

systemctl enable --now systemd-networkd
```

- 接 Windows ICS 时板子会拿到 `192.168.137.x`；**网关 `192.168.137.1` 不回 ping 属正常**（Windows Public 防火墙默认阻止入站 ICMP Echo，不影响 NAT 转发和 DNS），用 `ping 223.5.5.5` 和 `curl` 验证外网即可。
- 若需远程管理，建议给板子设静态 IP 或在路由器上按 MAC 做 DHCP 保留——否则重启后 IP 可能变化（已观察到 `.22 → .241`）。
