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
          include ThreeScale::Core::Logger

          # CRUD methods

          def api_create(attributes, api_options = {}, &blk)
            api_create_object :api_do_post, attributes, api_options, &blk
          end
          alias_method :api_save, :api_create

          def api_read(attributes, api_options = {}, &blk)
            api_create_object :api_do_get, attributes, api_options, &blk
          end
          alias_method :api_load, :api_read

          def api_update(attributes, api_options = {}, &blk)
            api_create_object :api_do_put, attributes, api_options, &blk
          end

          def api_delete(attributes, api_options = {}, &blk)
            api_do_delete(attributes, api_options, &blk)[:ok]
          end

          # Helpers

          def api_do_get(attributes, api_options = {}, &blk)
            blk = filter_404 if blk.nil?
            api :get, attributes, api_options, &blk
          end

          def api_do_put(attributes, api_options = {}, &blk)
            api :put, attributes, api_options, &blk
          end

          def api_do_post(attributes, api_options = {}, &blk)
            api :post, attributes, api_options, &blk
          end

          def api_do_delete(attributes, api_options = {}, &blk)
            blk = filter_404 if blk.nil?
            api :delete, attributes, api_options, &blk
          end

          def api_create_object(method, attributes, api_options = {}, &blk)
            ret = send method, attributes, api_options.merge(build: true), &blk
            ret[:object].send :persisted=, true if ret[:object]
            ret[:object]
          end

          def filter_404
            @filter_404_proc ||= proc do |response, _|
              response.status != 404
            end
          end
          private :filter_404

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
          rescue Faraday::Error::ClientError, SystemCallError => e
            raise ConnectionError, e
          end
          private :api_http

          def api_parse_json(response)
            raise JSONError, "non-acceptable content-type #{response.headers['content-type']}" unless response.headers['content-type'].include? 'json'
            parse_json(response.body)
          rescue JSON::ParserError => e
            # you can obtain the error message with
            # rescue JSONError => e
            #   puts(e.cause ? e.cause.message : e.message)
            #
            # e.message will always return a trimmed (bounded) message, while
            # e.cause.message, when a cause is present, may return a long
            # message including the whole response body.
            raise JSONError, e
          end
          private :api_parse_json

          # Our current HTTP client (Faraday wrapper) does not expose HTTP
          # version, which would be convenient for determining whether we have
          # a keep-alive connection. For that we would probably need to write a
          # Faraday middleware.
          #
          # Anyway, in HTTP/1.0 we are not guaranteed to have a Connection:
          # response field, so it does not always use Connection: close (they
          # are closed by default). HTTP/1.1 OTOH does keep-alive by default, so
          # it will close the connection when actually sending a Connection:
          # close. So:
          # HTTP/1.1: KA if no Connection field or if present and not 'close'
          # HTTP/1.0: no KA unless Connection: keep-alive.
          # XXX UNDEFINED: no Connection header, depends on HTTP version:
          # 1.1: keep-alive
          # 1.0: close
          def keep_alive_response?(response)
            response.headers['connection'] != 'close'
          end
          private :keep_alive_response?

          # api method - talk with the remote HTTP service
          #
          # method - HTTP method to use
          # attributes - HTTP request body parameters
          # options:
          #   :uri => string - sets the uri for this particular request
          #   :raise => boolean - raise APIError on error, defaults to true
          #   :build => boolean - create a new object with response's JSON if response is ok, defaults to false
          # block (optional) - receives two params: http status code and attributes
          #   this block if present handles error responses, invalidates :raise option,
          #   you should return an array of [raise (boolean), built_object (if any) or nil]
          #
          # returns:
          #   a hash consisting of:
          #     :response - http response
          #     :ok - whether the response code was ok when related to the http method
          #     :object - nil or the object created if applicable
          #     :attributes - JSON parsed attributes of the response's body

          def api(method, attributes, options = {})
            prefix = default_prefix
            attributes = { prefix => attributes } unless attributes.empty?
            uri = options.fetch(:uri, default_uri)

            logger.debug do
              "==> #{method.upcase} #{uri} [#{attributes}]"
            end

            before = Time.now
            response = api_http method, uri, attributes
            after = Time.now

            ok = status_ok? method, response.status
            ret = { response: response, ok: ok }

            attributes = if response.headers['content-type'].index 'json'
              api_parse_json(response.body)
            else
              {}
            end

            logger.debug do
              "<#{keep_alive_response?(response) ? '=' : '/'}= #{response.status} #{method.upcase} #{uri} [#{attributes}] (#{after - before})"
            end

            if ok
              attributes = attributes[prefix]

              ret[:object] = if attributes and options[:build]
                               new attributes
                             else
                               nil
                             end
            else
              # something went wrong. let's either let the user fix it, and ask him to provide us
              # with directions returned from block or just use :raise
              do_raise, ret[:object] = block_given? ? yield(response, attributes) : [options.fetch(:raise, true), nil]
              raise APIError.new(method, uri, response, attributes) if do_raise
            end

            ret[:attributes] = attributes
            ret
          end

        end
      end
    end
  end
end
