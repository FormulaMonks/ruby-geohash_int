# GeohashInt

Wraps [geohash-int](https://github.com/yinqiwen/geohash-int)
(A fast C99 geohash library which only provides int64 as hash result) for Ruby
using [FFI](https://github.com/ffi/ffi) (this means it is compatible with all
implementations of Ruby that support FFI, including MRI, JRuby, and Rubinius).

This can be used to build an efficient spatial data index, as explained
[here](https://github.com/yinqiwen/ardb/wiki/Spatial-Index).

## Explanation

This library turns a cooridnate (a latitude and a longitude) into a 64 bits
integer. To understand what this integer means we need to learn how the Geohash
algorithm works. Don't worry, it's super simple.

Suppose we want to encode the coordinate with latitude 42.6 and longitude -5.6.

Let's focus on the value 42.6. Latitudes fall in the range -90..90. We split that
range in half (-90...0, 0..90) and we check in which half the value falls. We'll
use 0 if it falls in the lower interval and 1 if it falls in the higher interval.
In this case it's 1. We then do the same but with this new interval (0..90): split
it (0...45, 45..90) and see in which half it falls. In this case it's 0.

If we stop here, we get the sequence "10".

We then do the same for the longitude, starting with the range -180..180.
If we repeat the process two times like before, we get the sequence "01".

We then **interleave** the longitude and latitude sequences and we get "0110".
Interpreting that as a 64 bits integer we get the value 6, and this is the encoded value.

To decode this value 6 we do the reverse process: de-interleave the sequence and
reconstruct the original numbers. But, in the process we'll lose precision:
by splitting the initial ranges -90..90 and -180..180 in halves, but only a couple
of times, we'll know that the original coordinate is anywhere in the range 0..45 for
latitude and -90..0 for longitude, with its center latitude 22.5 and longitude -45.0
as an estimation.

We can increase the number of steps we succesively split the original ranges to
increase the precision. For example, if we do it 10 times we get the sequence
"01101111111100000100", which is the number 458500. When decode it back, we get
(42.626953125, -5.44921875) as a result, which is closer to the original value.

The maximum number of steps we can do this for a 64 bits integer is 32,
because we use 32 bits for the latitude and 32 bits for the longitude.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'geohash_int'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install geohash_int

## Usage

To encode and decode values:

```ruby
require "geohash_int"

latitude  = 12.34
longitude = 56.78
precision = 10

value = GeohashInt.encode(latitude, longitude, precision)

value # => 825366

result = GeohashInt.decode(value, precision)

# Geohash is lossy
result.latitude  # => 12.392578125
result.longitude # => 56.77734375

# Geohash actually encodes a value to a bounding box:
# the above latitude and longitude are just its center.
result.min_latitude   # => 12.3046875
result.max_latitude   # => 12.48046875
result.min_longitude  # => 56.6015625
result.max_longitude  # => 56.953125
```

From an encoded value you get a neighbour or all neighbors:

```ruby
require "geohash_int"

latitude  = 12.34
longitude = 56.78
precision = 10

value = GeohashInt.encode(latitude, longitude, precision)

neighbor = GeohashInt.get_neighbor(value, GeohashInt::NORTH, precision)

neighbor # => 825367

neighbors = GeohashInt.get_neighbors(value, precision)

neighbors = # => #<struct GeohashInt::Neighbors
            #       north=825367, east=825372, west=825364, south=825363,
            #       south_west=825361, south_east=825369,
            #       north_west=825365, north_east=825373>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/citrusbyte/ruby-geohash_int.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## About Citrusbyte

![Citrusbyte](http://i.imgur.com/W6eISI3.png)

GeohashInt is lovingly maintained and funded by Citrusbyte.
Citrusbyte specializes in solving difficult computer science problems for startups and the enterprise.

At Citrusbyte we believe in and support open source software.
* Check out more of our open source software at Citrusbyte Labs.
* Learn more about [our work](https://citrusbyte.com/portfolio).
* [Hire us](https://citrusbyte.com/contact) to work on your project.
* [Want to join the team?](http://careers.citrusbyte.com)

*Citrusbyte and the Citrusbyte logo are trademarks or registered trademarks of Citrusbyte, LLC.*
