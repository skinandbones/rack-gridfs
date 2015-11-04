Rack::GridFS
============

[![Gem Version](https://badge.fury.io/rb/rack-gridfs.svg)][gem]
[![Build Status](https://travis-ci.org/skinandbones/rack-gridfs.svg?branch=0.4.x)][travis]

Rack::GridFS is a Rack middleware for creating HTTP endpoints for files
stored in MongoDB's GridFS. You can configure a prefix string which
will be used to match the path of a request, and further look up GridFS
files based on either their `ObjectId` or `filename` field.

For example,

    GET '/gridfs/someobjectid'

If the prefix is "gridfs", then the id will be be "someobjectid".

You can also use `Rack::GridFS::Endpoint` as a rack endpoint if you want to
handle routing another way.

[gem]: https://badge.fury.io/rb/rack-gridfs
[travis]: https://travis-ci.org/skinandbones/rack-gridfs

### Status ###

The library hasn't been updated for some time and is in the process of being
brought up to modern standards on the `master` branch. It does not yet work
with 2.x versions of the `mongo` driver gem, which means that you will not be
able to use it together with Mongoid 5.x (patches welcome if you need it faster
than we can deliver it). Since Mongoid 3.x and 4.x use the `moped` gem instead
of `mongo`, though, you may be able to use the current rack-gridfs release in
apps still using one of these older Mongoid versions. rack-gridfs should
support the latest 1.x `mongo` releases, [which support MongoDB 3.0][driver compat].

If your head is spinning, [this official blog post][driver 2.0] gives a good
breakdown of driver version history and the future.

[driver 2.0]: https://www.mongodb.com/blog/post/announcing-ruby-driver-20-rewrite
[driver compat]: https://docs.mongodb.org/ecosystem/drivers/driver-compatibility-reference/#reference-compatibility-mongodb-ruby

Features
--------

- Use as rack middleware or mount as a rack endpoint
- File lookup using a path or object id
- Chunked transfer encoding, keeps memory usage low
- Content-Type header set using 'mime-types' gem
- Last-Modified and Etag headers set automatically for conditional get support
- Cache-Control header support
- High availability when using replication sets

Installation
------------

    $ gem install rack-gridfs

Or in a Bundler project, add to your `Gemfile`:

```ruby
gem 'rack-gridfs', '~> 0.4'
```

Usage
-----

```ruby
require 'rack/gridfs'

use Rack::GridFS, :prefix => 'gridfs',
                  :hostname => 'localhost',
                  :port => 27017,
                  :database => 'test'
```

Options:

- `prefix`: a string used to match against incoming paths and route to through
  the middleware.  Default 'gridfs'.
- `lookup`: whether to look up a file based on `:id` or `:path` (example
  below). Default is `:id`.
- `fs_name`: collection name for the file system, if not using the Mongo driver
  default ("fs").

You must also specify MongoDB database details:

- `hostname`: the hostname/IP where the MongoDB server is running. Default 'localhost'.
- `port`: the port of the MongoDB server. Default 27017.
- `database`: the name of the MongoDB database to connect to.
- `username` and `password`: if you need to authenticate to MongoDB.

Alternatively you can pass in a `Mongo::DB` instance instead:

- `db`: `MongoMapper.database`, or `Mongoid.database` for example.

### Simple Sinatra Example ###

```ruby
require 'rubygems'
require 'sinatra'

require 'rack/gridfs'
use Rack::GridFS, :database => 'test', :prefix => 'gridfs'

get /.*/ do
  "The URL did not match a file in GridFS."
end
```

### Usage with Rails 2 ###

To use `Rack::GridFS` in a Rails application, add it as middleware in
`application.rb` or `config/environments/*` with something like this:

```ruby
config.middleware.insert_after Rack::Runtime, Rack::GridFS,
  :prefix => 'uploads', :database => "my_app_#{Rails.env}"
```

Run `rake middleware` to decide for yourself where to best place it in
the middleware stack for your app using [the Rails convenience methods],
taking into consideration that it can probably be near the top since it simply
returns a "static" file or a 404.

[the Rails convenience methods]: http://guides.rubyonrails.org/rails_on_rack.html#configuring-middleware-stack,

### Usage with Rails 3 ###

To use in Rails 3, you can insert into the middleware stack as above, or mount
the app directly in your routes (recommended). In `config/routes.rb`:

```ruby
mount Rack::GridFS::Endpoint.new(:db => Mongoid.database), :at => "gridfs"
```

This allows for much more straightforward and sensible configuration, if you do
not require other middleware in front of GridFS (Rack-based authorization, for
instance).

### Path (filename) Lookup ###

The `:lookup => :path` option causes files to be looked up from the GridFS
store based on their `filename` field (which can be a full file path) rather than
`ObjectId` (requests still need to match the `prefix` you've set). This allows
you to find files based on essentially arbitrary URLs such as:

    GET '/prefix/media/images/jane_avatar.jpg'

How filenames are set is specific to your application. We'll look at an example
with Carrierwave below.

**NOTE**: The Mongo Ruby driver will try to create an index on the `filename`
field for you automatically, but if you are using filename lookup you'll want to
double-check that it is created appropriately (on slaves only if you have a
master-slave architecture, etc.).

### Carrierwave Example ###

Path lookup works well for usage with [Carrierwave]. As a minimal example with
Mongoid:

```ruby
# config/initializers/carrierwave.rb
CarrierWave.configure do |config|
  config.storage = :grid_fs
  config.grid_fs_connection = Mongoid.database
  config.grid_fs_access_url = "/uploads"
end

# app/uploaders/avatar_uploader.rb
class AvatarUploader < CarrierWave::Uploader::Base
  # (Virtual) path where uploaded files will be stored, appended to the
  # gridfs_access_url by methods used with view helpers
  def store_dir
    "#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end

# app/models/user.rb
class User
  include Mongoid::Document
  mount_uploader :avatar, AvatarUploader
end
```

```eruby
<%# app/views/user/show.html.erb %>
<%= image_tag(@user.avatar.url) if @user.avatar? %>
```

This will result in URL paths like `/uploads/user/avatar/4d250d04a8f41c0a31000006/original_filename.jpg`
being generated for the view helpers, and Carrierwave will store
`user/avatar/4d250d04a8f41c0a31000006/original_filename.jpg` as the
`filename` in GridFS. Thus, you can configure `Rack::GridFS` to serve
these files as such:

```ruby
config.middleware.insert_after Rack::Runtime, Rack::GridFS,
  :prefix => 'uploads', :lookup => :path, :database => "my_app_#{Rails.env}"
```

[Carrierwave]: https://github.com/jnicklas/carrierwave.

Ruby Version and Mongo Driver Compatibility Notes
-------------------------------------------------

If for some reason you need support for ancient versions of the `mongo` driver
prior to v1.2, these were supported in rack-gridfs 0.3.0 and below. 0.4.x
supports `mongo` 1.2+ which made substantial changes to the earlier GridFS
API.

Support for Ruby 1.8 is no longer being tested and will be dropped in the next
version that supports `mongo` 2.x (the driver itself officially drops 1.8
support). It was supported up to rack-gridfs gem release/git tag v0.4.2.

Development and Contributing
----------------------------

Running the project and unit tests in development follows typical procedure for
a Ruby project:

    $ git clone https://github.com/skinandbones/rack-gridfs.git
    $ cd rack-gridfs
    $ bundle install
    $ bundle exec rake test

Note that the test suite expects that you have MongoDB running locally on the
default port and will use a database called `test`.

Copyright
---------

Copyright (c) 2010-2015 Blake Carlson. See LICENSE for details.
