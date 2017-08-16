require "bundler/setup"

require "ffi"

# Automatically generate the shared library if it doesn't exist
lib_filename = File.expand_path("../../ext/geohash_int/geohash.#{::FFI::Platform::LIBSUFFIX}", __FILE__)
unless File.exist?(lib_filename)
  Dir.chdir(File.expand_path("../../ext/geohash_int", __FILE__)) do
    unless system("rake")
      fail "couldn't generate shared library"
    end
  end
end

require "geohash_int"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
