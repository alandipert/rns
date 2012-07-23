`rns`, which stands for "Ruby namespaces", is a small library for
using classes and modules as packages of functions in order to support
functional programming in Ruby.  It is inspired by
[Clojure's](http://clojure.org) `ns` macro and namespace system.

[![Build Status](https://secure.travis-ci.org/alandipert/rns.png)](http://travis-ci.org/alandipert/rns)

# Usage

## Importing Methods into Classes

```ruby
require 'rns'

Arithmetic = Rns do
  def dec(n) n - 1 end
  def inc(n) n + 1 end
end

Statistics = Rns do
  def avg(arr) arr.reduce(:+).to_f / arr.count end
end

class Main
  Funcs = Rns(Statistics, Arithmetic => [:inc]) do
    def incremented_avg(nums)
      avg nums.map(&method(:inc))
    end
  end

  def main
    nums = [1, 2, 3]
    puts "The average of #{nums.inspect} incremented is: #{Funcs.incremented_avg nums}"
  end
end

Main.new.main
```

Please see the
[tests](https://github.com/alandipert/rns/tree/master/test) for more
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