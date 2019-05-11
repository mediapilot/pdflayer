# frozen_string_literal: true

require 'cgi'
require 'digest'
require 'httparty'
require 'hashable'
require 'pdflayer/missing_argument_exception'
require 'pdflayer/version'

module Pdflayer
  # Client
  class Client
    include HTTParty

    base_uri 'api.pdflayer.com/api'

    def initialize(access_key = nil, secret_keyword = nil)
      raise Pdflayer::MissingArgumentException, 'access_key' if access_key.nil?
      if secret_keyword.nil?
        raise Pdflayer::MissingArgumentException, 'secret_keyword'
      end

      @access_key = access_key
      @secret_keyword = secret_keyword
    end

    def convert(document_url = nil, options = ConvertOptions.new)
      if document_url.nil?
        raise Pdflayer::MissingArgumentException, 'document_url'
      end

      md5 = Digest::MD5.new
      md5.update document_url + @secret_keyword
      secret_key = md5.hexdigest

      query = options.dup
      query.access_key = @access_key
      query.secret_key = secret_key
      query.document_url = CGI.escape(document_url)

      req = ConvertRequest.new(query)
      req_dto = req.to_dh

      begin
        res = self.class.get('/convert', req_dto)
        res.inspect
        case res.headers['Content-Type']
        when 'application/pdf'
          if options.export.nil?
            res.parsed_response
          else
            begin
              File.open(options.export, 'a+') do |file|
                file.write(res.body)
                {
                  success: true,
                  info: 'The PDF file has been saved as a file.',
                  file_name: options.export
                }
              end
            rescue StandardError => e
              {
                success: false,
                info: e.inspect
              }
            end
          end
        when 'application/json'
          res.body
        else
          {
            success: false,
            info: res.inspect
          }
        end
      rescue StandardError => e
        puts e.inspect
      end
    end
  end

  # Request
  class ConvertRequest
    include Hashable

    attr_accessor :query

    def initialize(query = {})
      self.query = query
    end
  end

  # Options
  class ConvertOptions
    include Hashable

    attr_accessor :access_key
    attr_accessor :secret_key
    attr_accessor :document_url
    attr_accessor :document_html
    attr_accessor :document_name
    attr_accessor :export
    attr_accessor :document_unit
    attr_accessor :user_agent
    attr_accessor :text_encoding
    attr_accessor :ttl
    attr_accessor :force
    attr_accessor :inline
    attr_accessor :auth_user
    attr_accessor :auth_password
    attr_accessor :encryption
    attr_accessor :no_images
    attr_accessor :no_hyperlinks
    attr_accessor :accept_lang
    attr_accessor :no_backgrounds
    attr_accessor :no_javascript
    attr_accessor :use_print_media
    attr_accessor :grayscale
    attr_accessor :low_quality
    attr_accessor :forms
    attr_accessor :no_print
    attr_accessor :no_modify
    attr_accessor :no_copy
    attr_accessor :page_size
    attr_accessor :page_width
    attr_accessor :page_height
    attr_accessor :orientation
    attr_accessor :header_text
    attr_accessor :header_align
    attr_accessor :header_url
    attr_accessor :header_html
    attr_accessor :header_spacing
    attr_accessor :footer_text
    attr_accessor :footer_align
    attr_accessor :footer_url
    attr_accessor :footer_html
    attr_accessor :footer_spacing
    attr_accessor :css_url
    attr_accessor :delay
    attr_accessor :dpi
    attr_accessor :zoom
    attr_accessor :page_numbering_offset
    attr_accessor :watermark_url
    attr_accessor :watermark_opacity
    attr_accessor :watermark_offset_x
    attr_accessor :watermark_offset_y
    attr_accessor :watermark_in_background
    attr_accessor :title
    attr_accessor :subject
    attr_accessor :creator
    attr_accessor :author
    attr_accessor :test

    def initialize
      @query = nil
    end
  end
end
