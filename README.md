# Kripy: To The Resque

Okay. I've always wanted to play around with background jobs so, as with all my stuff, I looked for something that I could easily deploy to Heroku. I found Trineo's [Resque example](https://github.com/trineo/resque-example) and, after a fare amount of wrangling, managed to get it going. Thing was: I only wanted this to work on a single dyno. As it turns out, Unicorn allows you to get a couple of workers running. I think. Either that or I'm going to cop a charge from Heroku.

# Things To Note

A couple of things.

## Installation

Firstly, make sure you've [installed Ruby](http://www.ruby-lang.org/en/). Also, install the [Heroku Toolbelt](https://toolbelt.heroku.com/) as it includes [Foreman](https://github.com/ddollar/foreman) for running Procfile-based applications.

## Deployment

## Usage
curl -F "file=@src.jpeg" "http://appname.herokuapp.com/upload"

## MIT LICENSE

Copyright (c) 2013 Arturo Escartin

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.