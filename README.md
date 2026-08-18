# 2026 Manipal Cryptology

Coursework for this subject, written in [Typst](https://typst.app) and built in Docker.

## Downloads

Every push to `main` compiles each assignment to a PDF and attaches it to the [latest release](../../releases/latest). Files are named `<reg_no>_<name>_<course>_<course_code>_<assignment_no>.pdf` from `config.json`. Grab the whole set from the [release](../../releases/latest), or pick one below.

### Theory

<!-- THEORY:START -->

| # | Assignment | Download |
| :-- | :-- | :-- |
| 01 | Security Features in Real World Applications | [PDF](../../releases/download/latest/261100690032_Anish_Shobith_P_S_Cryptology_CYE_5101_01.pdf) |
| 02 | Caesar, Shift and ROT13 Ciphers | [PDF](../../releases/download/latest/261100690032_Anish_Shobith_P_S_Cryptology_CYE_5101_02.pdf) |

<!-- THEORY:END -->

### Lab

<!-- LAB:START -->

| # | Assignment | Download |
| :-- | :-- | :-- |
| 02 | Capturing Login Credentials over HTTP and HTTPS with Wireshark | [PDF](../../releases/download/latest/261100690032_Anish_Shobith_P_S_Cryptology_Lab_CYE_5151_02.pdf) |

<!-- LAB:END -->

## Set your identity

Edit `config.json` once. The PDF filenames, cover, and header all read from it.

```json
{
  "author": "Student Name",
  "reg_no": "241234567",
  "course": "Subject Name",
  "course_code": "SUB 1001",
  "kinds": {
    "Lab": { "course": "Subject Name Lab", "course_code": "SUB 1002" }
  }
}
```

Lab and theory can carry a different name or code. An entry under `kinds` overrides `course`, `course_code`, or both for that kind. Drop the top-level pair and give every kind its own if nothing is shared. A document's `main.typ` overrides either for one assignment.

## Add an assignment

Each assignment is a folder with a `main.typ`, under `assignments/theory/` or `assignments/lab/`. Name the folder `NN-slug`, e.g. `02-substitution-cipher`. The leading number becomes the assignment number in the filename and the table above.

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

Set `kind` to `"Theory"` or `"Lab"`. It shows on the cover and header. Override any `config.json` value for a single document here too, e.g. `course: "Cryptology"`.

## Build locally

Docker is the only requirement.

```bash
make all
```

PDFs land in `dist/`. For a single assignment:

```bash
make build DIR=assignments/theory/02-substitution-cipher
make watch DIR=assignments/theory/02-substitution-cipher
```

## License

See [LICENSE](LICENSE).

---

<sub>Generated from the [anishshobithpscollege/manipal_assignment_template](https://github.com/anishshobithpscollege/manipal_assignment_template) template. A monthly sync PR keeps the shared Typst template, `Dockerfile`, and `Makefile` current.</sub>
