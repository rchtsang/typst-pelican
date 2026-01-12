#import "@preview/bullseye:0.1.0": *
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

// embedded css
#let embed-css(content) = {
  show raw.where(lang: "css"): it => {
    html.style(it.text)
  }
}

// a wrapper for image to provide args for different output targets
#let img(paged-args: none, html-args: none) = context {
  assert(paged-args != none and html-args != none)
  if target() == "html" {
    html.div(class: "image fit", html.img(..html-args))
  } else {
    image(..paged-args)
  }
}

// wrap content for tabs
//
// for html:
// tab buttons will be rendered in a <div class="tab"> and the array
// of tab-contents (dictionaries containing "class" and "content" keys)
// will be rendered in their own divs with class 
// "tab-content <tab-id> <tab-content.class>"
// 
// for paged:
// all tab-contents will be rendered in their own blocks using blk-args
#let tabs(
  tab-id,
  div-args: (:),
  blk-args: (fill: luma(240), inset: 1em, radius: 5pt),
  tab-contents: (),
) = context {
  assert_type("tab-contents", tab-contents, array)

  if target() == "html" {
    assert_type("tab-id", tab-id, str)
    assert_type("div-args", div-args, dictionary)
    assert("class" not in div-args)

    let baseclass = "tab-content"
    [
      #html.div(class: "tab")[
        #for (i, tab-content) in tab-contents.enumerate() {
          let class = strfmt("tab-link {} {}", tab-id, tab-content.class)
          if i == 0 { class = class + " active" }
          html.elem("button", attrs: (
            class: class,
            onclick: strfmt("show_tab_class(event, \"{}\", \"{}\")", tab-id, tab-content.class),
          ))[#tab-content.class]
        }
      ]
      #for (i, tab-content) in tab-contents.enumerate() {
        let class = if i == 0 {
          strfmt("{} {} {} active", baseclass, tab-id, tab-content.class)
        } else {
          strfmt("{} {} {}", baseclass, tab-id, tab-content.class)
        }
        html.div(
          class: class,
          ..div-args,
          tab-content.content,
        )
      }
    ]

  } else {
    for tab-content in tab-contents {
      block(..blk-args, tab-content.content)
    }
  }
}

#let tabs-js = embed-js(
  ```js
  function show_tab_class(evt, tabcls, tabname) {
    // get elements with class "tab-content <tabcls>"
    console.log(evt, tabcls, tabname)
    let elems = document.getElementsByClassName("tab-content " + tabcls);
    for (let i = 0; i < elems.length; i++) {
      elems[i].className = elems[i].className.replace(" active", "");
      if (elems[i].className.includes(tabname)) {
        elems[i].className += " active";
      }
      console.log(elems[i].className)
    }

    // get elements with class "tab-link <tabcls>"
    let buttons = document.getElementsByClassName("tab-link " + tabcls);
    for (let i = 0; i < buttons.length; i++) {
      buttons[i].className = buttons[i].className.replace(" active", "");
      if (buttons[i].className.includes(tabname)) {
        buttons[i].className += " active";
      }
    }
  }
  ```
)

#let tabs-css(
  tab: (
    overflow: "hidden",
  ),
  tab-button: (
    float: "left",
    border-top: "2px solid #ccc",
    border-color: "black",
    border-radius: "0px",
    outline: "none",
    line-height: "none",
    box-shadow: "none",
  ),
  tab-button-active: (
    border-color: "grey",
  ),
  tab-content: (
    display: "none",
    padding: "1em 2.25em",
    border: "2px solid #ccc",
    border-color: "grey",
    margin-bottom: "2em",
    animation: "fadeEffect 0.75s",
  ),
  tab-content-active: (
    display: "block",
  ),
) = {
  let render-dict(d) = {
    let lines = ()
    for (k, v) in d.pairs() {
      lines.push(strfmt("{}: {};", k, v))
    }
    lines.join("\n")
  }
  // order matters very much!
  show "TAB": _ => render-dict(tab)
  show "TAB_BUTTON": _ => render-dict(tab-button)
  show "TAB_BUTTON_ACIVE": _ => render-dict(tab-button-active)
  show "TAB_CONTENT": _ => render-dict(tab-content)
  show "TAB_CONTENT_ACTIVE": _ => render-dict(tab-content-active)
  embed-css(
    ```css
    .tab {
      TAB
    }

    .tab button {
      TAB_BUTTON
    }

    .tab button.active {
      TAB_BUTTON_ACTIVE
    }

    .tab-content {
      TAB_CONTENT
    }

    .tab-content.active {
      TAB_CONTENT_ACTIVE
    }

    /* fade effect on tab buttons */

    @keyframes fadeEffect {
      from {opacity: 0;}
      to {opacity: 1;}
    }
    ```
  )
}

// an aside block, rendered in html using a div with the "aside" class
// in addition to the provided class string if present.
#let aside(
  div-args: (:),
  blk-args: (
    stroke: (left: 2pt + luma(235)),
    inset: 1em,
  ),
  content,
) = {
  show: show-target(paged: it => block(..blk-args, it))
  show: show-target(html: it => {
    let div-args = div-args
    if "class" in div-args {
      div-args.class = "aside " + div-args.class
    } else {
      div-args.class = "aside"
    }
    html.div(..div-args, it)
  })
  content
}