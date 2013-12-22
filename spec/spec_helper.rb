require 'xtr'

K = BigDecimal.new(1_000)
FIVEK = 5 * K
TENK = 10 * K

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'
end
