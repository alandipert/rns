module Rns
  def self.included(base)
    base.extend(ClassMethods)
  end

  def self.add_methods(to, use_spec)
    use_spec.to_a.each do |from, method_names|
      method_names.each do |name|
        to.send(:define_method, name) do |*args|
          from.method(name).call(*args)
        end
      end
    end
  end

  module ClassMethods
    def include_specified(use_spec)
      Rns::add_methods(self, use_spec)
    end

    def extend_specified(use_spec)
      singleton_class = class << self; self; end
      Rns::add_methods(singleton_class, use_spec)
    end
  end

  def self.using(use_spec, &blk)
    blk[Object.new.tap{|o| Rns::add_methods(o.class, use_spec)}]
  end
end
