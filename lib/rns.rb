module Rns
  def self.included(base)
    base.extend(ClassMethods)
  end

  def self.add_methods(to, use_spec)
    use_spec.to_a.each do |from, method_names|
      if (method_names.is_a? Hash)
        add_methods(to, method_names.map do |k,v|
                      #TODO: is there a better way to construct modules?
                      {eval(from.to_s + "::" + k.to_s) => v}
                    end.reduce({}){|l,r| l.merge(r)})
      else
        method_names.each do |name|
          if (name.is_a? Hash)
            add_methods(to, {from => name})
          else
            to.send(:define_method, name) do |*args|
              from.method(name).call(*args)
            end
          end
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
