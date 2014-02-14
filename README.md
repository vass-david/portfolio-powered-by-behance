# Portfolio Powered by Behance

Personal portfolio using data from your Behance profile cached to redis db to offer faster response and do not reach behance api limit 150 requests per day.

Written for sinatra, but can be used with anything ruby based.

### Dependencies

* rest-client
* redis
* slim

### Advice
When using data from behance, you should always show 'powered by Behance' image somewhere on page. Can be found at [Behance branding guidlines](https://www.behance.net/dev/api/brand). Of course, you should read this entire document.

### Example of use with sinatra

```ruby
# config/behance.yml

client_id: 'y0ur-cl13nt-1d'
user: 'username-or-user-id'

redis: # optional
  db: 1

rendering: # optional
  css_prefix: '.project'
```

```ruby
# app.rb

require 'sinatra/base'
require 'slim'
require 'portfolio-powered-by-behance'

before do
  @portfolio = PortfolioPoweredByBehance::Portfolio.new
end

get '/' do
  @projects = @portfolio.projects
  slim :index
end

get '/projects/:id' do
  @project = @portfolio.project_details params[:id]
  @behance_stylesheet = @project.stylesheet # your behance project stylesheet
  slim :project
end
```

```slim
# views/layout.slim

doctype html
html
  head
    - if @behance_stylesheet
      style type='text/css' rel='stylesheet' = @behance_stylesheet
  body == yield
```

```slim
# views/index.slim

ul
  - @project.each do |p|
    li
      a href="/projects/#{p['id']}"
        img src=p['covers']['404'] alt=p['name']
        .info
          h3 = p['name']
```

```slim
# views/project.slim

.project
  h1 = @project.name
  p.description = @project.description
  ul.fields
    - @project.fields.each do |f|
      li = f

  .body
    == project.markup # your behance project markup

  a href=@project.url show on behance
```
