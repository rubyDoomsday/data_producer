# frozen_string_literal: true

module LoremIpsum
  def self.generate(length = 500)
    letters = [("a".."z"), ("A".."Z")].map(&:to_a).flatten
    (0...length).map do
      letters[rand(letters.length)]
    end.join[0...length]
  end
end
