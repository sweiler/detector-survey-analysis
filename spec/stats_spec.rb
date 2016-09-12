require './src/stats'

RSpec.describe Stats do

  context 'with some example data' do
    data = [
        {:x => 3, :y => 'Y'}, {:x => 5, :y => 'N'}, {:x => 8, :y => 'Y'},
    ]
    uut = Stats.new(data)

    it 'computes the average for a specific column' do
      expect(uut.avg(:x)).to eq(5)
    end

    it 'computes max/min for a column' do
      expect(uut.min(:x)).to eq(3)
      expect(uut.max(:x)).to eq(8)
    end

    it 'computes a Y/N ratio' do
      expect(uut.yes_no_ratio(:y)).to eq(2.0/3.0)
    end

    it 'doesn\'t fail when dividing by zero' do
      uut2 = Stats.new([])
      expect(uut2.avg(:x)).to eq(0)
      expect(uut2.min(:x)).to eq(0)
      expect(uut2.max(:x)).to eq(0)
      expect(uut2.yes_no_ratio(:y)).to eq(0)
    end
  end

  context 'with grouped example data' do
    data = [
        {:randMultiple => 0, :createFile => 'Y', :createFileTime => 30},
        {:randMultiple => 0, :createFile => 'N', :createFileTime => 10},
        {:randMultiple => 1, :createFile => 'N', :createFileTime => 32.34},
    ]
    uut = Stats.new(data)

    it 'computes avg per group' do
      expect(uut.avg_with_group(:createFileTime, :randMultiple, 0)).to eq(20)
    end

    it 'computes a Y/N ratio per group' do
      expect(uut.yes_no_ratio_with_group(:createFile, :randMultiple, 0)).to eq(1.0/2.0)
    end

  end

end