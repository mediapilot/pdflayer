# frozen_string_literal: true
require 'securerandom'
require 'test_helper'

class PdflayerTest < Minitest::Test
  def test_has_a_version_number
    refute_nil ::Pdflayer::VERSION
  end

  def test_simple_convert
    client = Pdflayer::Client.new(ENV['ACCESS_KEY'], ENV['SECRET_KEYWORD'])
    document_url = 'https://en.wikipedia.org/wiki/Special:Random'
    options = Pdflayer::ConvertOptions.new
    options.test = true

    response = client.convert(document_url, options)
    refute_nil response
  end

  def test_export_convert
    client = Pdflayer::Client.new(ENV['ACCESS_KEY'], ENV['SECRET_KEYWORD'])
    document_url = 'https://en.wikipedia.org/wiki/Special:Random'
    options = Pdflayer::ConvertOptions.new
    options.test = true
    options.export = File.join('tmp', SecureRandom.uuid + '.pdf')

    response = client.convert(document_url, options)

    assert response[:success]
    assert File.exist?(options.export)

    File.unlink options.export
  end

  def test_invalid_url
    client = Pdflayer::Client.new(ENV['ACCESS_KEY'], ENV['SECRET_KEYWORD'])
    document_url = 'not a url'
    options = Pdflayer::ConvertOptions.new
    options.test = true
    options.export = File.join('tmp', SecureRandom.uuid + '.pdf')

    response = client.convert(document_url, options)

    refute response[:success]
    refute File.exist?(options.export)
  end
end
