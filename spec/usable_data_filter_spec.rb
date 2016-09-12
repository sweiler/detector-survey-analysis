require './src/usable_data_filter'

RSpec.describe UsableDataFilter do

  it 'removes unfinished rows' do
    example_data = []
    example_data.push({:submitdate => '2016-08-10 08:10:03'})
    example_data.push({:submitdate => ''})

    uut = UsableDataFilter.new
    result = uut.filter(example_data)

    expect(result.length).to eq(1)
  end

  it 'removes rows with too short duration' do
    example_data = []
    example_data.push({:interviewtime => 133})
    example_data.push({:interviewtime => 60 * 17})

    uut = UsableDataFilter.new
    result = uut.filter(example_data)
    expect(result.length).to eq(1)
  end

  it 'removes empty rows' do
    example_data = [{}, {:content => 3}]
    uut = UsableDataFilter.new
    expect(uut.filter(example_data)).to eq([{:content => 3}])
  end

  it 'can filter with question specific "usable" flags' do
    example_data = [{}, {:usableMultiple => true}, {:usableMultiple => false}]
    uut = UsableDataFilter.new
    expect(uut.filter_with_flag(example_data, :usableMultiple)).to eq([{:usableMultiple => true}])
  end

end