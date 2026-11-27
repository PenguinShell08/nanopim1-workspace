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
