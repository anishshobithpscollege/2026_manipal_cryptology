# 2026_manipal_cryptology

Coursework for this subject, written in [Typst](https://typst.app) and built in Docker.

Generated from the [anishshobithpscollege/manipal_assignment_template](https://github.com/anishshobithpscollege/manipal_assignment_template) assignment template. A monthly **Template sync** workflow opens a pull request whenever the template's shared parts (Typst template, `Dockerfile`, `Makefile`) change, so this repo stays current. Your assignments, `config.json`, and README are left untouched.

## Download the assignments

Every push to `main` compiles each assignment to a PDF and attaches it to the **[latest release](../../releases/latest)**. Each file is named `<reg_no>_<name>_<assignment_no>.pdf`, from the identity in `config.json`.

The table below is regenerated automatically on every build — no need to edit it.

<!-- ASSIGNMENTS:START -->

| # | Assignment | Kind | Download |
| :-- | :-- | :-- | :-- |
| 01 | Security Features in Real World Applications | Theory | [PDF](../../releases/download/latest/261100690032_Anish_Shobith_P_S_01.pdf) |

<!-- ASSIGNMENTS:END -->

> Grab everything at once from the [latest release](../../releases/latest), or click a **PDF** link above for a single assignment. The [Actions tab](../../actions) also keeps the build log and a zipped `pdfs` artifact for each run.

## Configure

Set your identity once in `config.json` — the PDF filenames and every document's cover and header read from it:

```json
{
  "author": "Student Name",
  "reg_no": "241234567",
  "course": "Subject Name",
  "course_code": "SUB 1001"
}
```

## Write an assignment

Each assignment is a folder under `assignments/`, grouped by `theory/` or `lab/`, with a `main.typ`. **Name the folder `NN-slug`** (e.g. `02-substitution-cipher`) — the leading number becomes the assignment number in the PDF filename and the table above.

```typst
#import "/template/lib.typ": *

#show: assignment.with(
  title: "Your Title",
  number: "Assignment 02",
  kind: "Theory",
)

= First section

Your content.
```

`kind: "Theory"` or `kind: "Lab"` shows on the cover and in the header. Override any `config.json` value for a single document here too, e.g. `course: "Cryptology"`.

## Build locally

Docker is the only requirement.

```bash
make all
```

PDFs land in `dist/`. To build or live-preview a single assignment:

```bash
make build DIR=assignments/theory/02-substitution-cipher
make watch DIR=assignments/theory/02-substitution-cipher
```

## License

See [LICENSE](LICENSE).
