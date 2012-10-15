= alke

* FIX (url)

== DESCRIPTION:

Alke. Greek for spirit of prowess and courage.

== FEATURES/PROBLEMS:

* Rest client
* Easy middleware
* Easy syntax

== SYNOPSIS:

class Widget
  include Alke::Client
  adapter :net_http # or any faraday supports
  parsers json: MyJsonParser
  
  # composes url of [host, prefix, path].join
  host 'http://factory.com'
  prefix '/admin'
  path '/widgets'

  # will only save what is in schema
  schema do
    name :string
    published_at :datetime
    image :file
  end

  middleware do
    insert RequestIdentity, on: [:class, :instance]
    insert GenericSignature, before: [:adapter], on: :class 
  end
  
  def publish
    update(published_at: Time.now)
  end
end

w = Widget.new(name: "WonderKnife")
w.persisted? # => false
w.save # => true

w.update(name: w.name + "(tm)")
# OR
w.name = w.name + "(tm)"
w.save
# OR
w.name = w.name + "(tm)"
w.save do |connection|
  # custom middleare registered with a method: as.
  as user

  # middleware with arg, position specified.
  with ShaSignature, "salt", before: [:adapter]

  # from faraday.
  connection.basic_auth("me", "secret")
end
# OR
w.name = w.name + "(tm)"
w.middleware do |connection|
  # custom middleare registered with a method: as.
  as user

  # middleware with arg, position specified.
  with ShaSignature, "salt", before: [:adapter]

  # from faraday.
  connection.basic_auth("me", "secret")
end
w.save

# find, returns a single object
w = Widget[1] do |connection|
  with ShaSignature, 'salt', replace: GenericSignature
end
w.name # => "WonderKnife(tm)"

w.__headers__ # return faraday headers
w.__response__ # return faraday response
w.__connection__ # returns faraday connection object 
  # that will be recycled and used on subsequent requests.

w.published_at # => nil
w.publish 

# find, returns a collection
c = Widget.all

c.headers # return faraday headers
c.response # return faraday response
c.connection # returns faraday connection object 
  # that will not be reused by default for security

c.each do |w|
  w.publish # will use the default middleware stack
end

# custom class methods and middleware
w = Widget.random # hosed if you need to overide middleware

w = Widget.scope{|c| as(user) }.random
# OR
s = Widget.scope
s.middleware do |connection|
  as user
end
w = s.random
# OR
scope = Alke::Scope.new do |connection|
  as user
end
w = Widget.with(scope).random

# query strings
# /wigets?foo=bar&code=1a35de8c
c = Widget.all(foo: 'bar', 'code' => '1a35de8c')

# /wigets/1?foo=bar&code=1a35de8c
w = Widget[1, foo: 'bar', 'code' => '1a35de8c']

# if you want query stings on your own custom methods, you
# need to manage them.

# multipart

# UploadIO comes from multipart-post
w.image = Faraday::UploadIO.new("file.txt", "text/plain")
w.image = Faraday::UploadIO.new(file_io, "text/plain", "file.txt")

== REQUIREMENTS:

* None

== INSTALL:

* gem install alke

== DEVELOPERS:

After checking out the source, run:

  $ rake newb

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.

== LICENSE:

(The MIT License)

Copyright (c) 2012 Matthew C Smith

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
