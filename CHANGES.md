CHANGE LOG
----------

### 0.4.3 / November 4, 2015 ###

Same as v0.4.2, but v0.4.2 gem yanked because of faulty gemspec file (grumble).

### 0.4.2 / November 3, 2015 ###

[full commit log](https://github.com/skinandbones/rack-gridfs/compare/v0.4.1...v0.4.2)

It's been awhile, eh? No compatibility with new `mongo` 2.x releases yet,
we'll look to bring that in an 0.5 or 1.0 release. This is primarily a bug fix
release for users affected by incompatible bson 2.x being allowed by some
historical `mongo` driver versions.

#### Features ####

- Eliminate need for `:require` option in Gemfile ([Konstantin Shabanov])
- Add `fs_name` option as supported by the Mongo driver ([max-power])

#### Bug Fixes ####

- Prevent bson 2.x being allowed to resolve dependency constraints, where some
  historical versions of the `mongo` gem used a ">= 1.x" constraint spec.
  See [#14](https://github.com/skinandbones/rack-gridfs/issues/14) for instance.


### 0.4.1 / June 26, 2011 ###

[full commit log](https://github.com/skinandbones/rack-gridfs/compare/v0.4.0...v0.4.1)

#### Bug Fixes ####

- URL-decode before filename lookup so that non-ASCII filenames are handled
  correctly ([Konstantin Shabanov])


### 0.4.0 / May 12, 2011 ###

Major refactoring and loads of new features! Thanks to [Ben Marini] for his
substantial contributions to this release.

[full commit log](https://github.com/skinandbones/rack-gridfs/compare/v0.2.0...v0.4.0)

#### Features ####

- Allow configuration of MongoDB authentication ([Steve Sloan])
- Allow option to look up objects by GridFS filename instead of `ObjectId`
  ([SHIBATA Hiroshi])
- Return iterable GridIO object instead of file contents, so Rack can stream in
  chunks ([Ches Martin])
- `Rack::GridFS::Endpoint`: support for mounting as a Rack endpoint in addition
  to middleware ([Ben Marini])
- Cache headers: set `Last-Modified` and `Etag` so that `Rack::ConditionalGet`
  sends 304s. `expires` option to set `Cache-Control` ([Alexander Gräfe] & [Ben
  Marini])
- `mime-types` dependency so GridFS lib can determine content types ([Ben
  Marini])
- You can now pass a `Mongo::DB` instance instead of discrete database
  configuration parameters. Connections are retried so we take advantage of a
  `ReplSetConnection` in high-availability architectures ([Ben Marini])

#### Bug Fixes ####

- `BSON::ObjectID` renamed to `ObjectId`, and other changes supporting
  current versions of Mongo libraries

[Alexander Gräfe]: https://github.com/rickenharp
[SHIBATA Hiroshi]: https://github.com/hsbt
[Ben Marini]: https://github.com/bmarini
[Ches Martin]: https://github.com/ches
[max-power]: https://github.com/max-power
[Konstantin Shabanov]: https://github.com/etehtsea
[Steve Sloan]: https://github.com/CodeMonkeySteve
