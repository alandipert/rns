class Ns
  def self.to_pairs(use_spec)
    case use_spec
    when Array then use_spec.each_slice(2).reduce([]){|xs,y| xs + [y]}
    when Hash then use_spec.to_a
    else
      raise "Don't know how to make module/class:methods pairs out of #{use_spec.class}"
    end
  end
  
  def self.populate(obj, use_spec)
    obj.tap do |o|
      to_pairs(use_spec).each do |pkg, method_names|
        method_names.each do |name|
          o.class.send(:define_method, name) do |*args|
            pkg.method(name).call(*args)
          end
        end
      end
    end
  end

  def initialize
    Ns::populate(self, use)
  end

  def self.using(use_spec, &blk)
    blk[Ns::populate(Object.new, use_spec)]
  end
end
