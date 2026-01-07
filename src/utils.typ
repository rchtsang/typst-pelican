#import "@preview/oxifmt:1.0.0": strfmt

// type checking
#let assert_type(varname, var, typ) = {
  assert(type(var) == typ,
    message: strfmt("`{}` must be {}", varname, str(typ))
  )
}

// embedded javascript
#let embed-js(content) = {
  show selector.or(
    raw.where(lang: "javascript"),
    raw.where(lang: "js"),
  ): it => {
    html.script(it.text)
  }
  content
}
