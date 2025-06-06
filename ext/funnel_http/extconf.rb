# frozen_string_literal: true

require "mkmf"
require "go_gem/mkmf"

# Makes all symbols private by default to avoid unintended conflict
# with other gems. To explicitly export symbols you can use RUBY_FUNC_EXPORTED
# selectively, or entirely remove this flag.
append_cflags("-fvisibility=hidden")

create_go_makefile("funnel_http/funnel_http")
