FIRA-SANS
=========
CLASSIFICATION: Sans-Serif Monospaced


GENERAL INFORMATION
===================

### Problem

Programmers use a lot of symbols, often encoded with several characters.
For human brain sequences like `->`, `<=` or `:=` are single logical token,
even if they take two or three places on the screen. Your eye spends
non-zero amount of energy to scan, parse and join multiple characters
into a single logical one. Ideally, all programming languages should be
designed with full-fledged Unicode symbols for operators, but that’s not
the case yet.

### Solution

Fira Code is a Fira Mono font extended with a set of ligatures for common
programming multi-character combinations.
This is just a font rendering feature: underlying code remains ASCII-compatible.
This helps to read and understand code faster.
For some frequent sequences like `..` or `//` ligatures allow us to correct spacing.

### Editor support

Please refer to [Hasklig Readme](https://github.com/i-tu/Hasklig) for editor support

_Note:_ I’m not a font designer, and Fira Code is built in sort of
[a hacky way](https://github.com/mozilla/Fira/issues/62)
from OTF version of Fira Mono. Please forgive me if it doesn’t work for you.
Help will be greatly appreciated.


AUTHORS
=======
[Nikita Prokopov](http://tonsky.me/)


LICENSE
=======
[SIL Open Font License (OFL)](http://scripts.sil.org/OFL)


UI CONFIGURATION
================
AKKORDEON
DOWNLOAD
AUTHOR
LICENSE
SPECIMEN


TEX CONFIGURATION
=================
KARLBERRYNAME:tfi
FOUNDRY:tonsky
TEXSRCREGULAR:fira-code_regular

