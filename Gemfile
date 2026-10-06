source "https://rubygems.org"

# Static site generator
gem "jekyll", "~> 4.4"

# Liquid template tags
group :jekyll_plugins do
  gem "jekyll-seo-tag", "~> 2.8"
  gem "jekyll-sitemap", "~> 1.4"
end

# Auto-reload in the browser is built into Jekyll 4 itself
# (`jekyll serve --livereload`), no extra gem required.

# Ruby 3.x no longer bundles a web server with the stdlib
gem "webrick", "~> 1.9"

platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

# Performance booster for watching directories on Windows
gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]
