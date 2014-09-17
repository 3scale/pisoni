module ThreeScale
  module Core
    module APIClient
      module Operations
        def self.included(base)
          base.extend ClassMethods
          base.prepend Initializer
        end

        private

        attr_accessor :persisted

        def api_save(api_options = {})
          if persisted
            ret = self.class.api_do_put attributes, api_options
          else
            ret = self.class.api_do_post attributes, api_options
            self.persisted = ret[:ok]
          end
          if ret[:ok]
            update_attributes(ret[:attributes])
            self.dirty = false
            true
          else
            false
          end
        end

        def api_delete(api_options = {})
          ok = self.class.api_delete attributes, api_options
          self.persisted = false if ok
          ok
        end

        module Initializer
          def initialize(*args)
            self.persisted = false
            super
          end
        end

        module ClassMethods
          # CRUD methods

          def api_create(attributes, api_options = {})
            api_create_object :api_do_post, attributes, api_options
          end
          alias_method :api_save, :api_create

          def api_read(attributes, api_options = {})
            api_create_object :api_do_get, attributes, api_options
          end
          alias_method :api_load, :api_read

          def api_update(attributes, api_options = {})
            api_create_object :api_do_put, attributes, api_options
          end

          def api_delete(attributes, api_options = {})
            api_do_delete(attributes, api_options)[:ok]
          end

          # Helpers

          def api_do_get(attributes, api_options = {})
            api :get, attributes, api_options do |response, _|
              :raise unless response.status == 404
            end
          end

          def api_do_put(attributes, api_options = {})
            api :put, attributes, api_options
          end

          def api_do_post(attributes, api_options = {})
            api :post, attributes, api_options
          end

          def api_do_delete(attributes, api_options = {})
            api :delete, attributes, api_options do |response, _|
              :raise unless response.status == 404
            end
          end

          def api_create_object(method, attributes, api_options = {})
            ret = send method, attributes, api_options.merge(build: true)
            ret[:object].send :persisted=, true if ret[:object]
            ret[:object]
          end

          def api_http(method, uri, attributes)
            # GET, DELETE and HEAD are treated differently by Faraday. We need
            # to set the body in there.
            if method == :get or method == :delete
              Core.faraday.send method, uri do |req|
                req.body = attributes.to_json
              end
            else
              Core.faraday.send method, uri, attributes.to_json
            end
          end
          private :api_http

          def api_parse_json(text)
            parse_json(text)
          rescue JSON::ParserError
            raise "JSON Parser Error"
          end
          private :api_parse_json

          # api method - talk with the remote HTTP service
          #
          # method - HTTP method to use
          # attributes - HTTP request body parameters
          # options:
          #   :uri => string - sets the uri for this particular request
          #   :on_error => exception - either use nil to not raise, or :raise (default, use default_http_error_exception) or an exception class
          #   :build => boolean|class - call new with response's JSON if response is ok, defaults to false
          # block (optional) - receives two params: http status code and attributes
          #   this block if present handles error responses, invalidates :on_error option,
          #   you should return an array of [exception_to_raise|nil, built_object (if any) or nil]
          #
          # returns:
          #   a hash consisting of:
          #     :response - http response
          #     :ok - whether the response code was ok when related to the http method
          #     :object - nil or the object created if applicable
          #     :attributes - JSON parsed attributes of the response's body

          def api(method, attributes, options = {})
            prefix = default_prefix
            attributes = { prefix => attributes }
            uri = options.fetch(:uri, default_uri)
            response = api_http method, uri, attributes

            ok = status_ok? method, response.status
            ret = { response: response, ok: ok }

            attributes = api_parse_json(response.body)
            attributes = attributes[prefix]
            ret[:attributes] = attributes

            if ok
              ret[:object] = if attributes and options[:build]
                               ((options[:build] == true) ? self : options[:build]).public_send(:new, attributes)
                             else
                               nil
                             end
            else
              # something went wrong. let's either let the user fix it, and ask him to provide us
              # with directions returned from block or just use :on_error
              except, ret[:object] = block_given? ? yield(response, attributes) : [options.fetch(:on_error, :raise), nil]
              if except
                except = default_http_error_exception if except == :raise
                raise except, "Error #{method.upcase}'ing #{uri}, attributes: #{attributes.inspect}, " \
              "response code: #{response.status}, response body: #{response.body.inspect}"
              end
            end

            ret
          end

        end
      end
    end
  end
end
