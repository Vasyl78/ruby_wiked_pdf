# Ruby Wicked PDF
## A PDF generation repo with docker
TODO: Readme will be here


```html
 <!-- templates/helpers/pdf_pagination_js.html.erb -->

<script>
  var pageVars = {};

  function initPageVars() {
    var x = document.location.search.substring(1).split('&');
    for(var i in x) {
      var z=x[i].split('=',2);
      pageVars[z[0]] = decodeURIComponent(z[1]);
    }
  }

  function numberPages() {
    initPageVars();
    var x=['frompage','topage','page','webpage','section','subsection','subsubsection'];
    for(var i in x) {
      var y = document.getElementsByClassName(x[i]);
      for(var j=0; j<y.length; ++j) y[j].textContent = pageVars[x[i]];
    }
  }
</script>
```

```html
<!-- templates/layouts/default.html.erb -->

<!DOCTYPE html>
<html lang="ar">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <%= render_partial "layouts/javascripts" %>
  </head>
  <body>
    <%= yield %>
  </body>
  <%= render_partial "layouts/styles" %>
  <%= render_partial "layouts/javascripts_after_body" %>
</html>
```

```html
<!-- templates/layouts/javascripts.html.erb -->

<%= render_partial "helpers/pdf_pagination_js" %>
```

```html
<!-- templates/layouts/javascripts_after_body.html.erb -->

```

```html
<!-- templates/layouts/javascripts_after_body.html.erb -->

```

```html
<!-- templates/layouts/styles.html.erb -->

<style>
  body {
    margin: 0;
    padding: 0;
    color: #000;
  }
  .display-none {
    display: none;
  }
</style>
```

```sh
./bin/wikedpdf_generate_pdf \
  --body-html test_html_body.html \
  --header-html test_html_header.html \
  --footer-html test_html_footer.html \
  --margin-bottom 0 \
  --margin-left 0 \
  --margin-right 0 \
  --margin-top 0 \
  --orientation Portrait
```

```sh
./bin/wikedpdf_generate_pdf \
  --body-template test_body.html.erb \
  --body-layout layouts/test_body.html.erb \
  --no-skip-body-layout \
  --header-template test_header.html.erb \
  --header-layout layouts/test_header.html.erb \
  --no-skip-header-layout \
  --footer-template test_footer.html.erb \
  --footer-layout layouts/test_footer.html.erb \
  --no-skip-footer-layout \
  --margin-bottom 0 \
  --margin-left 0 \
  --margin-right 0 \
  --margin-top 0 \
  --orientation Portrait\
  --template-data '
    {
      "key1": "value1",
      "key2": "value2",
      "key3": "value3",
      "key4": "value4",
      "key5": "value5",
      "key6": "value6",
      "key7": "value7"
    }
  '
```

```sh
docker build -f docker/Dockerfile --platform=linux/amd64 -t ruby-wiked-pdf:latest .
```

```sh
docker run --platform linux/amd64 \
           --rm \
           -v $(pwd)/templates:/app/templates \
           -v $(pwd)/output:/app/output \
           ruby-wiked-pdf:latest \
           bundle exec ./bin/wikedpdf_generate_pdf --help
```

```sh
docker run --platform linux/amd64 \
           --rm \
           -v $(pwd)/templates:/app/templates \
           -v $(pwd)/output:/app/output \
           ruby-wiked-pdf:latest \
           bundle exec ./bin/wikedpdf_generate_pdf \
           --body-template pdf_template.html.erb \
           --body-layout layouts/default.html.erb \
           --margin-bottom 0 \
           --margin-left 0 \
           --margin-right 0 \
           --margin-top 0 \
           --orientation Portrait \
           --template-data '
             {
               "key1": "value1",
               "key2": "value2",
               "key3": "value3",
               "key4": "value4",
               "key5": "value5",
               "key6": "value6",
               "key7": "value7"
             }
           '
```