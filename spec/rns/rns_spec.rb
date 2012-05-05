require File.join(File.dirname(__FILE__), *%w[.. spec_helper.rb])
require 'rns'

module Arithmetic
  class << self
    def dec(n) n - one end
    def inc(n) n + one end
  private
    def one() 1 end
  end
end

module Statistics
  def self.avg(arr); arr.reduce(:+).to_f / arr.count end
end

class Thing < Rns
  def use
    {Arithmetic => [:inc],
     Statistics => [:avg]}
  end

  def inced_one
    inc 1
  end

  def average
    avg [11, 42, 7]
  end
end

describe Rns do
  context 'adding methods to classes' do
    it "works" do
      Thing.new.average.should == 20
    end

    it "works with private module methods" do
      Thing.new.inced_one.should == 2
    end
  end

  context 'adding methods to blocks' do
    it "works" do
      Rns::using(Arithmetic => [:inc], Statistics => [:avg]) do
        avg((1..10).to_a.map(&method(:inc))).should == 6.5
      end
    end

    it "works using an array" do
      Rns::using [Arithmetic, [:inc], Statistics, [:avg]] do
        avg((1..10).to_a.map(&method(:inc))).should == 6.5
      end
    end
  end
end
