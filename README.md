`ns`, which stands for "namespace", is a small library for using
classes and modules as packages of functions in order to support
functional programming in Ruby.  It is inspired by
[Clojure's](http://clojure.org) `ns` macro and namespace system.

[![Build Status](https://secure.travis-ci.org/alandipert/ns.png)](http://travis-ci.org/alandipert/ns)

# Usage

## Importing Methods into Classes

```ruby
require 'ns'

module Arithmetic
  def self.dec(n) n - 1; end
  def self.inc(n) n + 1; end
end

module Statistics
  def self.avg(arr); arr.reduce(:+) / arr.count; end
end

class Main < Ns
  def use
    {Math       => [:inc],
     Statistics => [:avg]}
  end

  def main
    puts "1+1 is #{inc 1} and the average of [1,2,3] is #{avg [1,2,3]}"
  end
end

Main.new.main
```

## Importing Methods into Blocks

```ruby
Ns::using [Math, [:inc], Statistics, [:avg]] do
  puts avg((1..10).to_a.map(&method(:inc)))
end
```

Please see the
[tests](https://github.com/alandipert/ns/tree/master/spec/ns) for more
usage examples.

# Rationale

Ruby has good functional programming support, but the class and module
system doesn't lend itself to organizing and accessing functions.
With `ns` I hope to make it at least slightly easier to build Ruby
programs primarily out of pure functions.