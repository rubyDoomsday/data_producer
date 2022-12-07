# frozen_string_literal: true

# ActiveRecord Initializer hooks into ActiveSupport to automatically include
# the DSL exposed by the DataProducer Engine. This design takes cues from the
# Devise engine for inspiration.
#
# @author rebecca.chapin@fundthatflip.com
#
# @see: https://github.com/heartcombo/devise/blob/5d5636f03ac19e8188d99c044d4b5e90124313af/lib/devise/orm/active_record.rb
ActiveSupport.on_load(:active_record) do
  extend DataProducer::Models
end
