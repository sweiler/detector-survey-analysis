require './src/parser'

RSpec.describe Parser do
  it 'creates an empty array for the empty string' do
    result = Parser.parse('')
    expect(result).to eq([])
  end
  
  context 'with headlines in the first line' do
    first_line = '"a","b","c"'
    
    it 'creates an empty array for no data' do
      result = Parser.parse(first_line)
      expect(result).to eq([])
    end
    
    it 'creates corresponding dictionaries' do
      second_line = '"x","y","z"'
      input_str = first_line + "\n" + second_line
      result = Parser.parse(input_str)
      expect(result).to eq([{:a => 'x', :b => 'y', :c => 'z'}])
    end

  end

  it 'converts numbers' do
    data = '"a","b"' + "\n" + '"3","2"'
    result = Parser.parse(data)
    expect(result).to eq([{:a => 3, :b => 2}])
  end
end
