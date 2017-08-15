require "geohash_int/version"
require "geohash_int/ffi"

# The GeohashInt provides methods to encode and decode geographic
# coordinates using the geohash algorithm, but instead of returning
# a string, an integer (Fixnum) is returned.
#
# See also:
#  - https://en.wikipedia.org/wiki/Geohash
#  - https://github.com/yinqiwen/geohash-int
#  - https://github.com/yinqiwen/ardb/wiki/Spatial-Index
module GeohashInt
  module_function

  LAT_RANGE = GeohashInt::FFI::Range.new.tap do |range|
    range[:min] = -90.0
    range[:max] =  90.0
  end # :nodoc:

  LNG_RANGE = GeohashInt::FFI::Range.new.tap do |range|
    range[:min] = -180.0
    range[:max] =  180.0
  end # :nodoc:

  NORTH       = 0
  EAST        = 1
  WEST        = 2
  SOUTH       = 3
  SOUTH_WEST  = 4
  SOUTH_EAST  = 5
  NORTH_WEST  = 6
  NORTH_EAST  = 7

  # The result of decoding an integer that represents an encoded coordinate.
  #
  # In Geohash, encoding a coordinate results in a value that, when decoded,
  # returns a bounding box. The `latitude` and `longitude` values are taken
  # as the middle of the bounding box.
  class BoundingBox < Struct.new(
    :latitude, :longitude,
    :min_latitude, :max_latitude,
    :min_longitude, :max_longitude,
  ); end

  # Neighbors of an encoded coordinate.
  class Neighbors < Struct.new(
    :north, :east, :west, :south,
    :south_west, :south_east, :north_west, :north_east,
  ); end

  # Encodes a coordinate with a given precision (1..32).
  #
  # Returns the encoded value as an integer (Fixnum). To correctly decode this
  # value back into a coordinate you must pass the same precision to #decode.
  def encode(latitude, longitude, precision)
    bits = GeohashInt::FFI::Bits.new

    result = GeohashInt::FFI.geohash_encode(LAT_RANGE, LNG_RANGE,
                                            latitude, longitude,
                                            precision, bits.pointer)
    if result == 0
      bits[:bits]
    else
      raise ArgumentError.new("Incorrect value for latitude (#{latitude}), " \
                              "longitude (#{longitude}) or precision (#{precision})")
    end
  end

  # Decodes a previously encoded value. The given precision must be the same
  # as the one given in #encode to generate *value*.
  #
  # Returns a BoundingBox where the original  coordinate falls
  # (the Geohash algorithm is lossy), where `latitude` and `longitude` of that
  # bounding box are its center.
  def decode(value, precision)
    bits = new_bits(value, precision)
    area = GeohashInt::FFI::Area.new

    # This will always return 0 because the only condition for it
    # returning something else is when area is NULL, but we are
    # not passing NULL.
    GeohashInt::FFI.geohash_decode(LAT_RANGE, LNG_RANGE, bits, area.pointer)

    lat_range = area[:latitude]
    lng_range = area[:longitude]

    lat = (lat_range[:max] + lat_range[:min]) / 2
    lng = (lng_range[:max] + lng_range[:min]) / 2

    BoundingBox.new(
      lat, lng,
      lat_range[:min], lat_range[:max],
      lng_range[:min], lng_range[:max],
    )
  end

  # Gets a neighbor of an encoded value.
  #
  # - *direction* must be one of this module's constants ( NORTH, EAST, etc. ).
  # - *precision* must be the same as the one used in #encode to generate *value*.
  def get_neighbor(value, direction, precision)
    bits     = new_bits(value, precision)
    neighbor = GeohashInt::FFI::Bits.new

    result = GeohashInt::FFI.geohash_get_neighbor(bits, direction, neighbor.pointer)
    if result == 0
      neighbor[:bits]
    else
      raise ArgumentError.new("Incorrect value for direction (#{direction})")
    end
  end

  # Gets all neighbors of an encoded value.
  #
  # - *precision* must be the same as the one used in `encode` to generate *value*.
  #
  # Returns a Neighbors instance.
  def get_neighbors(value, precision)
    bits      = new_bits(value, precision)
    neighbors = GeohashInt::FFI::Neighbors.new

    # This function never fails
    GeohashInt::FFI.geohash_get_neighbors(bits, neighbors.pointer)

    Neighbors.new(
      neighbors[:north     ][:bits],
      neighbors[:east      ][:bits],
      neighbors[:west      ][:bits],
      neighbors[:south     ][:bits],
      neighbors[:south_west][:bits],
      neighbors[:south_east][:bits],
      neighbors[:north_west][:bits],
      neighbors[:north_east][:bits],
    )
  end

  private def new_bits(value, precision)
    GeohashInt::FFI::Bits.new.tap do |bits|
      bits[:bits] = value
      bits[:step] = precision
    end
  end
end
