#let assert_type(varname, var, typ) = {
  assert(type(var) == typ,
    message: strfmt("`{}` must be {}", varname, str(typ))
  )
}
