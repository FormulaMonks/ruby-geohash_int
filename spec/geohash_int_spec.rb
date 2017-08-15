require "spec_helper"

RSpec.describe GeohashInt do
  it "has a version number" do
    expect(GeohashInt::VERSION).not_to be nil
  end

  describe "encode" do
    it "with precision 10" do
      encoded = GeohashInt.encode(12.34, 56.78, 10)
      expect(encoded).to eq(825366)
    end

    it "with precision 32" do
      encoded = GeohashInt.encode(12.34, 56.78, 32)
      expect(encoded).to eq(14520001368503071193)
    end

    it "raises when lat out of bounds" do
      expect {
        GeohashInt.encode(90.1, 56.78, 10)
      }.to raise_error(ArgumentError)
    end

    it "raises when lng out of bounds" do
      expect {
        GeohashInt.encode(12.34, 180.1, 10)
      }.to raise_error(ArgumentError)
    end

    it "raises when precision out of bounds" do
      expect {
        GeohashInt.encode(12.34, 180.1, 33)
      }.to raise_error(ArgumentError)
    end

    it "raises when precision is zero" do
      expect {
        GeohashInt.encode(12.34, 180.1, 0)
      }.to raise_error(ArgumentError)
    end

    it "works when lat/lng are integers" do
      encoded = GeohashInt.encode(10, 20, 10)
      expect(encoded).to eq(GeohashInt.encode(10.0, 20.0, 10))
    end
  end

  describe "decode" do
    it "with default precision 10" do
      result = GeohashInt.decode(825366, 10)
      expect(result.latitude).to      eq(12.392578125)
      expect(result.longitude).to     eq(56.77734375)
      expect(result.min_latitude).to  eq(12.3046875)
      expect(result.max_latitude).to  eq(12.48046875)
      expect(result.min_longitude).to eq(56.6015625)
      expect(result.max_longitude).to eq(56.953125)
    end

    it "with precision 32" do
      result = GeohashInt.decode(14520001368503071193, 32)
      expect(result.latitude).to      eq(12.340000018011779)
      expect(result.longitude).to     eq(56.78000001702458)
      expect(result.min_latitude).to  eq(12.33999999705702)
      expect(result.max_latitude).to  eq(12.340000038966537)
      expect(result.min_longitude).to eq(56.77999997511506)
      expect(result.max_longitude).to eq(56.78000005893409)
    end
  end

  describe "get_neighbor" do
    it "gets north neighbor" do
      result = GeohashInt.get_neighbor(825366, GeohashInt::NORTH, 10)
      expect(result).to eq(825367)
    end

    it "gets south neighbor" do
      result = GeohashInt.get_neighbor(825366, GeohashInt::SOUTH, 10)
      expect(result).to eq(825363)
    end

    it "gets invalid neighbor" do
      expect {
        GeohashInt.get_neighbor(825366, 123, 10)
      }.to raise_error(ArgumentError)
    end
  end

  describe "get_neighbors" do
    it "gets neighbors" do
      result = GeohashInt.get_neighbors(825366, 10)
      p result
      expect(result.north).to       eq(825367)
      expect(result.east).to        eq(825372)
      expect(result.west).to        eq(825364)
      expect(result.south).to       eq(825363)
      expect(result.south_west).to  eq(825361)
      expect(result.south_east).to  eq(825369)
      expect(result.north_west).to  eq(825365)
      expect(result.north_east).to  eq(825373)
    end
  end
end
