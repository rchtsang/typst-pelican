#import "@preview/oxifmt:1.0.0": strfmt
#import "utils.typ": assert_type

#let article(
  title: none,
  date: none,
  modified: datetime.today(),
  tags: none,
  keywords: none,
  category: none,
  slug: none,
  author: none,
  authors: (),
  summary: none,
  lang: "en",
  translation: false,
  status: "draft",
  template: "article",
  save_as: none,
  url: none,
  doc,
) = {
  // check required arguments
  assert_type("authors", authors, array)
  let missing_required = (
    title == none,
    date == none,
    slug == none,
    (author == none) and (authors.len() == 0),
  ).fold(false, (acc, cond) => acc or cond)
  assert(missing_required,
    message: "required arguments: (`title`,`date`,`slug`,`author`/`authors`)")
  assert_type("title", title, str)
  assert_type("date", date, datetime)
  assert_type("modified", modified, datetime)
  assert_type("slug", slug, str)
  assert(not ((author != none) and (authors.len() > 0)),
    message: "`author` and `authors` are mutually exclusive")
  assert_type("lang", lang, str)
  assert_type("translation", translation, bool)
  assert_type("status", status, str)
  assert(status in ("draft", "hidden", "skip", "published"),
    message: strfmt("invalid status: {}", status))
  assert_type("template", template, str)

  // only use `authors` for metadata
  if author != none {
    assert_type("author", author, str)
    authors.push(author)
  }

  let datefmt = "[year]-[month]-[day] [hour]:[minute]"

  // build metadata
  let metadata = (:)
  metadata.title = title
  metadata.date = date.display(datefmt)

  metadata.modified = modified.display(datefmt)
  metadata.slug = slug
  metadata.authors = authors.join(", ")
  
  if tags != none {
    assert_type("tags", tags, array)
    metadata.tags = tags.join(", ")
  }
  if keywords != none {
    assert_type("keywords", keywords, array)
    metadata.keywords = keywords.join(", ")
  }
  if category != none {
    assert_type("category", category, str)
    metadata.category = cateogry
  }
  if summary != none {
    assert_type("summary", summary, str)
    metadata.summary = summary
  }
  if save_as != none {
    assert_type("save_as", save_as, str)
    metadata.save_as = save_as
  }
  if url != none {
    assert_type("url", url, str)
    metadata.url = url
  }

  // show rules
  show math.equation: it => {
    show: if it.block { it => it } else { box }
    html.frame(it)
  }

  // build article html
  html.html[
    #html.head[
      #for (field, value) in metadata {
        [#html.meta(name: field, content: value)]
      }
    ]
    #html.body(doc)
  ]
}
