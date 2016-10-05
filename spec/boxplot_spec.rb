require './src/boxplot'

RSpec.describe Boxplot do

  example_data = [
      {:group => 0, :val => 0},
      {:group => 0, :val => 1},
      {:group => 0, :val => 2},
      {:group => 0, :val => 4},
      {:group => 0, :val => 7},

      {:group => 1, :val => 0},
      {:group => 1, :val => 1},
      {:group => 1, :val => 2},
      {:group => 1, :val => 4},

      {:group => 2, :val => 1000}
  ]

  it 'has a correct median when odd' do
    uut = Boxplot.new(example_data, :group, 0, :val)
    expect(uut.median).to eq(2)
  end

  it 'has a correct median when even' do
    uut = Boxplot.new(example_data, :group, 1, :val)
    expect(uut.median).to eq(1.5)
  end

  it 'has correct quartiles' do
    uut = Boxplot.new(example_data, :group, 0, :val)
    expect(uut.lower_quartile).to eq(1)
    expect(uut.upper_quartile).to eq(4)
  end

  it 'has a inter quartile range' do
    uut = Boxplot.new(example_data, :group, 0, :val)
    expect(uut.iqr).to eq(3)
  end

  it 'computes correct antennas' do
    uut = Boxplot.new(example_data, :group, 0, :val)
    expect(uut.upper_antenna).to eq(4)
    expect(uut.lower_antenna).to eq(0)
  end

  it 'computes correct outliers' do
    uut = Boxplot.new(example_data, :group, 0, :val)
    expect(uut.outliers).to eq([7])
  end

  it 'provides the min and max values' do
    uut = Boxplot.new(example_data, :group, 0, :val)
    expect(uut.min_value).to eq(0)
    expect(uut.max_value).to eq(7)
  end

end