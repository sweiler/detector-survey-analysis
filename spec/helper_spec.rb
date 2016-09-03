require './src/helper'

RSpec.configure do |c|
  c.include Helper
end

RSpec.describe Helper do
  it 'formats durations' do
    seconds = 135
    expect(format_duration(seconds)).to eq('2:15 min')
  end
end