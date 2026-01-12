# typst-pelican

an unofficial typst package for building html article content for 
[pelican](https://getpelican.com/).

## requirements

software requirements:
- python
  - toml
- typst

## installing

clone this repository, then run the python install script:
```
python install.py
```

this is an unofficial package and will be installed in one of the following
locations depending on your system (see typst's readme on
[packages](https://github.com/typst/packages/blob/main/README.md)):

- linux:
  - `$XDG_DATA_HOME/typst/packages/local`
  - `~/.local/share/typst/packages/local`
- macos:
  - `~/Library/Application\ Support/typst/packages/local`
- windows:
  - `%APPDATA%\typst\packages\local\`


## usage

```typst
#import "@local/typst-pelican:0.1.0" as pelican

// see https://docs.getpelican.com/en/latest/content.html
// for description of how fields are used.
// all fields are used only for metadata and do not affect doc contents
#show doc: pelican.article(
  title: "my title",                // default: none
  date: "YYYY-MM-DD HH:SS",         // default: none
  modified: "YYYY-MM-DD HH:SS",     // default: none
  tags: ("tag1", "tag2", "tag3"),   // default: none
  keywords: ("kw1", "hw2"),         // default: none
  category: "examples",             // default: none
  slug: "typst-pelican-example",    // default: none
  author: "ryan tsang",             // `author` xor `authors`
  // authors: ("ryan tsang", "john doe"),
  summary: "a brief description",   // default: none
  lang: "en",                       // default: "en"
  translation: false,               // default: false
  status: "draft",                  // default: "published"
  template: "page",                 // default: "article"
  save_as: "relative/path/to/file", // default: none
  url: "https://example.com/demo",  // default: none
  styles: ("custom.css",),          // default: ()
  scripts: ("custom.js",),          // default: ()
  doc,
)
```
