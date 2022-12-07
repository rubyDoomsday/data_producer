# frozen_string_literal: true

module RequestHelper
  # Builds basic headers for API request
  # @return [Hash] Header hash
  def basic_auth_headers
    {
      "Content-type" => "application/json",
      "Accept" => "application/json",
    }
  end

  # Parses a response body to a ruby hash
  # @return [Hash] The JSON hash
  def json
    JSON.parse(response.body, symbolize_names: true)
  end

  # compares Hash keys from an expectation to the json response
  # @param expectations [Hash|Object] Must respond to .to_json
  # @param (given) [JSON] The given response object. default #json
  # @return [Boolean]
  def expect_response_to_match(hash = {}, given = json)
    expectations = JSON.parse(hash.to_json).deep_symbolize_keys.keys
    expect(expectations).to include(*given.keys), "expected response to match but got: #{given}"
  end

  # compares Array of Hashes to the json response array
  # @param expectations [Array]
  # @return [Boolean]
  def expect_response_to_match_array(array = [])
    array.each_with_index { |hash, i| expect_response_to_match(hash, json[i]) }
  end

  private

  def error_response
    {errors: []}
  end
end
