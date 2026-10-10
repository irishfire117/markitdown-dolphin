# markitdown-dolphin

A right-click **Convert to Markdown** action for KDE Dolphin (and the Plasma
desktop) that runs Microsoft's [MarkItDown](https://github.com/microsoft/markitdown)
on a file and saves the result next to it.

- `Spec Sheet.pdf` → `Spec Sheet.md`
- `report.final.docx` → `report.final.md` (only the last extension changes)
- The original file is never modified, and an existing `.md` is never
  overwritten. The new file is saved as `name (1).md`, `name (2).md`, …
- Select several files to convert them all in one go.

A notification shows "Converting to Markdown" while it runs, then changes to
"Converted to Markdown" or "Failed: name" with MarkItDown's error. A failed
conversion leaves no partial `.md` behind.

The whole thing is one file: a Dolphin service menu whose `Exec=` line is a
short `sh` loop. No helper script, no Python dependencies beyond MarkItDown
itself.

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
- `notify-send` (libnotify)

| Distro | Dependencies |
| --- | --- |
| Arch | `sudo pacman -S libnotify python-pipx` |
| Debian / Ubuntu | `sudo apt install libnotify-bin pipx` |
| Fedora | `sudo dnf install libnotify pipx` |

Then install MarkItDown:

```bash
pipx install 'markitdown[all]'
```

On Arch you can use the AUR package `markitdown-bin` instead.

## Install

```bash
git clone https://github.com/irishfire117/markitdown-dolphin.git
install -Dm755 markitdown-dolphin/markitdown.desktop ~/.local/share/kio/servicemenus/markitdown.desktop
```

The mode matters: KF6 ignores service menus that aren't executable. No root
needed.

Right-click a supported file and choose **Convert to Markdown**. If the entry
doesn't appear, close and reopen Dolphin. For desktop icons, log out and back
in.

To update, `git pull` and run the `install` line again.

### Upgrading from the old Python version

Remove the files the old `install.sh` put in place:

```bash
rm -f ~/.local/bin/markitdown-convert ~/.local/share/applications/markitdown-convert.desktop
```

## Uninstall

```bash
rm ~/.local/share/kio/servicemenus/markitdown.desktop
```

## How it works

The `Exec=` line in `markitdown.desktop`, expanded:

```sh
PATH="$PATH:$HOME/.local/bin"            # Dolphin often lacks ~/.local/bin, where pipx puts markitdown
for f; do                                # every selected file (%F)
  b="${f%.*}"                            # report.final.docx -> report.final
  o="$b.md"; n=1
  while [ -e "$o" ]; do                  # never overwrite: name (1).md, name (2).md, ...
    o="$b ($n).md"; n=$((n+1))
  done
  id=$(notify-send -p ... "Converting to Markdown" "${f##*/}")
  if err=$(markitdown "$f" -o "$o" 2>&1 >/dev/null); then
    notify-send -r "$id" ... "Converted to Markdown" "${o##*/}"
  else
    rm -f "$o"
    notify-send -r "$id" ... "Failed: ${f##*/}" "$(echo "$err" | tail -n1)"
  fi
done
```

In the file, `%` is written as `%%` because `%` starts a field code (like `%F`)
in `.desktop` files.

## Troubleshooting

- **Menu entry missing.** KF6 only loads service menus that are executable.
  Check with `ls -l ~/.local/share/kio/servicemenus/markitdown.desktop`, then
  restart Dolphin.
- **"Failed" notification saying `markitdown` was not found.** The action looks on your `PATH` and in
  `~/.local/bin`. If MarkItDown lives somewhere else, add its directory to the
  `PATH=` part of the `Exec=` line.
- **Messy PDF output.** Complex layouts such as textbooks with columns, tables
  and equations convert poorly. That's a limit of MarkItDown's PDF text
  extraction, not of this action. Scanned PDFs with no text layer come out
  nearly empty, since MarkItDown doesn't OCR.
- **A broken file "converts" anyway.** MarkItDown checks what a file actually
  contains, not just its extension. A damaged file may come out as plain text
  instead of failing.

## License

MIT
