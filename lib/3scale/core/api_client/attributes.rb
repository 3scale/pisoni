module ThreeScale
  module Core
    module APIClient
      module Attributes
        def self.included(base)
          base.extend ClassMethods
        end

        def attributes
          attrs = {}
          self.class.attributes.each do |attr|
            attrs[attr] = send(attr)
          end
          attrs
        end
        alias_method :to_hash, :attributes

        def update_attributes(attributes)
          self.class.attributes.each do |attr|
            send("#{attr}=", attributes[attr])
          end
          self
        end

        def dirty?
          @dirty
        end

        private

        def dirty=(val)
          @dirty = val
        end

        module ClassMethods
          TIME_ATTRIBUTES = [:timestamp]

          def attributes(*attributes)
            return @attributes if attributes.empty?
            attributes.each do |attr|
              attr_reader attr
              define_method "#{attr}=" do |val|
                self.dirty = true
                val = Time.parse(val) if TIME_ATTRIBUTES.include? attr.to_sym
                instance_variable_set "@#{attr}", val
              end
            end
            @attributes = attributes
          end
        end
      end
    end
  end
end
