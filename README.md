`rns`, which stands for "Ruby namespaces", is a small library for
using classes and modules as packages of functions in order to support
functional programming in Ruby.  It is inspired by
[Clojure's](http://clojure.org) `ns` macro and namespace system.

[![Build Status](https://secure.travis-ci.org/alandipert/rns.png)](http://travis-ci.org/alandipert/rns)

# Usage

## Importing Methods into Classes

```ruby
require 'rns'

module Arithmetic
  class << self
    def dec(n) n - 1 end
    def inc(n) n + 1 end
  end
end

module Statistics
  def self.avg(arr); arr.reduce(:+).to_f / arr.count end
end

class Main
  include Rns
  
  extend_specified Arithmetic => [:inc]
  include_specified Statistics => [:avg]

  def main
    puts "1+1 is #{self.class.inc 1} and the average of [1,2,3] is #{avg [1,2,3]}"
  end
end

Main.new.main
```

## Importing Methods into Blocks

```ruby
Rns::using(Arithmetic => [:inc], Statistics => [:avg]) do
  puts avg((1..10).to_a.map(&method(:inc)))
end
```

Please see the
[tests](https://github.com/alandipert/rns/tree/master/spec/rns) for more
usage examples.

# Rationale

Ruby has good functional programming support, but the class and module
system doesn't lend itself to organizing and accessing functions.
With `rns` I hope to make it at least slightly easier to build Ruby
programs primarily out of pure functions.

# Thanks

To [Sam Umbach](https://twitter.com/samumbach) for helping me tame the
eigenclass, and to my employer [Relevance](http://thinkrelevance.com)
for indulging me with time to work on free software.