#let table_of_contents(outlined: true, body) = {
  align(center)[
    #block(below: 20pt)[
      #show heading: it => [
        #set text(size: 16pt)
        #it.body
      ]
      #heading(outlined: outlined)[
        #upper(body)
      ]
    ]
  ]
}
