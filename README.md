# markitdown-dolphin

A right-click **Convert to Markdown** action for KDE Dolphin (and the Plasma
desktop) that runs Microsoft's [MarkItDown](https://github.com/microsoft/markitdown)
on a file and saves the result next to it.

- `Spec Sheet.pdf` → `Spec Sheet.md`
- `report.final.docx` → `report.final.md` (only the last extension changes)
- The original file is never modified, and an existing `.md` is never
  overwritten. The new file is saved as `name (1).md`, `name (2).md`, …
- Select several files to convert them all in one go.

While it runs, progress shows in Plasma's notification area just like a Dolphin
file copy, with a **Cancel** button. Cancelling stops MarkItDown and deletes
the half-written `.md`. When it finishes, the notification offers to open the
file or its folder.

## Supported formats

The menu entry only appears on files MarkItDown can convert:

| Type | Extensions |
| --- | --- |
| PDF | `.pdf` |
| Word | `.docx` |
| PowerPoint | `.pptx` |
| Excel | `.xlsx`, `.xls` |
| Web / data | `.html`, `.xhtml`, `.csv`, `.json`, `.xml` |
| E-books | `.epub` |
| Outlook | `.msg` |
| Jupyter | `.ipynb` |

Images and audio are left out on purpose. Without extra setup (an LLM for
image captions/OCR, speech-to-text for audio) MarkItDown only extracts their
metadata.

## Requirements

- KDE Plasma 6 / Dolphin (KF6)
- [MarkItDown](https://github.com/microsoft/markitdown) with its optional
  converters, as a `markitdown` command
- Python 3 with PyGObject
- `notify-send` (libnotify)

| Distro | Dependencies |
| --- | --- |
| Arch | `sudo pacman -S python-gobject libnotify python-pipx` |
| Debian / Ubuntu | `sudo apt install python3-gi libnotify-bin pipx` |
| Fedora | `sudo dnf install python3-gobject libnotify pipx` |

Then install MarkItDown:

```bash
pipx install 'markitdown[all]'
```

On Arch you can use the AUR package `markitdown-bin` instead.

## Install

```bash
git clone https://github.com/irishfire117/markitdown-dolphin.git
cd markitdown-dolphin
./install.sh
```

This installs for the current user only (no root needed):

| File | Purpose |
| --- | --- |
| `~/.local/bin/markitdown-convert` | The converter script |
| `~/.local/share/kio/servicemenus/markitdown.desktop` | The right-click entry |
| `~/.local/share/applications/markitdown-convert.desktop` | Hidden entry that gives the progress notification its name and icon |

Right-click a supported file and choose **Convert to Markdown**. If the entry
doesn't appear, close and reopen Dolphin. For desktop icons, log out and back
in.

To update, `git pull` and run `./install.sh` again.

## Uninstall

```bash
./install.sh --uninstall
```

## Command line

The script works outside Dolphin too:

```bash
markitdown-convert *.pdf
```

Set `MARKITDOWN=/path/to/markitdown` to use a specific MarkItDown binary.

## Troubleshooting

- **Menu entry missing.** KF6 only loads service menus that are executable.
  Check with `ls -l ~/.local/share/kio/servicemenus/markitdown.desktop`, then
  restart Dolphin.
- **"MarkItDown not found" notification.** The script looks on your `PATH` and
  in `~/.local/bin`. If MarkItDown lives somewhere else, set `MARKITDOWN` in
  your session environment, e.g. in `~/.config/environment.d/markitdown.conf`.
- **No progress notification, only a pop-up at the end.** The script falls
  back to plain notifications when Plasma's job tracker
  (`org.kde.JobViewServer`) isn't available, e.g. outside Plasma.
- **Messy PDF output.** Complex layouts such as textbooks with columns, tables
  and equations convert poorly. That's a limit of MarkItDown's PDF text
  extraction, not of this action.
- **A broken file "converts" anyway.** MarkItDown checks what a file actually
  contains, not just its extension. A damaged file may come out as plain text
  instead of failing.

## License

MIT
