require './src/manual_data'

RSpec.describe ManualData do

  it 'augments rows with available manual data' do
    manual_data_json = '[{"id": 25, "dataX": "xyz"}]'
    rows = [
        {:id => 15, :x => 'abc'},
        {:id => 25, :x => 'def'}
    ]

    uut = ManualData.new(manual_data_json)
    result = uut.augment(rows)

    expected = [
        {:id => 15, :x => 'abc'},
        {:id => 25, :x => 'def', :dataX => 'xyz'}
    ]
    expect(result).to eq(expected)
  end

  it 'saves augmentations as json' do
    manual_data_json = '[{"id":25,"dataX":"xyz"}]'
    uut = ManualData.new(manual_data_json)

    expect(uut.to_json).to eq(manual_data_json)
  end

  it 'supports adding augmentations' do
    uut = ManualData.new
    uut.add_data(13, {:dataX => 'a', :dataY => 'b'})

    expected_json = '[{"id":13,"dataX":"a","dataY":"b"}]'

    expect(uut.to_json).to eq(expected_json)
  end

  it 'supports adding augmentations multiple times' do
    uut = ManualData.new
    uut.add_data(10, {:x => 1})
    uut.add_data(10, {:y => 2})

    expect(uut.to_json).to eq('[{"id":10,"x":1,"y":2}]')
  end

end