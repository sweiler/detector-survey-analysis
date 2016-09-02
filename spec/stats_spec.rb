require './src/stats'

RSpec.describe Stats do

  context 'with some example data' do
    data = [{:x => 3}, {:x => 5}, {:x => 8}]
    uut = Stats.new(data)

    it 'computes the average for a specific column' do
      expect(uut.avg(:x)).to eq(5)
    end

    it 'computes max/min for a column' do
      expect(uut.min(:x)).to eq(3)
      expect(uut.max(:x)).to eq(8)
    end
  end

end